case "$(uname -s)" in
  Darwin*)
    # ruby-build -> configure readline path from homebrew
    export RUBY_CONFIGURE_OPTS=--with-readline-dir="$BREW_PREFIX/opt/readline"
    ;;
  Linux*)
    # ruby-build -> configure readline path
    export RUBY_CONFIGURE_OPTS=--with-readline-dir="/usr/include/readline"
    ;;
esac
