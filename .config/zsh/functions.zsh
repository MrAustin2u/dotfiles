# fgstash - easier way to deal with stashes
# type fstash to get a list of your stashes
# enter shows you the contents of the stash
# ctrl-d shows a diff of the stash against your current HEAD
# ctrl-b checks the stash out as a branch, for easier merging
fgstash() {
  local out q k sha
  while out=$(
    git stash list --pretty="%C(yellow)%h %>(14)%Cgreen%cr %C(blue)%gs" |
      fzf --ansi --no-sort --query="$q" --print-query \
        --expect=ctrl-d,ctrl-b
  ); do
    mapfile -t out <<<"$out"
    q="${out[0]}"
    k="${out[1]}"
    sha="${out[-1]}"
    sha="${sha%% *}"
    [[ -z "$sha" ]] && continue
    if [[ "$k" == 'ctrl-d' ]]; then
      git diff $sha
    elif [[ "$k" == 'ctrl-b' ]]; then
      git stash branch "stash-$sha" $sha
      break
    else
      git stash show -p $sha
    fi
  done
}

# killport <port> - kill whatever is listening on the given TCP port.
# Tries a graceful SIGTERM first, then SIGKILL if it's still listening.
killport() {
  local port="$1"
  if [ -z "$port" ]; then
    echo "usage: killport <port>" >&2
    return 1
  fi
  local pids
  pids=$(lsof -ti tcp:"$port" -sTCP:LISTEN)
  if [ -z "$pids" ]; then
    echo "killport: nothing listening on port $port" >&2
    return 1
  fi
  echo "Killing pid(s) on port $port: $pids"
  kill $pids 2>/dev/null
  sleep 1
  pids=$(lsof -ti tcp:"$port" -sTCP:LISTEN)
  if [ -n "$pids" ]; then
    echo "Still alive, sending SIGKILL: $pids"
    kill -9 $pids
  fi
}

# fkill - kill process
fkill() {
  pid=$(ps -ef | sed 1d | fzf -m | awk '{print $2}')

  if [ "x$pid" != "x" ]; then
    kill -${1:-9} $pid
  fi
}

# fgco - checkout git branch/tag
fgco() {
  local tags branches target
  tags=$(
    git tag | awk '{print "\x1b[31;1mtag\x1b[m\t" $1}'
  ) || return
  branches=$(
    git branch --all | grep -v HEAD |
      sed "s/.* //" | sed "s#remotes/[^/]*/##" |
      sort -u | awk '{print "\x1b[34;1mbranch\x1b[m\t" $1}'
  ) || return
  target=$(
    (
      echo "$tags"
      echo "$branches"
    ) |
      fzf-tmux -l30 -- --no-hscroll --ansi +m -d "\t" -n 2
  ) || return
  git checkout $(echo "$target" | awk '{print $2}')
}

 # fgshow - git commit browser
fgshow() {
  git log --graph --color=always \
    --format="%C(auto)%h%d %s %C(black)%C(bold)%cr" "$@" |
    fzf --ansi --no-sort --reverse --tiebreak=index --bind=ctrl-s:toggle-sort \
      --bind "ctrl-m:execute:
                (grep -o '[a-f0-9]\{7\}' | head -1 |
                xargs -I % sh -c 'git show --color=always % | less -R') << 'FZF-EOF'
                {}
FZF-EOF"
}

# fgstash - easier way to deal with stashes
# type fstash to get a list of your stashes
# enter shows you the contents of the stash
# ctrl-d shows a diff of the stash against your current HEAD
# ctrl-b checks the stash out as a branch, for easier merging
fgstash() {
  local out q k sha
  while out=$(
    git stash list --pretty="%C(yellow)%h %>(14)%Cgreen%cr %C(blue)%gs" |
      fzf --ansi --no-sort --query="$q" --print-query \
        --expect=ctrl-d,ctrl-b
  ); do
    mapfile -t out <<<"$out"
    q="${out[0]}"
    k="${out[1]}"
    sha="${out[-1]}"
    sha="${sha%% *}"
    [[ -z "$sha" ]] && continue
    if [[ "$k" == 'ctrl-d' ]]; then
      git diff $sha
    elif [[ "$k" == 'ctrl-b' ]]; then
      git stash branch "stash-$sha" $sha
      break
    else
      git stash show -p $sha
    fi
  done
}

