export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

# add support for Ansi for fd color
export FZF_DEFAULT_OPTS="--ansi"

# Tokyonight Theme
export FZF_DEFAULT_OPTS=$FZF_DEFAULT_OPTS'
  --margin 0,0
  --color=fg:#c5cdd9,bg:#000000,hl:#6cb6eb
  --color=fg+:#c5cdd9,bg+:#000000,hl+:#5dbbc1
  --color=info:#88909f,prompt:#ec7279,pointer:#d38aea
  --color=marker:#a0c980,spinner:#ec7279,header:#5dbbc1'

  # Use fd for listing path candiates.
  # - The first argument to the function ($1) is the base path to start traversal
  _fzf_compgen_path() {
    fd --hidden --exclude .git . "$1"
  }

  # Use fd to generate the list for directory complettion
  _fzf_compgen_dir() {
    fd --type=d --hidden --exclude .git . "$1"
  }

  source ~/fzf-git.sh/fzf-git.sh
