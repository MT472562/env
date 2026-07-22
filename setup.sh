#!/usr/bin/env bash
# Bootstrap a machine from the env repo.
# Usage:
#   bash setup.sh                  # full interactive setup
#   bash setup.sh --deploy-only    # configs only
#   bash setup.sh --ssh-paste      # only SSH key paste helper
#   bash setup.sh --no-ssh         # skip SSH section
#   bash setup.sh --yes            # non-interactive defaults (skip SSH paste)
set -euo pipefail

# Prefer SSH Host alias (multi-account). Override as needed:
#   ENV_ACCOUNT=maruchandev|mt472562  ENV_REPO=owner/name
ENV_ACCOUNT="${ENV_ACCOUNT:-maruchandev}"
ENV_REPO="${ENV_REPO:-maruchandev/env}"
case "$ENV_ACCOUNT" in
  mt472562 | mt) ENV_SSH_HOST="github.com-mt472562" ;;
  *) ENV_SSH_HOST="github.com-maruchandev" ;;
esac
REPO_URL_SSH="git@${ENV_SSH_HOST}:${ENV_REPO}.git"
REPO_URL_HTTPS="https://github.com/${ENV_REPO}.git"
REPO_DIR="${REPO_DIR:-$HOME/env}"

DEPLOY_ONLY=0
SSH_ONLY=0
DO_SSH=1
ASSUME_YES=0

for arg in "$@"; do
  case "$arg" in
    --deploy-only) DEPLOY_ONLY=1 ;;
    --ssh-paste | --ssh-only) SSH_ONLY=1 ;;
    --no-ssh) DO_SSH=0 ;;
    --yes | -y) ASSUME_YES=1 ;;
    -h | --help)
      sed -n '2,12p' "$0"
      exit 0
      ;;
  esac
done

# ---------------------------------------------------------------------------
# Resolve repo root
# ---------------------------------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$SCRIPT_DIR/deploy.sh" ] && [ -d "$SCRIPT_DIR/bashrc.d" ]; then
  ROOT="$SCRIPT_DIR"
else
  echo "--- cloning env repo → $REPO_DIR ---"
  if [ -d "$REPO_DIR/.git" ]; then
    if command -v gh >/dev/null 2>&1 && gh auth status >/dev/null 2>&1; then
      gh auth setup-git 2>/dev/null || true
      git -C "$REPO_DIR" pull --ff-only || true
    else
      git -C "$REPO_DIR" pull --ff-only || true
    fi
  else
    # Prefer SSH Host alias (multi-account keys); fall back to gh / HTTPS
    if git clone "$REPO_URL_SSH" "$REPO_DIR" 2>/dev/null; then
      :
    elif command -v gh >/dev/null 2>&1 && gh auth status >/dev/null 2>&1; then
      gh auth setup-git 2>/dev/null || true
      gh repo clone "$ENV_REPO" "$REPO_DIR"
    else
      git clone "$REPO_URL_HTTPS" "$REPO_DIR"
    fi
  fi
  ROOT="$REPO_DIR"
fi
cd "$ROOT"
chmod +x "$ROOT/setup.sh" "$ROOT/deploy.sh" "$ROOT/scripts/"*.sh 2>/dev/null || true

# ---------------------------------------------------------------------------
# SSH helpers
# ---------------------------------------------------------------------------
paste_multiline() {
  # Read until a line that is exactly END (or EOF / empty line after content)
  local line buf=""
  while IFS= read -r line || [ -n "$line" ]; do
    if [ "$line" = "END" ] || [ "$line" = "----END----" ]; then
      break
    fi
    buf+="$line"$'\n'
  done
  printf '%s' "$buf"
}

write_key_file() {
  local dest="$1" content="$2"
  mkdir -p "$(dirname "$dest")"
  # normalize trailing newline
  printf '%s\n' "${content%"${content##*[![:space:]]}"}" >"$dest"
  chmod 600 "$dest"
  echo "wrote $dest (mode 600)"
}

ssh_paste_private_key() {
  local name dest
  echo
  echo "Key file name under ~/.ssh/ (e.g. id_ed25519, id_github, oci.key)"
  read -r -p "name [id_ed25519]: " name
  name="${name:-id_ed25519}"
  dest="$HOME/.ssh/$name"

  if [ -e "$dest" ] && [ "$ASSUME_YES" -ne 1 ]; then
    read -r -p "$dest exists. overwrite? [y/N] " ans
    case "$ans" in y | Y) ;; *) echo "skipped"; return 0 ;; esac
  fi

  echo
  echo "Paste the PRIVATE key now (including -----BEGIN ...----- lines)."
  echo "When finished, type END on its own line and press Enter."
  echo "----"
  local content
  content="$(paste_multiline)"
  if [ -z "${content//[[:space:]]/}" ]; then
    echo "empty paste — aborted" >&2
    return 1
  fi
  if ! printf '%s' "$content" | grep -q "BEGIN.*PRIVATE KEY"; then
    echo "warning: content does not look like a private key" >&2
    if [ "$ASSUME_YES" -ne 1 ]; then
      read -r -p "save anyway? [y/N] " ans
      case "$ans" in y | Y) ;; *) echo "aborted"; return 1 ;; esac
    fi
  fi
  write_key_file "$dest" "$content"

  # Optional matching public key
  if [ "$ASSUME_YES" -ne 1 ]; then
    read -r -p "Also paste a public key (.pub)? [y/N] " ans
    case "$ans" in
      y | Y)
        echo "Paste public key line(s), then END:"
        local pub
        pub="$(paste_multiline)"
        if [ -n "${pub//[[:space:]]/}" ]; then
          write_key_file "${dest}.pub" "$pub"
          chmod 644 "${dest}.pub"
        fi
        ;;
    esac
  fi

  # ssh-add if agent available
  if command -v ssh-add >/dev/null 2>&1; then
    ssh-add "$dest" 2>/dev/null || true
  fi
}

