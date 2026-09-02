# mfeserve [package...] - serve one or more micro-frontends packages.
#
# Run it from anywhere inside the micro-frontends repo, including a worktree. With no
# argument it serves the package you are standing in, so `cd packages/messaging && mfeserve`
# is the common case. Tab completion lists the packages.
#
# This exists because `just serve` cannot be trusted from a worktree. justfile:16 derives
# the package with a sed regex expecting `/micro-frontends/packages/<name>`, and a worktree
# path has an extra segment between the two, so the match fails. Line 17 then falls back to
# `*`, which serves all thirty packages at once and starves the one you wanted.
mfeserve() {
  local root
  root=$(git rev-parse --show-toplevel 2>/dev/null) || {
    echo "mfeserve: not inside a git repository" >&2
    return 1
  }

  if [[ ! -d "$root/packages" || ! -f "$root/turbo.json" ]]; then
    echo "mfeserve: $root is not the micro-frontends repo" >&2
    return 1
  fi

  local -a packages
  packages=("$@")

  # Standing inside a package is the same as naming it.
  if (( ${#packages} == 0 )) && [[ "$PWD" == "$root/packages/"* ]]; then
    local relative=${PWD#$root/packages/}
    packages=("${relative%%/*}")
  fi

  if (( ${#packages} == 0 )); then
    echo "usage: mfeserve <package> [package...]" >&2
    echo "packages:" >&2
    local manifest
    for manifest in "$root"/packages/*/package.json; do
      echo "  ${${manifest:h}:t}" >&2
    done
    return 1
  fi

  local -a filters
  local package
  for package in "${packages[@]}"; do
    if [[ ! -f "$root/packages/$package/package.json" ]]; then
      echo "mfeserve: no package named $package" >&2
      return 1
    fi
    filters+=("--filter=./packages/$package")
  done

  echo "mfeserve: ${packages[*]}"
  (cd "$root" && FORCE_COLOR=1 yarn turbo run serve "${filters[@]}")
}

_mfeserve() {
  local root
  root=$(git rev-parse --show-toplevel 2>/dev/null) || return
  [[ -d "$root/packages" ]] || return

  local -a names
  local manifest
  for manifest in "$root"/packages/*/package.json; do
    names+=("${${manifest:h}:t}")
  done

  _describe 'package' names
}

compdef _mfeserve mfeserve

# mfetypes [package] - refresh the graphql types, then typecheck a package.
#
# The generated types are built from packages/graphql's schema file, so running tsc
# without refreshing it compares the code against whichever schema was fetched last. A
# field added to sched this morning is invisible until the schema is fetched again, which
# is how a clean tsc run can still fail the moment webpack regenerates the types.
#
# Needs sched running on localhost:4000, which is where fetch-schema reads from.
mfetypes() {
  local root
  root=$(git rev-parse --show-toplevel 2>/dev/null) || {
    echo "mfetypes: not inside a git repository" >&2
    return 1
  }

  if [[ ! -d "$root/packages" || ! -f "$root/turbo.json" ]]; then
    echo "mfetypes: $root is not the micro-frontends repo" >&2
    return 1
  fi

  local package=$1

  if [[ -z "$package" && "$PWD" == "$root/packages/"* ]]; then
    local relative=${PWD#$root/packages/}
    package=${relative%%/*}
  fi

  if [[ -z "$package" ]]; then
    echo "usage: mfetypes <package>" >&2
    return 1
  fi

  if [[ ! -f "$root/packages/$package/tsconfig.json" ]]; then
    echo "mfetypes: no package named $package, or it has no tsconfig" >&2
    return 1
  fi

  echo "mfetypes: fetching the private schema"
  (cd "$root/packages/graphql" && yarn fetch-schema:private) || return 1

  # generate-types is a root task in turbo.json, not a package one, so filtering to
  # packages/graphql matches nothing and silently generates nothing.
  echo "mfetypes: generating types"
  (cd "$root/packages/graphql" && yarn generate-types:private) || return 1

  echo "mfetypes: $package"
  (cd "$root/packages/$package" && yarn tsc --noEmit -p tsconfig.json)
}

compdef _mfeserve mfetypes
