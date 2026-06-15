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