ssh_generate_key() {
  local name comment dest
  read -r -p "key name [id_ed25519]: " name
  name="${name:-id_ed25519}"
  dest="$HOME/.ssh/$name"
  read -r -p "comment (email) [$(whoami)@$(hostname)]: " comment
  comment="${comment:-$(whoami)@$(hostname)}"
  if [ -e "$dest" ]; then
    echo "$dest already exists — not overwriting" >&2
    return 1
  fi
  ssh-keygen -t ed25519 -f "$dest" -C "$comment"
  echo "public key:"
  cat "${dest}.pub"
  if command -v ssh-add >/dev/null 2>&1; then
    ssh-add "$dest" 2>/dev/null || true
  fi
}

ssh_import_file() {
  local src dest name
  read -r -p "path to existing private key: " src
  src="${src/#\~/$HOME}"
  if [ ! -f "$src" ]; then
    echo "not found: $src" >&2
    return 1
  fi
  read -r -p "install as ~/.ssh/ name [$(basename "$src")]: " name
  name="${name:-$(basename "$src")}"
  dest="$HOME/.ssh/$name"
  install -m 600 "$src" "$dest"
  echo "installed $dest"
  if [ -f "${src}.pub" ]; then
    install -m 644 "${src}.pub" "${dest}.pub"
  fi
}

