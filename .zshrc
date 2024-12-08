
#  ▄███████▄     ▄████████    ▄█    █▄
# ██▀     ▄██   ███    ███   ███    ███
#       ▄███▀   ███    █▀    ███    ███
#  ▀█▀▄███▀▄▄   ███         ▄███▄▄▄▄███▄▄
#   ▄███▀   ▀ ▀███████████ ▀▀███▀▀▀▀███▀
# ▄███▀                ███   ███    ███
# ███▄     ▄█    ▄█    ███   ███    ███
#  ▀████████▀  ▄████████▀    ███    █▀
#

export LANG="en_US.UTF-8"

# =====================================================
# set XDG paths
# =====================================================

export XDG_CACHE_HOME="${HOME}/.cache"
export XDG_DATA_HOME="${HOME}/.local/share"
export XDG_CONFIG_HOME="${HOME}/.config"


# =====================================================
# these must be here because otherwise asdf will get pushed after brew (files
# are loaded in alphabetical order) - this is not ideal, but it's the best
# solution for now
# =====================================================

# set homebrew on path (Intel)
export PATH="/usr/local/bin:$PATH"

# set homebrew on path (Apple Silicon) - should be first to override system bins
# (e.g. for updating zsh or bash)
export PATH="/opt/homebrew/bin:$PATH"

# =====================================================
# load all config files
# =====================================================

for f in ${XDG_CONFIG_HOME}/zsh/*; do
  source $f
done

# =====================================================
# preferred editor
# =====================================================

if [ -z ${EDITOR+x} ]; then
  export EDITOR='nvim'
fi

# Editor for git commits, rebases etc (don't set it if it was set already...
# i.e. by NeoVim)
if [ -z ${GIT_EDITOR+x} ]; then
  export GIT_EDITOR='nvim'
fi

# =====================================================
# load and source
# =====================================================

# alias
[[ -f ~/.aliases ]] && source ~/.aliases

# zsh
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

# =====================================================
# Starship
# =====================================================

# set up starship prompt
export STARSHIP_CONFIG="$HOME/.config/starship/config.toml"
eval "$(starship init zsh)"