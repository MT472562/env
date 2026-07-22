#!/usr/bin/env bash
# env リポジトリからマシンをセットアップする
#
# 使い方:
#   bash setup.sh                  # フルセットアップ（パッケージ + 設定 + gh + サーバ鍵）
#   bash setup.sh --deploy-only    # 設定ファイルだけ反映
#   bash setup.sh --ssh-paste      # サーバ用 SSH 鍵の貼り付けだけ
#   bash setup.sh --no-ssh         # サーバ鍵ウィザードをスキップ
#   bash setup.sh --yes            # 非対話（鍵貼り付け・gh ログインをスキップ）
#
# 方針:
#   - GitHub … すべて gh（ログイン・clone・push の認証）
#   - SSH 鍵 … LAN / OCI / GCP など「GitHub 以外のサーバ」用のみ貼り付け
set -euo pipefail

# クローン先・リポジトリ（ENV_REPO=owner/name で上書き可）
ENV_REPO="${ENV_REPO:-maruchandev/env}"
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
      cat <<'EOF'
env セットアップ

  bash setup.sh                  フルセットアップ
  bash setup.sh --deploy-only    設定ファイルのみ
  bash setup.sh --ssh-paste      サーバ用 SSH 鍵の貼り付けのみ
  bash setup.sh --no-ssh         サーバ鍵ウィザードをスキップ
  bash setup.sh --yes            非対話モード

GitHub は gh に統一。SSH 鍵ペーストはサーバ（LAN/OCI 等）用のみ。
EOF
      exit 0
      ;;
  esac
done

# ---------------------------------------------------------------------------
# リポジトリの場所を決める
# ---------------------------------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$SCRIPT_DIR/deploy.sh" ] && [ -d "$SCRIPT_DIR/bashrc.d" ]; then
  ROOT="$SCRIPT_DIR"
else
  echo "--- env リポジトリを取得 → $REPO_DIR ---"
  if [ -d "$REPO_DIR/.git" ]; then
    if command -v gh >/dev/null 2>&1 && gh auth status >/dev/null 2>&1; then
      gh auth setup-git 2>/dev/null || true
    fi
    git -C "$REPO_DIR" pull --ff-only || true
  else
    if command -v gh >/dev/null 2>&1 && gh auth status >/dev/null 2>&1; then
      gh auth setup-git 2>/dev/null || true
      gh repo clone "$ENV_REPO" "$REPO_DIR"
    else
      echo "gh 未ログインのため HTTPS で clone します（後で gh auth login 推奨）"
      git clone "$REPO_URL_HTTPS" "$REPO_DIR"
    fi
  fi
  ROOT="$REPO_DIR"