# ask for confirmation in scripts
function confirm() {
  read -p "Are you sure? " -n 1 -r
  echo    # move to a new line
  if [[ ! $REPLY =~ ^[Yy]$ ]]
  then
    exit 1
  fi
}

httpless() {
    # `httpless example.org'
    http --pretty=all --print=hb "$@" | less -R;
}

work() {
  # Set Session Name
  SESSION="BLVD"
  SESSIONEXISTS=$(tmux list-sessions | grep $SESSION)

  # Only create tmux session if it doesn't already exist
  if [ "$SESSIONEXISTS" = "" ]
  then
      # Start New Session with our name
      tmux new-session -d -s $SESSION

      # start servers
      tmux rename-window -t 1 'Servers'
      tmux send-keys -t 0 "clear && sched" Enter "ism" Enter &
      tmux split-window -h
      tmux send-keys -t 1 "clear && dashboard" Enter "yrs" Enter &

      #Sched
      tmux new-window
      tmux rename-window "Sched"
      tmux send-keys -t 0 "clear && sched" Enter &
      tmux split-window -h
      tmux send-keys -t 1 "clear && sched" Enter "claude" Enter &

       # Dashboard
      tmux new-window
      tmux rename-window "Dashboard"
      tmux send-keys -t 0 "clear && dashboard" Enter &
      tmux split-window -h
      tmux send-keys -t 1 "clear && dashboard" Enter "claude" Enter &

      #Dotfiles
      tmux new-window
      tmux rename-window "Nvim Config"
      tmux send-keys -t 0 "clear && cd ~/dotfiles && vim" Enter &
      tmux split-window -h
      tmux send-keys -t 1 "clear && cd ~/dotfiles && claude" Enter &

      #Ngrok
      tmux new-window
      tmux rename-window "Ngrok"
      tmux send-keys -t 0 "clear && cd" Enter "clear && ngrok start blvd" Enter &

      tmux select-window -t "Servers"
  fi

  # Attach Session, on the Main window
  tmux attach-session -t $SESSION
}

# nerds() {
#   # Set Session Name
#   SESSION="NERDS"
#   SESSIONEXISTS=$(tmux list-sessions | grep $SESSION)
#
#   # Only create tmux session if it doesn't already exist
#   if [ "$SESSIONEXISTS" = "" ]
#   then
#       # Start New Session with our name
#       tmux new-session -d -s $SESSION
#
#       # start NERDS local servers
#       tmux rename-window -t 1 'NERDS servers'
#       tmux send-keys -t 1 "clear && nerds" Enter "pnpm dev" Enter &
#       tmux split-window -h -p 50
#       tmux send-keys -t 2 "clear && nerds" Enter "pnpm db:studio" Enter &
#
#       #NERDS website code
#       tmux new-window
#       tmux rename-window "NERDS website"
#       tmux send-keys -t 1 "clear && nerds" Enter &
#
#       tmux select-window -t "NERDS servers"
#   fi
#
#   # Attach Session, on the Main window
#   tmux attach-session -t $SESSION
# }

slb() {
  # Set Session Name
  SESSION="BLVD"
  SESSIONEXISTS=$(tmux list-sessions | grep $SESSION)

  # Only create tmux session if it doesn't already exist
  if [ "$SESSIONEXISTS" = "" ]
    mix escript.install hex livebook
    livebook server
  then
  fi
}

