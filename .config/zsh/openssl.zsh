case "$(uname -s)" in
  Darwin*)
    # don't mess with this.. or erlang will stop compiling.
    ;;
  Linux*)
    export PATH="/usr/local/opt/openssl@1.1/bin:$PATH"

    # For compilers to find openssl@1.1 you may need to set:
    export LDFLAGS="$LDFLAGS -L/usr/local/opt/openssl@1.1/lib"
    export CPPFLAGS="$CPPFLAGS -I/usr/local/opt/openssl@1.1/include"

    # For pkg-config to find openssl@1.1 you may need to set:
    export PKG_CONFIG_PATH="/usr/local/opt/openssl@1.1/lib/pkgconfig"
    ;;
esac
