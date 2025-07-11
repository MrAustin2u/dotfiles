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

       # Dashboard
      tmux new-window
      tmux rename-window "Dashboard"
      tmux send-keys -t 0 "clear && dashboard" Enter &

      #Dotfiles
      tmux new-window
      tmux rename-window "Nvim Config"
      tmux send-keys -t 0 "clear && cd ~/dotfiles && vim" Enter &

      #Ngrok
      tmux new-window
      tmux rename-window "Ngrok"
      tmux send-keys -t 0 "clear && cd" Enter "clear && ngrok http 4000 --url aaustin-blvd.ngrok.io" Enter &

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