# Push local branch to BLVD dev env
jpb() {
  CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
  DEPLOYMENT_ENV="$1"
  if [[ -n $* ]]
    echo "Pushing $CURRENT_BRANCH to $*!"
  then
    git push -f origin $CURRENT_BRANCH:$*
  fi
}

ff() {
  aerospace list-windows --all | fzf --bind 'enter:execute(bash -c "aerospace focus --window-id {1}")+abort'
}

# dockerprune - show everything Docker is holding (containers, images,
# volumes, networks), then confirm before removing ALL of it. Volumes are
# removed unconditionally (not just dangling ones), so any data in named
# volumes is lost.
dockerprune() {
  echo "=== Containers ==="
  docker ps -a --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}'
  echo "\n=== Images ==="
  docker image ls --format 'table {{.Repository}}\t{{.Tag}}\t{{.Size}}'
  echo "\n=== Volumes ==="
  docker volume ls --format 'table {{.Name}}\t{{.Driver}}'
  echo "\n=== Networks (custom) ==="
  docker network ls --filter type=custom --format 'table {{.Name}}\t{{.Driver}}'
  echo ""
  read -q "REPLY?Remove ALL of the above (containers, images, volumes, networks)? [y/N] " || { echo ""; return 1 }
  echo ""
  docker stop $(docker ps -aq) 2>/dev/null
  docker rm $(docker ps -aq) 2>/dev/null
  docker image prune -a -f
  docker volume rm -f $(docker volume ls -q) 2>/dev/null
  docker network prune -f
}

# prunegitbranches <pattern> - clean up local branches matching <pattern>
# (case-insensitive, extended regex) whose PR is MERGED or CLOSED on GitHub.
# If the branch has an active git worktree managed by workmux, removes it via
# `workmux remove` (which also drops the branch). For worktrees not managed by
# workmux, falls back to `git worktree remove` + `git branch -D`.
# Branches with no worktree are deleted with `git branch -D`.
# Branches with an open PR, no PR, or unknown state are kept.
# Requires `gh` (authenticated). `jq` is used for workmux handle lookup; without
# it, all worktree removals fall through to the plain `git` path.
prunegitbranches() {
  local pattern="$1"
  if [ -z "$pattern" ]; then
    echo "usage: prunegitbranches <pattern>" >&2
    echo "  e.g. prunegitbranches mktg" >&2
    return 1
  fi
  local b state worktree_path wt_handle workmux_map
  workmux_map=$(workmux list --json 2>/dev/null \
    | jq -r '.[] | "\(.path)\t\(.handle)"' 2>/dev/null)
  for b in $(git branch --format='%(refname:short)' | grep -iE "$pattern"); do
    state=$(gh pr view "$b" --json state -q .state 2>/dev/null)
    case "$state" in
      MERGED|CLOSED)
        worktree_path=$(git worktree list --porcelain \
          | awk -v branch="refs/heads/$b" '
              /^worktree / { wt = substr($0, 10) }
              $0 == "branch " branch { print wt; exit }
            ')
        if [ -n "$worktree_path" ]; then
          wt_handle=$(printf '%s\n' "$workmux_map" \
            | awk -F'\t' -v p="$worktree_path" '$1 == p { print $2; exit }')
          if [ -n "$wt_handle" ]; then
            echo "Removing workmux worktree $wt_handle for $b (PR $state)"
            workmux remove "$wt_handle"
          else
            echo "Removing unmanaged worktree $worktree_path for $b (PR $state)"
            git worktree remove "$worktree_path" && git branch -D "$b"
          fi
        else
          echo "Deleting $b (PR $state)"
          git branch -D "$b"
        fi
        ;;
      *)
        echo "Keeping $b (PR state: ${state:-no PR found})"
        ;;
    esac
  done
}