setup_ssh_interactive() {
  mkdir -p "$HOME/.ssh"
  chmod 700 "$HOME/.ssh"

  # Always deploy multi-account GitHub Host aliases from repo
  if [ -f "$ROOT/ssh_config" ]; then
    cp "$ROOT/ssh_config" "$HOME/.ssh/config"
    chmod 600 "$HOME/.ssh/config"
    echo "installed ~/.ssh/config (GitHub multi-account Host aliases)"
  fi

  # Ensure per-account keys exist (empty passphrase for workstation convenience)
  if [ -x "$ROOT/scripts/ssh-github.sh" ]; then
    bash "$ROOT/scripts/ssh-github.sh" gen maruchandev >/dev/null 2>&1 || true
    bash "$ROOT/scripts/ssh-github.sh" gen mt472562 >/dev/null 2>&1 || true
  fi

  while true; do
    echo
    echo "=== SSH key setup ==="
    echo "  1) Skip / done"
    echo "  2) Paste private key (clipboard → file)"
    echo "  3) Generate new ed25519 key"
    echo "  4) Import key from file path"
    echo "  5) Show public keys"
    echo "  6) GitHub multi-account status (ssh -T per Host)"
    echo "  7) Print GitHub pubkeys to register"
    if [ "$ASSUME_YES" -eq 1 ]; then
      echo "(--yes: skipping SSH interactive)"
      break
    fi
    read -r -p "choice [1]: " choice
    choice="${choice:-1}"
    case "$choice" in
      1) break ;;
      2) ssh_paste_private_key || true ;;
      3) ssh_generate_key || true ;;
      4) ssh_import_file || true ;;
      5)
        echo "--- ~/.ssh/*.pub ---"
        ls -1 "$HOME"/.ssh/*.pub 2>/dev/null || echo "(none)"
        for p in "$HOME"/.ssh/*.pub; do
          [ -f "$p" ] || continue
          echo
          echo "# $p"
          cat "$p"
        done
        ;;
      6)
        bash "$ROOT/scripts/ssh-github.sh" status || true
        ;;
      7)
        echo "=== maruchandev (register on that account) ==="
        bash "$ROOT/scripts/ssh-github.sh" pubkey maruchandev || true
        echo "=== mt472562 (register on that account) ==="
        bash "$ROOT/scripts/ssh-github.sh" pubkey mt472562 || true
        echo
        echo "Open: https://github.com/settings/keys  (switch account as needed)"
        ;;
      *) echo "invalid" ;;
    esac
  done
}

# ---------------------------------------------------------------------------
# Packages / toolchains
# ---------------------------------------------------------------------------
install_packages() {
  echo "=== packages ==="
  if command -v apt-get >/dev/null 2>&1; then
    sudo apt-get update -y
    sudo apt-get install -y \
      curl git tmux eza ripgrep fd-find xclip wl-clipboard \
      build-essential unzip 2>/dev/null || \
      sudo apt-get install -y curl git tmux eza build-essential
  fi

  # NVM
  if [ ! -d "$HOME/.nvm" ]; then
    echo "--- nvm ---"
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
  fi
  # shellcheck disable=SC1091
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
  if command -v nvm >/dev/null 2>&1; then
    nvm install --lts >/dev/null
  fi

  # Rust
  if ! command -v rustup >/dev/null 2>&1 && [ ! -f "$HOME/.cargo/bin/rustup" ]; then
    echo "--- rustup ---"
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
  fi
  # shellcheck disable=SC1091
  [ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"

  # Starship
  if ! command -v starship >/dev/null 2>&1; then
    echo "--- starship ---"
    curl -sS https://starship.rs/install.sh | sh -s -- -y
  fi

  # GitHub CLI (prefer for all GitHub auth / push / clone)
  install_gh

  # Neovim (official appimage fallback if missing)
  if ! command -v nvim >/dev/null 2>&1; then
    echo "--- neovim ---"
    if command -v apt-get >/dev/null 2>&1; then
      sudo apt-get install -y neovim || true
    fi
    if ! command -v nvim >/dev/null 2>&1; then
      echo "nvim not found after apt; install manually: https://github.com/neovim/neovim/releases"
    fi
  fi

  # Tmux plugin manager
  if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
    echo "--- tpm ---"
    git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
  fi

  echo "Font (optional): PlemolJP Console NF — https://github.com/yuru7/PlemolJP/releases"
}

install_gh() {
  if command -v gh >/dev/null 2>&1; then
    echo "--- gh already installed: $(gh --version | head -1) ---"
  else
    echo "--- gh (GitHub CLI) ---"
    mkdir -p "$HOME/.local/bin"
    local ver arch gh_arch url tmp
    arch="$(uname -m)"
    case "$arch" in
      x86_64) gh_arch=amd64 ;;
      aarch64 | arm64) gh_arch=arm64 ;;
      *) echo "unsupported arch for gh: $arch" >&2; return 0 ;;
    esac
    ver="$(curl -fsSL https://api.github.com/repos/cli/cli/releases/latest | sed -n 's/.*"tag_name": "\(v[^"]*\)".*/\1/p' | head -1)"
    if [ -z "$ver" ]; then
      echo "could not resolve gh version" >&2
      return 0
    fi
    url="https://github.com/cli/cli/releases/download/${ver}/gh_${ver#v}_linux_${gh_arch}.tar.gz"
    tmp="$(mktemp -d)"
    curl -fsSL "$url" -o "$tmp/gh.tgz"
    tar -xzf "$tmp/gh.tgz" -C "$tmp"
    install -m 755 "$tmp/gh_${ver#v}_linux_${gh_arch}/bin/gh" "$HOME/.local/bin/gh"
    rm -rf "$tmp"
    export PATH="$HOME/.local/bin:$PATH"
    echo "installed $HOME/.local/bin/gh"
  fi

  # One-time login if missing (interactive machines only)
  if ! gh auth status >/dev/null 2>&1; then
    if [ "$ASSUME_YES" -eq 1 ] || [ ! -t 0 ]; then
      echo "gh not logged in. Later: gh auth login && gh auth setup-git"
    else
      echo
      echo "=== GitHub CLI login (recommended) ==="
      echo "  GitHub.com → HTTPS → Login with a web browser"
      echo "  This makes git push/pull/clone Just Work."
      read -r -p "Run gh auth login now? [Y/n] " ans
      case "${ans:-Y}" in
        n | N) echo "skip; run later: gh auth login" ;;
        *)
          gh auth login
          gh auth setup-git
          ;;
      esac
    fi
  else
    gh auth setup-git 2>/dev/null || true
  fi
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
if [ "$SSH_ONLY" -eq 1 ]; then
  setup_ssh_interactive
  exit 0
fi

if [ "$DEPLOY_ONLY" -eq 0 ]; then
  install_packages
fi

bash "$ROOT/deploy.sh"

if [ "$DO_SSH" -eq 1 ] && [ "$DEPLOY_ONLY" -eq 0 ]; then
  setup_ssh_interactive
fi

echo
echo "=== setup complete ==="
echo "  bash configs : ~/.bashrc + ~/.bashrc.d/"
echo "  neovim       : ~/.config/nvim  (first launch installs plugins)"
echo "  tmux         : ~/.tmux.conf"
echo "  ssh          : ~/.ssh/config (+ keys you installed)"
echo
echo "Re-run anytime:"
echo "  $ROOT/setup.sh --deploy-only"
echo "  $ROOT/setup.sh --ssh-paste"
