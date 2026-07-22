cd() { builtin cd "$@" && ls; }

# Copy a language template from ~/template into cwd (or a target dir)
tmpl() {
  local src base="$HOME/template"
  case "${1:-}" in
    python | py) src="main.py" ;;
    java) src="Main.java" ;;
    rust | rs) src="main.rs" ;;
    c++ | cpp) src="main.cpp" ;;
    "") echo "usage: tmpl <lang|filename> [dest_dir]" >&2; return 1 ;;
    *) src="$1" ;;
  esac
  if [ ! -f "$base/$src" ]; then
    echo "template not found: $base/$src" >&2
    return 1
  fi
  if [ -n "${2:-}" ]; then
    mkdir -p "$2" && cp -i "$base/$src" "$2/$src"
  else
    cp -i "$base/$src" "./$src"
  fi
}