# tginbound - simulate a Telgorithm inbound SMS webhook against the local sched
# server (origin :incoming_contact_center). Handy for exercising the messaging /
# Beau pipeline without sending a real text. Run from the sched repo (a worktree
# is fine) so the direnv-loaded TELGORITHM_PRIMARY_TOKEN is in the environment.
#
# Usage:
#   tginbound                                    # sample text, default numbers
#   tginbound --to +15551234567 --text "hi"      # customise recipient / body
#   tginbound -f +15557654321 -t +15551234567 -m "any openings?"
#   tginbound --smee                             # send via the smee proxy instead of direct
#   tginbound https://my-tunnel.ngrok.app        # target a different domain (path is appended)
#   tginbound --target http://localhost:4001/webhooks/telgorithm/inbound_message
#
# Defaults for --from/--to can be set once via $TG_INBOUND_FROM / $TG_INBOUND_TO.
# Use a real booking-line number for --to to drive the full inbound routing.
tginbound() {
  emulate -L zsh
  local from="${TG_INBOUND_FROM:-+19876543210}"
  local to="${TG_INBOUND_TO:-+11234567890}"
  local text="Hi, do you have any openings this week?"
  local domain="http://localhost:4000"
  local target=""
  local smee_url="https://smee.io/blvd-telgorithm-inbound-message-dev"
  local use_smee=0

  while (( $# )); do
    case "$1" in
      -f|--from)            from="$2";   shift 2 ;;
      -t|--to)              to="$2";     shift 2 ;;
      -m|--text|--message)  text="$2";   shift 2 ;;
      -d|--domain)          domain="$2"; shift 2 ;;
      --target)             target="$2"; shift 2 ;;
      --smee)               use_smee=1;  shift ;;
      -h|--help)
        print -r -- "usage: tginbound [DOMAIN] [-f FROM] [-t TO] [-m TEXT] [-d DOMAIN] [--target URL] [--smee]"
        return 0 ;;
      -*) print -ru2 -- "tginbound: unknown option: $1"; return 1 ;;
      *)  domain="$1"; shift ;;
    esac
  done

  # Build the target from the domain unless an explicit --target was given.
  # Strip any trailing slash on the domain so we don't double up.
  [[ -n "$target" ]] || target="${domain%/}/webhooks/telgorithm/inbound_message"

  local bin
  for bin in curl jq openssl; do
    command -v "$bin" >/dev/null 2>&1 || { print -ru2 -- "tginbound: '$bin' not found"; return 1; }
  done

  # Only To/From/Text come from args; everything else in the body is generated
  # dynamically each call: fresh Sid/WebhookSid (so per-Sid dedup doesn't drop
  # it), current EventDate, and SegmentCount derived from the text length
  # (160 chars for a single GSM-7 segment, 153 per part when concatenated).
  local len=${#text} seg
  if (( len <= 160 )); then seg=1; else seg=$(( (len + 152) / 153 )); fi

  local body
  body=$(jq -n \
    --arg wsid "WH$(openssl rand -hex 24)" \
    --arg sid  "IM$(openssl rand -hex 24)" \
    --arg from "$from" \
    --arg to   "$to" \
    --arg date "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
    --arg text "$text" \
    --argjson seg "$seg" \
    '{WebhookSid:$wsid, Sid:$sid, From:$from, To:$to, AdditionalRecipients:[],
      EventDate:$date, Text:$text, MediaUrls:[], SegmentCount:$seg,
      ConversationMetadata:"{}"}') || return 1

  if (( use_smee )); then
    # The webhook proxy attaches the Bearer token on the way to the target.
    print -r -- "→ POST $smee_url  (To: $to  From: $from)"
    curl -sS -i -X POST "$smee_url" \
      -H "Content-Type: application/json" \
      -d "$body"
    return
  fi

  if [[ -z "${TELGORITHM_PRIMARY_TOKEN:-}" ]]; then
    print -ru2 -- "tginbound: TELGORITHM_PRIMARY_TOKEN is not set — is direnv loaded? (try 'direnv reload' in the repo)"
    return 1
  fi

  print -r -- "→ POST $target  (To: $to  From: $from)"
  curl -sS -i -X POST "$target" \
    -H "Authorization: Bearer $TELGORITHM_PRIMARY_TOKEN" \
    -H "Content-Type: application/json" \
    -d "$body"
}

