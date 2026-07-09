cd() { builtin cd "$@" && ls; }

tmpl() {
    local src
    case "$1" in
        python|py) src="main.py" ;;
        java)      src="Main.java" ;;
        rust|rs)   src="main.rs" ;;
        c++|cpp)   src="main.cpp" ;;
        *)         src="$1" ;;
    esac
    if [ -n "$2" ]; then
        mkdir -p "$2" && cp -i "$HOME/template/$src" "$2/$src"
    else
        cp -i "$HOME/template/$src" "./$src"
    fi
}
