case "$(uname -s)" in
  Darwin*)
    # don't mess with this.. or erlang will stop compiling.
    ;;
  Linux*)
    export PATH="/usr/local/opt/libpq/bin:$PATH"
    export PATH="/usr/local/opt/qt/bin:$PATH"
    export LDFLAGS="$LDFLAGS -L/usr/local/opt/qt/lib"
    export CPPFLAGS="-I/usr/local/opt/qt/include"
    ;;
esac