# tgtraffic - simulate a Telgorithm TrafficLimitAlert webhook against the local
# sched server. The alert says a location's messaging is near, or past, what a
# carrier lets it send; an attributed alert opens a TCR Task on the TECH board.
# Run from the sched repo (a worktree is fine) so the direnv-loaded
# TELGORITHM_PRIMARY_TOKEN is in the environment.
#
# The brand and campaign ids have to match a telephony_a2p_campaign_registries
# row or the alert resolves to no location and no ticket is created (itself a
# case worth testing). --from-db fills them in from the first row that has one.
#
# Usage:
#   tgtraffic --from-db                          # nearest thing to a one-liner
#   tgtraffic --from-db -u 100                   # at the limit, not approaching
#   tgtraffic --from-db -e SenderPhoneNumber     # resolve via the booking line
#   tgtraffic -b B6918 -c C6982                  # ids you already have
#   tgtraffic --from-db -M T-Mobile -w Sec -T 5  # different carrier and window
#   tgtraffic --miss                             # ids that match nothing
#   tgtraffic -d http://localhost:4001 --from-db # server on another port
#
# Defaults can be set once via $TG_TRAFFIC_BRAND_ID / $TG_TRAFFIC_CAMPAIGN_ID.
#
# One ticket is created per location, carrier and usage state per 12 hours, so a
# repeat call is deduped on purpose. To get a fresh ticket change --mno, or move
# --usage across 100, or clear the job:
#   psql -d sched_development -c "delete from oban_jobs where worker =
#     'BlvdTelephony.TelgorithmEvents.Jobs.RequestThroughputLimitSupport';"
tgtraffic() {
  emulate -L zsh
  local brand="${TG_TRAFFIC_BRAND_ID:-}"
  local campaign="${TG_TRAFFIC_CAMPAIGN_ID:-}"
  local entity="Campaign"
  local phone=""
  local mno="AT&T"
  local usage="75.5"
  local throughput="100"
  local window="Min"
  local msgtype="SMS"
  local domain="http://localhost:4000"
  local target=""
  local db="sched_development"
  local from_db=0 miss=0

  while (( $# )); do
    case "$1" in
      -b|--brand-id)           brand="$2";      shift 2 ;;
      -c|--campaign-id)        campaign="$2";   shift 2 ;;
      -e|--entity-type)        entity="$2";     shift 2 ;;
      -p|--phone)              phone="$2";      shift 2 ;;
      -M|--mno|--carrier)      mno="$2";        shift 2 ;;
      -u|--usage|--percentage) usage="$2";      shift 2 ;;
      -T|--throughput)         throughput="$2"; shift 2 ;;
      -w|--window)             window="$2";     shift 2 ;;
      -m|--message-type)       msgtype="$2";    shift 2 ;;
      -d|--domain)             domain="$2";     shift 2 ;;
      --target)                target="$2";     shift 2 ;;
      --database)              db="$2";         shift 2 ;;
      --from-db)               from_db=1;       shift ;;
      --miss)                  miss=1;          shift ;;
      -h|--help)
        print -r -- "usage: tgtraffic [DOMAIN] [-b BRAND] [-c CAMPAIGN] [-e ENTITY] [-p PHONE]"
        print -r -- "                 [-M MNO] [-u PCT] [-T N] [-w Sec|Min|Day] [-m SMS|MMS]"
        print -r -- "                 [-d DOMAIN] [--target URL] [--database NAME] [--from-db] [--miss]"
        return 0 ;;
      -*) print -ru2 -- "tgtraffic: unknown option: $1"; return 1 ;;
      *)  domain="$1"; shift ;;
    esac
  done

  local bin
  for bin in curl jq openssl; do
    command -v "$bin" >/dev/null 2>&1 || { print -ru2 -- "tgtraffic: '$bin' not found"; return 1; }
  done

  # Ids that deliberately match nothing, to exercise the no-ticket path.
  if (( miss )); then
    brand="B0000000"; campaign="C0000000"; phone="+15550000000"
  elif (( from_db )); then
    command -v psql >/dev/null 2>&1 || { print -ru2 -- "tgtraffic: 'psql' not found"; return 1; }

    local row
    row=$(psql -d "$db" -tAF'|' -c "
      select r.tcr_brand_id, r.tcr_campaign_id, r.location_id, coalesce(b.incoming_number, '')
      from telephony_a2p_campaign_registries r
      left join booking_lines b on b.location_id = r.location_id
      where r.tcr_campaign_id is not null
      limit 1;") || return 1

    if [[ -z "$row" ]]; then
      print -ru2 -- "tgtraffic: no telephony_a2p_campaign_registries row with a tcr_campaign_id in '$db'"
      return 1
    fi

    local location
    IFS='|' read -r brand campaign location phone <<< "$row"
    print -r -- "  from $db: brand $brand  campaign $campaign  location $location  phone ${phone:-none}"

    if [[ "$entity" == "SenderPhoneNumber" && -z "$phone" ]]; then
      print -ru2 -- "tgtraffic: location $location has no booking line, so there is no sender number to send as"
      return 1
    fi
  fi

  if [[ -z "$brand" && -z "$campaign" && -z "$phone" ]]; then
    print -ru2 -- "tgtraffic: need ids to attribute the alert — pass -b/-c, or --from-db, or --miss"
    return 1
  fi

  [[ -n "$target" ]] || target="${domain%/}/webhooks/telgorithm/traffic_limit_alert"

  if [[ -z "${TELGORITHM_PRIMARY_TOKEN:-}" ]]; then
    print -ru2 -- "tgtraffic: TELGORITHM_PRIMARY_TOKEN is not set — is direnv loaded? (try 'direnv reload' in the repo)"
    return 1
  fi

  # A real sender-number alert carries no brand or campaign; the server recovers
  # both from the registry row it reaches through the booking line. Sending them
  # anyway would test the wrong path.
  local jq_brand="\$brand" jq_campaign="\$campaign" jq_phone="\$phone"
  if [[ "$entity" == "SenderPhoneNumber" ]]; then
    jq_brand="null"; jq_campaign="null"
  else
    jq_phone="null"
  fi

  local body
  body=$(jq -n \
    --arg sid "WH$(openssl rand -hex 16)" \
    --arg date "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
    --arg entity "$entity" \
    --arg brand "$brand" \
    --arg campaign "$campaign" \
    --arg phone "$phone" \
    --arg mno "$mno" \
    --arg window "$window" \
    --arg msgtype "$msgtype" \
    --argjson throughput "$throughput" \
    --argjson usage "$usage" \
    "{sid:\$sid, type:\"TrafficLimitAlert\",
      payload:{eventDate:\$date, entityType:\$entity, brandId:$jq_brand,
               campaignId:$jq_campaign, phone:$jq_phone, mno:\$mno,
               throughput:\$throughput, throughputTimeWindow:\$window,
               messageType:\$msgtype, dailyUsagePercentage:\$usage}}") || return 1

  local state; (( $(printf '%.0f' "$usage") >= 100 )) && state="reached" || state="approaching"
  print -r -- "→ POST $target  ($entity  $mno  ${usage}% → $state)"
  curl -sS -i -X POST "$target" \
    -H "Authorization: Bearer $TELGORITHM_PRIMARY_TOKEN" \
    -H "Content-Type: application/json" \
    -d "$body"
}