fi
cd "$ROOT"
chmod +x "$ROOT/setup.sh" "$ROOT/deploy.sh" 2>/dev/null || true
chmod +x "$ROOT"/scripts/*.sh 2>/dev/null || true

# ---------------------------------------------------------------------------
# サーバ用 SSH 鍵ヘルパー（GitHub 用ではない）
# ---------------------------------------------------------------------------
paste_multiline() {
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
  printf '%s\n' "${content%"${content##*[![:space:]]}"}" >"$dest"
  chmod 600 "$dest"
  echo "保存しました: $dest （権限 600）"
}

# $1=保存先パス  $2=表示名  $3=強制上書き(0/1)
ssh_paste_into() {
  local dest="$1" label="${2:-$1}" force="${3:-0}"
  if [ -e "$dest" ] && [ "$force" -ne 1 ] && [ "$ASSUME_YES" -ne 1 ]; then
    read -r -p "$dest は既にあります。上書きしますか？ [y/N] " ans
    case "$ans" in y | Y | ｙ | Ｙ) ;; *) echo "スキップ: $label"; return 0 ;; esac
  fi

  echo
  echo ">>> 秘密鍵を貼り付けてください: $label"
  echo "    -----BEGIN ... PRIVATE KEY----- から最後まで"
  echo "    貼り終えたら、単独行で END と入力して Enter"
  echo "----"
  local content
  content="$(paste_multiline)"
  if [ -z "${content//[[:space:]]/}" ]; then
    echo "空のため中止しました（$label）" >&2
    return 1
  fi
  if ! printf '%s' "$content" | grep -q "BEGIN.*PRIVATE KEY"; then
    echo "警告: 秘密鍵の形式に見えません" >&2
    if [ "$ASSUME_YES" -ne 1 ]; then
      read -r -p "それでも保存しますか？ [y/N] " ans
      case "$ans" in y | Y | ｙ | Ｙ) ;; *) echo "中止"; return 1 ;; esac
    fi
  fi
  write_key_file "$dest" "$content"

  if command -v ssh-keygen >/dev/null 2>&1; then
    if ssh-keygen -y -f "$dest" >"${dest}.pub" 2>/dev/null; then
      chmod 644 "${dest}.pub"
      echo "公開鍵を生成しました: ${dest}.pub"
    fi
  fi

  if command -v ssh-add >/dev/null 2>&1; then
    ssh-add "$dest" 2>/dev/null || true
  fi
  return 0
}

ssh_paste_named() {
  local name dest
  echo
  echo "保存名の例: lan.key / oci.key / gcp.key / id_server"
  read -r -p "~/.ssh/ 以下のファイル名: " name
  if [ -z "$name" ]; then
    echo "名前が空です"
    return 1
  fi
  dest="$HOME/.ssh/$name"
  ssh_paste_into "$dest" "$name"
}

ssh_generate_key() {
  local name comment dest
  read -r -p "鍵の名前 [id_ed25519]: " name
  name="${name:-id_ed25519}"
  dest="$HOME/.ssh/$name"
  read -r -p "コメント（メールなど） [$(whoami)@$(hostname)]: " comment
  comment="${comment:-$(whoami)@$(hostname)}"
  if [ -e "$dest" ]; then
    echo "既に存在します（上書きしません）: $dest" >&2
    return 1
  fi
  ssh-keygen -t ed25519 -f "$dest" -C "$comment"
  echo "公開鍵:"
  cat "${dest}.pub"
  if command -v ssh-add >/dev/null 2>&1; then
    ssh-add "$dest" 2>/dev/null || true
  fi
}

ssh_import_file() {
  local src dest name
  read -r -p "既存の秘密鍵のパス: " src
  src="${src/#\~/$HOME}"
  if [ ! -f "$src" ]; then
    echo "見つかりません: $src" >&2
    return 1
  fi
  read -r -p "~/.ssh/ に付ける名前 [$(basename "$src")]: " name
  name="${name:-$(basename "$src")}"
  dest="$HOME/.ssh/$name"
  install -m 600 "$src" "$dest"
  echo "インストールしました: $dest"
  if [ -f "${src}.pub" ]; then
    install -m 644 "${src}.pub" "${dest}.pub"
  elif command -v ssh-keygen >/dev/null 2>&1; then
    ssh-keygen -y -f "$dest" >"${dest}.pub" 2>/dev/null && chmod 644 "${dest}.pub" || true
  fi
}

# よく使うサーバ鍵を順番に聞く
ssh_setup_common_server_keys() {
  local pair name path label
  # name|説明
  local -a presets=(
    "lan.key|LAN サーバ（10.10.0.*）"
    "oci.key|Oracle Cloud 等"
    "gcp.key|GCP"
  )

  echo
  echo "よく使うサーバ鍵（あるものだけ貼り付け / スキップ可）"
  for pair in "${presets[@]}"; do
    name="${pair%%|*}"
    label="${pair#*|}"
    path="$HOME/.ssh/$name"
    echo
    if [ -f "$path" ]; then
      echo "・$name （$label）… 既に存在します"
      read -r -p "  貼り付けで上書きしますか？ [y/N] " ans
      case "$ans" in y | Y | ｙ | Ｙ) ssh_paste_into "$path" "$name ($label)" 1 || true ;; *) echo "  そのまま残します" ;; esac
    else
      read -r -p "・$name （$label）を貼り付けますか？ [y/N] " ans
      case "$ans" in y | Y | ｙ | Ｙ) ssh_paste_into "$path" "$name ($label)" 1 || true ;; *) echo "  スキップ" ;; esac
    fi
  done

  echo
  read -r -p "他にもサーバ鍵を追加しますか？ [y/N] " ans
  case "$ans" in
    y | Y | ｙ | Ｙ)
      while true; do
        echo
        read -r -p "追加の鍵ファイル名（空で終了）: " name
        [ -z "$name" ] && break
        ssh_paste_into "$HOME/.ssh/$name" "$name" || true
      done
      ;;
  esac
}

setup_ssh_interactive() {
  mkdir -p "$HOME/.ssh"
  chmod 700 "$HOME/.ssh"

  # ssh_config（Host 定義のみ。秘密鍵は含めない）
  if [ -f "$ROOT/ssh_config" ]; then
    cp "$ROOT/ssh_config" "$HOME/.ssh/config"
    chmod 600 "$HOME/.ssh/config"
    echo "ssh_config を配置しました → ~/.ssh/config"
  fi

  echo
  echo "╔════════════════════════════════════════════════════════╗"
  echo "║  サーバ用 SSH 鍵（GitHub 以外）                        ║"
  echo "║  LAN / クラウド等の鍵を貼り付けます                    ║"
  echo "║  ※ GitHub の認証は gh に任せます（ここでは扱いません） ║"
  echo "╚════════════════════════════════════════════════════════╝"

  if [ "$ASSUME_YES" -eq 1 ]; then
    echo "（--yes: サーバ鍵の対話はスキップ）"
    return 0
  fi

  ssh_setup_common_server_keys

  while true; do
    echo
    echo "=== サーバ鍵（追加操作）==="
    echo "  1) 完了"
    echo "  2) 秘密鍵を貼り付け（名前を指定）"
    echo "  3) 新しい鍵を生成"
    echo "  4) ファイルから取り込み"
    echo "  5) 公開鍵一覧を表示"
    echo "  6) よく使う鍵をもう一度聞く"
    read -r -p "選択 [1]: " choice
    choice="${choice:-1}"
    case "$choice" in
      1) break ;;
      2) ssh_paste_named || true ;;
      3) ssh_generate_key || true ;;
      4) ssh_import_file || true ;;
      5)
        shopt -s nullglob
        local pubs=( "$HOME"/.ssh/*.pub )
        if [ ${#pubs[@]} -eq 0 ]; then
          echo "（公開鍵なし）"
        else
          for p in "${pubs[@]}"; do
            echo
            echo "# $p"
            cat "$p"
          done
        fi
        shopt -u nullglob
        ;;
      6) ssh_setup_common_server_keys ;;
      *) echo "無効な選択です" ;;
    esac
  done

  echo
  echo "=== サーバ鍵の配置状況 ==="
  ls -la "$HOME"/.ssh/*.key "$HOME"/.ssh/id_* 2>/dev/null || echo "（鍵ファイルなし）"
  echo
  echo "GitHub の操作は:  gh auth status / gh repo clone / git push"
  echo "サーバ鍵のやり直し:  bash $ROOT/setup.sh --ssh-paste"
}

# ---------------------------------------------------------------------------
# パッケージ / ツールチェーン
# ---------------------------------------------------------------------------
install_packages() {
  echo "=== パッケージ ==="
  if command -v apt-get >/dev/null 2>&1; then
    sudo apt-get update -y
    sudo apt-get install -y \
      curl git tmux eza ripgrep fd-find xclip wl-clipboard \
      build-essential unzip 2>/dev/null || \
      sudo apt-get install -y curl git tmux eza build-essential
  fi

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

  if ! command -v rustup >/dev/null 2>&1 && [ ! -f "$HOME/.cargo/bin/rustup" ]; then
    echo "--- rustup ---"
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
  fi
  # shellcheck disable=SC1091
  [ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"

  if ! command -v starship >/dev/null 2>&1; then
    echo "--- starship ---"
    curl -sS https://starship.rs/install.sh | sh -s -- -y
  fi

  # GitHub は gh に統一
  install_gh

  if ! command -v nvim >/dev/null 2>&1; then
    echo "--- neovim ---"
    if command -v apt-get >/dev/null 2>&1; then
      sudo apt-get install -y neovim || true
    fi
    if ! command -v nvim >/dev/null 2>&1; then
      echo "nvim が見つかりません。手動インストール: https://github.com/neovim/neovim/releases"
    fi
  fi

  if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
    echo "--- tmux プラグインマネージャ (tpm) ---"
    git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
  fi

  echo "フォント（任意）: PlemolJP Console NF — https://github.com/yuru7/PlemolJP/releases"
}

install_gh() {
  export PATH="$HOME/.local/bin:$PATH"

  if command -v gh >/dev/null 2>&1; then
    echo "--- gh はインストール済み: $(gh --version | head -1) ---"
  else
    echo "--- GitHub CLI (gh) をインストール ---"
    mkdir -p "$HOME/.local/bin"
    local ver arch gh_arch url tmp
    arch="$(uname -m)"
    case "$arch" in
      x86_64) gh_arch=amd64 ;;
      aarch64 | arm64) gh_arch=arm64 ;;
      *)
        echo "未対応のアーキテクチャ: $arch" >&2
        return 0
        ;;
    esac
    ver="$(curl -fsSL https://api.github.com/repos/cli/cli/releases/latest | sed -n 's/.*"tag_name": "\(v[^"]*\)".*/\1/p' | head -1)"
    if [ -z "$ver" ]; then
      echo "gh のバージョン取得に失敗しました" >&2
      return 0
    fi
    url="https://github.com/cli/cli/releases/download/${ver}/gh_${ver#v}_linux_${gh_arch}.tar.gz"
    tmp="$(mktemp -d)"
    curl -fsSL "$url" -o "$tmp/gh.tgz"
    tar -xzf "$tmp/gh.tgz" -C "$tmp"
    install -m 755 "$tmp/gh_${ver#v}_linux_${gh_arch}/bin/gh" "$HOME/.local/bin/gh"
    rm -rf "$tmp"
    export PATH="$HOME/.local/bin:$PATH"
    echo "インストール完了: $HOME/.local/bin/gh"
  fi

  # GitHub 認証は gh が担当（必須に近い）
  if gh auth status >/dev/null 2>&1; then
    echo "gh: ログイン済み"
    gh auth setup-git 2>/dev/null || true
    gh auth status 2>&1 | head -20 || true
    return 0
  fi

  if [ "$ASSUME_YES" -eq 1 ] || [ ! -t 0 ]; then
    echo "gh 未ログインです。後で実行してください:"
    echo "  gh auth login"
    echo "  gh auth setup-git"
    return 0
  fi

  echo
  echo "╔════════════════════════════════════════════════════════╗"
  echo "║  GitHub 認証（gh に統一）                              ║"
  echo "║  推奨: GitHub.com → HTTPS → ブラウザでログイン         ║"
  echo "║  複数アカウントは: gh auth login を追加 → gh auth switch║"
  echo "╚════════════════════════════════════════════════════════╝"
  read -r -p "いま gh auth login を実行しますか？ [Y/n] " ans
  case "${ans:-Y}" in
    n | N | ｎ | Ｎ)
      echo "スキップ。後で: gh auth login && gh auth setup-git"
      ;;
    *)
      gh auth login
      gh auth setup-git
      echo
      echo "ログイン状態:"
      gh auth status 2>&1 || true
      ;;
  esac
}

# ---------------------------------------------------------------------------
# メイン
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
echo "=== セットアップ完了 ==="
echo "  bash     : ~/.bashrc + ~/.bashrc.d/"
echo "  neovim   : ~/.config/nvim （初回起動でプラグイン導入）"
echo "  tmux     : ~/.tmux.conf"
echo "  GitHub   : gh auth status で確認"
echo "  サーバ鍵 : ~/.ssh/ （LAN / クラウド用）"
echo
echo "いつでも再実行:"
echo "  $ROOT/setup.sh --deploy-only   # 設定だけ"
echo "  $ROOT/setup.sh --ssh-paste     # サーバ鍵の貼り付け"
echo "  gh auth status                 # GitHub ログイン確認"
echo "  gh auth switch                 # アカウント切替"
echo "  bash $ROOT/scripts/gh-publish.sh   # この repo を gh で push"
