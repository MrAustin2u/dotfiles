# Labels a herdr pane with the program running in it, and clears the label when
# that program exits and the shell prompt returns.
#
# Coding agents are deliberately absent from the table. herdr detects them and
# reports live state on the pane border and in the sidebar, but only while no
# manual pane name is set, so titling a claude pane would replace a live status
# with a static string.
#
# Only the executables listed here set a title. Everything else costs one
# associative-array lookup in the shell and starts no process.
#
# Disable by adding this to ~/.zshrc.local:
#   export HERDR_DISABLE_PANE_TITLES=1

# HERDR_PANE_ID is what `herdr pane rename` needs, so its presence is the test
# for running inside a herdr pane.
if [[ -n ${HERDR_PANE_ID:-} && -z ${HERDR_DISABLE_PANE_TITLES:-} ]]; then
  autoload -Uz add-zsh-hook

  typeset -gA HERDR_PANE_TITLES=(
    amp ' amp'
    btop '󰄪 btop'
    claude ' claude'
    cline ' cline'
    codex ' codex'
    copilot ' copilot'
    cursor ' cursor'
    diffnav ' diffnav'
    dive '  dive'
    fx ' fx'
    gemini ' gemini'
    gh ' github'
    git ' git'
    grok ' grok'
    hermes ' hermes'
    iex ' iex'
    jless ' jless'
    kdash '󱃾 kdash'
    kilo ' kilo'
    kimi ' kimi'
    lazydocker '  lazydocker'
    lazygit ' lazygit'
    mastracode ' mastracode'
    mix ' elixir'
    nvim ' neovim'
    opencode ' opencode'
    opencode2 ' opencode v2'
    pi ' pi'
    posting '󰒊 posting'
    pspg ' pspg'
    psql ' psql'
    qodercli ' qodercli'
    tuicr ' tuicr'
    tv '󰟴 television'
    yazi ' yazi'
  )

  _herdr_update_pane_title() {
    local title=$1
    local -a args=(pane rename "$HERDR_PANE_ID")
    if [[ -n $title ]]; then
      args+=("$title")
    else
      args+=(--clear)
    fi

    # Wrapped in a subshell so zsh reports no job control for the background
    # rename, which would otherwise print over the prompt.
    (
      "${HERDR_BIN_PATH:-herdr}" "${args[@]}" >/dev/null 2>&1 &
    )
  }

  _herdr_set_mapped_pane_title() {
    [[ -z ${HERDR_DISABLE_PANE_TITLES:-} ]] || return

    # $3 is the fully expanded command line. Take the first word and drop any
    # leading path, so /opt/homebrew/bin/nvim matches nvim.
    local executable=${3%% *}
    executable=${executable##*/}
    local title=${HERDR_PANE_TITLES[$executable]-}
    [[ -n $title ]] || return

    typeset -g HERDR_PANE_TITLE_ACTIVE=1
    _herdr_update_pane_title "$title"
  }

  _herdr_clear_mapped_pane_title() {
    # Only clear a title this module set, so a pane renamed by hand survives.
    [[ -n ${HERDR_PANE_TITLE_ACTIVE:-} ]] || return

    unset HERDR_PANE_TITLE_ACTIVE
    _herdr_update_pane_title
  }

  add-zsh-hook preexec _herdr_set_mapped_pane_title
  add-zsh-hook precmd _herdr_clear_mapped_pane_title
fi