# pgfix - diagnose, and optionally repair, a Homebrew Postgres that won't start.
#
# The usual cause is a stale postmaster.pid left behind by a reboot or a hard
# kill. On the way back up the PID recorded in that file has been recycled by an
# unrelated process, so Postgres's "is another postmaster alive?" check gets a
# false positive and refuses to boot; launchd then retries every 10s forever and
# `brew services list` shows `error`. What you see at the prompt is:
#
#   psql: error: connection to server on socket "/tmp/.s.PGSQL.5432" failed:
#         No such file or directory
#
# Clearing that lock file while a server really is running risks corruption, so
# pgfix proves no postmaster is alive first: it probes the socket and port, and
# identifies the process holding the recorded PID. Everything is read-only until
# you answer the prompt, and it refuses outright if anything looks like Postgres.
#
# Usage:
#   pgfix                # auto-detect the formula, diagnose, prompt to fix
#   pgfix -n             # diagnose only, never prompt
#   pgfix -y             # skip the prompt (the checks above still gate the fix)
#   pgfix postgresql@16  # pin the formula (or set $PGFIX_FORMULA)
pgfix() {
  emulate -L zsh

  local formula="" dry=0 assume_yes=0
  while (( $# )); do
    case "$1" in
      -n|--dry-run) dry=1; shift ;;
      -y|--yes)     assume_yes=1; shift ;;
      -h|--help)
        print -r -- "usage: pgfix [-n|--dry-run] [-y|--yes] [FORMULA]"
        return 0 ;;
      -*) print -ru2 -- "pgfix: unknown option: $1"; return 1 ;;
      *)  formula="$1"; shift ;;
    esac
  done
  [[ -n "$formula" ]] || formula="${PGFIX_FORMULA:-}"

  command -v brew >/dev/null 2>&1 || { print -ru2 -- "pgfix: brew not found"; return 1 }
  local prefix
  prefix=$(brew --prefix) || return 1

  if [[ -z "$formula" ]]; then
    formula=$(brew services list 2>/dev/null \
      | awk '$1 ~ /^postgresql(@[0-9.]+)?$/ { print $1; exit }')
  fi
  if [[ -z "$formula" ]]; then
    print -ru2 -- "pgfix: no postgresql formula in 'brew services list' — pass one explicitly"
    return 1
  fi

  local datadir="$prefix/var/$formula"
  local logfile="$prefix/var/log/$formula.log"
  local pidfile="$datadir/postmaster.pid"
  if [[ ! -d "$datadir" ]]; then
    print -ru2 -- "pgfix: data directory not found: $datadir"
    return 1
  fi

  # Prefer the formula's own binaries; it's keg-only, so PATH may not have them.
  local isready="$prefix/opt/$formula/bin/pg_isready"
  local psqlbin="$prefix/opt/$formula/bin/psql"
  [[ -x "$isready" ]] || isready=$(command -v pg_isready)
  [[ -x "$psqlbin" ]] || psqlbin=$(command -v psql)

  print -r -- "=== Service ==="
  brew services list 2>/dev/null | awk -v f="$formula" 'NR == 1 || $1 == f'

  # postmaster.pid is positional: pid, data dir, start epoch, port, socket dir,
  # listen address, shmem key, status. Fall back to Homebrew's defaults.
  local pid="" port=5432 sockdir=/tmp pgstatus=""
  if [[ -r "$pidfile" ]]; then
    local -a pidlines
    pidlines=("${(@f)$(<$pidfile)}")
    pid="${pidlines[1]}"
    port="${pidlines[4]:-5432}"
    sockdir="${pidlines[5]:-/tmp}"
    pgstatus="${pidlines[8]}"
  fi
  local sock="$sockdir/.s.PGSQL.$port"

  print -- "\n=== Is a server actually up? ==="
  local alive=0
  if [[ -n "$isready" ]] && "$isready" -h "$sockdir" -p "$port" >/dev/null 2>&1; then
    alive=1
    print -r -- "pg_isready : accepting connections on $sockdir:$port"
  elif [[ -n "$isready" ]]; then
    print -r -- "pg_isready : no response on $sockdir:$port"
  else
    print -r -- "pg_isready : not found, relying on socket and port checks"
  fi

  if [[ -S "$sock" ]]; then
    print -r -- "socket     : $sock exists"
  else
    print -r -- "socket     : $sock missing"
  fi

  local listeners
  listeners=$(lsof -nP -iTCP:"$port" -sTCP:LISTEN 2>/dev/null | sed 1d)
  if [[ -n "$listeners" ]]; then
    print -r -- "port $port  : in use by"
    print -r -- "$listeners" | sed 's/^/             /'
  else
    print -r -- "port $port  : nothing listening"
  fi

  if (( alive )); then
    print -- "\npgfix: Postgres is up and accepting connections — nothing to fix."
    return 0
  fi

  # A postmaster on this data directory means the diagnosis above is wrong
  # somehow; never clear a lock file out from under a live server.
  local same
  same=$(pgrep -fl -- "postgres.*-D $datadir" 2>/dev/null)
  if [[ -n "$same" ]]; then
    print -u2 -- "\npgfix: a postmaster is already running on $datadir:"
    print -ru2 -- "$same"
    print -ru2 -- "       Refusing to touch $pidfile. Investigate by hand."
    return 1
  fi

  local need_unlock=0
  if [[ -n "$pid" ]]; then
    local owner
    owner=$(ps -p "$pid" -o command= 2>/dev/null)
    print -- "\n=== Recorded lock holder ==="
    print -r -- "postmaster.pid : pid $pid, port $port, socket dir $sockdir, status ${pgstatus:-unknown}"
    if [[ -z "$owner" ]]; then
      print -r -- "pid $pid        : not running"
    else
      print -r -- "pid $pid        : $owner"
    fi
    if [[ "$owner" == *postgres* ]]; then
      print -u2 -- "\npgfix: pid $pid looks like Postgres. Refusing to remove $pidfile."
      return 1
    fi
    need_unlock=1
  else
    print -- "\nNo postmaster.pid — the server is stopped, not lock-jammed."
  fi

  if [[ -r "$logfile" ]]; then
    print -- "\n=== Last log lines ($logfile) ==="
    tail -5 "$logfile"
  fi

  print -r -- ""
  if (( need_unlock )); then
    print -r -- "Verdict: no server on $sock, nothing listening on $port, and pid $pid is not"
    print -r -- "         a Postgres process — $pidfile is stale."
  else
    print -r -- "Verdict: $formula is simply not running."
  fi

  if (( dry )); then
    print -r -- "(dry run, stopping here)"
    return 0
  fi

  if (( ! assume_yes )); then
    local prompt_msg="Restart $formula? [y/N] "
    (( need_unlock )) && prompt_msg="Remove the stale lock file and restart $formula? [y/N] "
    read -q "REPLY?$prompt_msg" || { print ""; return 1 }
    print ""
  fi

  if (( need_unlock )); then
    rm -f "$pidfile" || return 1
  fi
  brew services restart "$formula" || return 1

  # The postmaster needs a moment to create its socket; don't call it a win early.
  local i
  for i in {1..15}; do
    if [[ -n "$isready" ]] && "$isready" -h "$sockdir" -p "$port" >/dev/null 2>&1; then
      print -- "\npgfix: $formula is up on $sock"
      [[ -n "$psqlbin" ]] && "$psqlbin" -l 2>/dev/null | head -20
      return 0
    fi
    [[ -z "$isready" && -S "$sock" ]] && { print -- "\npgfix: socket $sock is back"; return 0 }
    sleep 1
  done

  print -u2 -- "\npgfix: $formula still isn't accepting connections. Recent log:"
  tail -20 "$logfile" >&2
  return 1
}
