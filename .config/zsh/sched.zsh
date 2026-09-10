# provision_sched - bring a sched checkout or worktree up to a working state.
#
# Run it from anywhere inside a sched checkout, including a worktree, and run it before doing
# anything else in a fresh one. Skipping it does not just defer the local checks, it removes
# them: `mix format` cannot run without compiled deps, because Styler and MixGraphqlFormatter
# are formatter plugins that have to be compiled first.
#
# Every step goes through `direnv exec`. `direnv allow` grants the directory but does not
# export anything into the shell already running, so the variables do not appear until the
# next prompt, which is too late for the commands below.
provision_sched() {
  local root
  root=$(git rev-parse --show-toplevel 2>/dev/null) || {
    echo "provision_sched: not inside a git repository" >&2
    return 1
  }

  if [[ ! -f "$root/mix.exs" || ! -d "$root/apps/blvd" ]]; then
    echo "provision_sched: $root is not the sched repo" >&2
    return 1
  fi

  echo "provision_sched: $root"

  echo "provision_sched: orbstack"
  orb start || return 1
  docker context use orbstack || return 1

  # Granting the directory is separate from reading it; see the note above.
  echo "provision_sched: direnv"
  direnv allow "$root" || return 1

  local -a mix
  mix=(direnv exec "$root" mix)

  echo "provision_sched: config json"
  (cd "$root" && direnv exec . just fetch-latest-config-json) || return 1

  # An empty deps/ fails every mix task, blvd.provision included, so the fetch has to come
  # first in a checkout that has never been built.
  if [[ ! -d "$root/deps" || -z "$(print -rn -- "$root"/deps/*(N))" ]]; then
    echo "provision_sched: deps (empty, fetching before the mix tasks)"
    "${mix[@]}" deps.get || return 1
  fi

  echo "provision_sched: algolia"
  "${mix[@]}" blvd.provision || return 1

  # localstack as well as typesense. redis and postgres are in the backend profile too but
  # run natively on this machine, so bringing up the whole profile would collide with them
  # on 5432 and 6379.
  echo "provision_sched: containers"
  (cd "$root" && docker compose --profile backend up -d localstack typesense) || return 1

  # Nothing provisioned into localstack lands until it answers, and a docker prune leaves it
  # rebuilding from an empty volume, which takes longer than `up -d` returning.
  echo "provision_sched: waiting for localstack"
  local waited=0
  until curl -fsS --max-time 2 http://localhost:4566/_localstack/health >/dev/null 2>&1; do
    (( waited += 2 ))
    if (( waited > 90 )); then
      echo "provision_sched: localstack did not come up within 90s" >&2
      return 1
    fi
    sleep 2
  done

  echo "provision_sched: typesense collection"
  (cd "$root" && direnv exec . ./scripts/provision_local_typesense) || return 1

  # A prune takes the localstack volume, so the queues and buckets go with it. Without these
  # sched boots and then floods the log with econnrefused against every SQS queue.
  echo "provision_sched: localstack eventbridge and s3"
  (cd "$root" && direnv exec . ./scripts/provision_localstack_eventbridge) || return 1
  (cd "$root" && direnv exec . ./scripts/provision_localstack_s3) || return 1

  echo "provision_sched: deps"
  "${mix[@]}" deps.get || return 1

  echo "provision_sched: compile"
  "${mix[@]}" compile || return 1

  # Worktrees share one development database, so this migrates the database every other
  # worktree is using too.
  echo "provision_sched: migrate"
  "${mix[@]}" ecto.migrate || return 1

  # Last, because the terraform in terraform/sched_localstack_kms stops with
  # AlreadyExistsException once alias/phi/secure-messaging and alias/phi/isolation-fixture
  # exist in localstack, which is every run after the first. That one error is benign, and
  # only that one: treating every failure as expected once hid a localstack that was not
  # running at all, and the function still reported success.
  #
  # The same apply is what writes .env.localstack-kms, so an alias error aborts before the
  # file appears, which is why its absence is checked separately below.
  echo "provision_sched: localstack kms"
  local kms_log kms_status
  kms_log=$(cd "$root" && direnv exec . ./scripts/provision_localstack_kms 2>&1)
  kms_status=$?

  if (( kms_status != 0 )); then
    if [[ "$kms_log" == *AlreadyExistsException* ]]; then
      echo "provision_sched: kms aliases already exist, which is expected after the first run" >&2
    else
      echo "provision_sched: kms apply failed for a reason other than existing aliases" >&2
      printf '%s\n' "$kms_log" >&2
      return 1
    fi
  fi

  if [[ -e "$root/.env.localstack-kms" ]]; then
    echo "provision_sched: done"
    return 0
  fi

  cat >&2 <<'MISSING'
provision_sched: .env.localstack-kms is missing, so SECURE_CONTENT_KEY_ALIAS_MESSAGING,
  SECURE_CONTENT_KEY_ALIAS_ISOLATION_FIXTURE and SECURE_CONTENT_KMS_ENDPOINT_URL are unset
  and secure messaging will not work locally. Link it from the main checkout:

    ln -s ~/BLVD/sched/.env.localstack-kms .env.localstack-kms

  The alias names in it are static, so a copy from any checkout is correct. Do not reach for
  `terraform import` to fix the apply: the live aliases and the keys in terraform state have
  drifted apart, and re-pointing the aliases makes everything already encrypted under the
  current targets undecryptable.
MISSING

  return 1
}
