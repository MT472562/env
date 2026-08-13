# env

個人用ドットファイル。端末差分はモジュール単位で持ち、`setup.sh` / `deploy.sh` で展開する。

## 役割分担

| 用途 | 手段 |
|---|---|
| **GitHub**（clone / push / PR / 複数アカウント） | **`gh` に統一** |
| **サーバ**（LAN / OCI / GCP 等） | **SSH 鍵の貼り付け**（`setup.sh`） |
| **対話シェル** | **bash**（`~/.bashrc` + `~/.bashrc.d/`） |

```bash
# GitHub
gh auth login              # ブラウザでログイン（HTTPS 推奨）
gh auth setup-git          # git の認証を gh に接続
gh auth status
gh auth switch             # 複数アカウント切替
gh repo clone owner/env ~/env
bash scripts/gh-publish.sh # この repo を create + push

# サーバ用 SSH 鍵だけやり直す
bash setup.sh --ssh-paste
# → lan.key / oci.key / gcp.key などを貼り付け（単独行 END で確定）
```

## クイックセットアップ

```bash
# gh ログイン済みなら
gh repo clone MT472562/env ~/env
cd ~/env && bash setup.sh

# または
bash <(curl -fsSL https://raw.githubusercontent.com/MT472562/env/main/setup.sh)
```

`setup.sh` の流れ（日本語プロンプト）:

1. 環境プロファイルを選択（実行環境から推奨値を自動判定）
2. パッケージ導入 + **gh インストール / ログイン**
3. `deploy.sh` で設定配置
4. **サーバ用 SSH 鍵**の貼り付け（GitHub 鍵は聞かない）

通常は表示された推奨プロファイルで Enter を押せばよい。自動構築では
`--profile` を明示するか、`--yes` で実行環境から自動決定する。

### よく使うオプション

| コマンド | 意味 |
|---|---|
| `bash setup.sh` | パッケージ + gh + 設定 + サーバ鍵 |
| `bash setup.sh --deploy-only` | 設定ファイルだけ |
| `bash setup.sh --ssh-paste` | サーバ鍵の貼り付けのみ |
| `bash setup.sh --no-ssh` | サーバ鍵ウィザードをスキップ |
| `bash setup.sh --yes` | 非対話 |
| `bash setup.sh --profile wsl` | Windows上のWSL向け |
| `bash setup.sh --profile macos` | macOS向け（Homebrewが必要） |
| `bash setup.sh --profile linux-desktop` | GUI付きLinux向け |
| `bash setup.sh --profile linux-server` | SSH中心のLinuxサーバー向け |
| `bash deploy.sh` | 設定の再適用のみ |
| `bash scripts/gh-publish.sh` | gh で remote 作成 + push |

秘密鍵は **リポジトリに含めない**。`ssh_config` には Host / IdentityFile のパスだけ。

### SSH切断・端末固有設定

`deploy.sh` は管理設定を `~/.ssh/config.d/00-env.conf` に配置し、既存の
`~/.ssh/config` の末尾へ `Include` を一度だけ追加する。既存設定を上書きしないため、
WSLを主環境にしつつ、macOSやネイティブLinuxでは同じリポジトリをそのまま使える。

共通設定では15秒ごとにサーバ応答を確認し、3回失敗（約45秒）で切断する。
Wi-Fi断やスリープ後にSSHクライアントが固まったように残る状態を防ぐ。

```sshconfig
# ~/.ssh/config（端末固有値は管理設定より先に評価され、こちらが優先）
Host slow-vpn
  ServerAliveInterval 30
  ServerAliveCountMax 6

# deploy.sh が末尾に自動追加
Match all
Include ~/.ssh/config.d/00-env.conf
```

接続先で `tmux` を使っていれば、SSH切断後も作業セッションはサーバ側に残り、
再接続時に `default` セッションへ自動復帰する。緊急切断は改行後に `~.`。

## 構成

### ルート

| パス | 説明 |
|---|---|
| `.bashrc` | 対話シェル判定 + `bashrc.d/*.sh` を source |
| `.profile` | ログインシェル / user bin PATH |
| `.tmux.conf` | `tmux/` モジュールを source-file |
| `nvim/` | Neovim 設定一式 → `deploy` で `~/.config/nvim` に配置 |
| `ssh_config` | → `~/.ssh/config.d/00-env.conf`（keepalive + サーバ用 Host） |
| `scripts/gh-publish.sh` | gh で create + push |
| `starship.toml` | Starship |
| `setup.sh` | 初回ブートストラップ |
| `deploy.sh` | 設定の再適用 |

### bashrc.d/

| ファイル | 内容 |
|---|---|
| `00-base.sh` | 履歴・shopt・`prepend_path`・**WSL で Windows PATH 除外** |
| `01-terminal.sh` | **端末依存の一元管理**（truecolor / Wayland / Nerd Font → `_TERM_*`） |
| `10-aliases.sh` | eza / ls / grep（アイコンは `_TERM_NF` 依存） |
| `20-functions.sh` | `cd` 自動 ls、`tmpl` |
| `30-completion.sh` | bash-completion（候補生成のみ。キー操作は `55-ble.sh`） |
| `31-fzf.sh` | fzf 環境変数（`fdfind` 優先・検索コマンド・プレビュー） |
| `32-tool-completions.sh` | gh / rustup / npm 等（**キャッシュ付き** → `~/.cache/bash-completions/`） |
| `40-nvm.sh` | NVM（**遅延ロード**。default node の bin だけ即 PATH） |
| `50-starship.sh` | Starship |
| `55-ble.sh` | **ble.sh**（構文ハイライト / fzf 統合。自動補完はオフ） |
| `56-ble-theme.sh` | ble.sh を TokyoNight 配色（`_TERM_TRUECOLOR` で #RRGGBB / 256 色切替） |
| `60-cargo.sh` | cargo / go PATH（存在時のみ） |
| `70-opencode.sh` | opencode PATH |
| `71-gh.sh` | gh PATH |
| `72-editor.sh` | `vim` → nvim、EDITOR |
| `73-grok.sh` | Grok CLI PATH / completion |
| `75-atcoder.sh` | AtCoder 用 BROWSER / `ae` |
| `80-local.sh` | `~/.bashrc.local` |
| `90-tmux.sh` | default セッションへ auto-attach |

**bash 補完の使い方（ble.sh 有効時）**

自動サジェスト / 自動メニューは **無効**（WSL で遅延が酷かったため削除済み）。

| 操作 | 動作 |
|------|------|
| `Tab` | 通常の bash 補完（プログラマブル補完） |
| `↑` / `↓` | 今の入力に前方一致する履歴 |
| `Ctrl-R` | fzf で履歴あいまい検索 |
| `Ctrl-T` | fzf でファイル挿入 |
| `Alt-C` | fzf でディレクトリへ cd |
| `cd **` + `Tab` | あいまいパス補完 |

### 補完・起動が重いとき（WSL 対策）

対話シェル起動が ~1s あった主因は次の3つだった（対策済み）:

1. **Windows PATH の丸ごと注入**（`/mnt/c/...` が 50 超）→ 存在しないコマンドの探索のたびに 9p を舐める
2. **毎回 `npm completion` / `pip completion` 等を eval**（数百 ms）
3. **nvm.sh のフルロード**（~400 ms）

無効化・オプトアウト:

```bash
# tmux 自動 attach を止める
touch ~/.no_tmux_auto   # または export NO_TMUX_AUTO=1

# ble.sh を止める（readline に戻る）
touch ~/.no_ble         # または export NO_BLE=1

# Windows PATH を残したい（code.exe 等を PATH から使いたい場合）
touch ~/.keep_win_path  # または export KEEP_WIN_PATH=1

# nvm を起動時にフルロードしたい
touch ~/.nvm_eager      # または export NVM_EAGER=1
```

補完キャッシュを消して再生成:

```bash
rm -rf ~/.cache/bash-completions
# 次の対話シェル起動時に作り直される
```

恒久的に Windows PATH を付けない（要 WSL 再起動）:

```ini
# /etc/wsl.conf
[interop]
appendWindowsPath = false
```

自動補完を戻したい場合は `~/.bashrc.local` で（非推奨・重い）:

```bash
bleopt complete_auto_complete=1
bleopt complete_auto_history=1
bleopt complete_auto_delay=100
# 自動メニューまで戻すなら:
# bleopt complete_auto_menu=500
# bleopt complete_menu_complete=1
# bleopt complete_menu_style=dense
```

端末固有の追加は `~/.bashrc.local` へ。
**端末ごとの上書き（truecolor / Nerd Font など）は `~/.bashrc.terminal`** へ（`01-terminal.sh` が source）:

```bash
# ~/.bashrc.terminal の例
_TERM_NF=0        # Nerd Font 非対応端末 → eza のアイコン無効
_TERM_TRUECOLOR=1 # 強制的に truecolor
BROWSER=firefox
```

### ble.sh（fish 風ラインエディタ）

`setup.sh` が `~/.local/share/blesh` に clone + ビルドし、`55-ble.sh` が読み込む。
readline を置き換え、**構文ハイライト**を bash で提供する（自動補完はオフ）。
fzf の統合は `blesh-contrib` の `integration/fzf-*` 経由（fzf>=0.48 なら `eval "$(fzf --bash)"` を使用）。
ble.sh が無い環境では `31-fzf.sh` の環境変数 + フォールバックで fzf のキーバインドを維持する。

### nvim/

Vim / coc.nvim は使わない。設定はすべて Neovim:

```
nvim/
  init.lua
  lua/config/{options,keymaps,autocmds}.lua
  lua/plugins/{ui,editor,lsp,completion,treesitter,writing}.lua
  KEYMAPS.md
```

### tmux/

| ファイル | 内容 |
|---|---|
| `00-base.conf` | mouse / 端末（truecolor `Tc`） |
| `10-theme.conf` | Tokyo Night 風 status |
| `20-keybinds.conf` | ペイン操作 |
| `30-plugins.conf` | tpm |
| `40-copy-paste-wayland.conf` | wl-clipboard（Wayland 時） |
| `41-copy-paste-x11.conf` | xclip（X11 時） |
| `42-copy-paste-macos.conf` | pbcopy / pbpaste（macOS） |

`.tmux.conf` の `if-shell` がOSと `WAYLAND_DISPLAY` を見て自動選択する（`paste.sh` もランタイム検出）。

### aerc

`aerc/accounts.conf` は **gitignore**（アプリパスワード等）。  
雛形は `aerc/accounts.conf.example`。

## 整理済みの無駄

- **`.vimrc` / vim-plug / coc** … Neovim へ移行済みのため削除
- **モノリシック `nvim/init.lua`** … `lua/` 分割構成に置換
- **WSL 固定** (`BROWSER=wslview` / docker `ae`) … ネイティブ Linux 向けに修正
- **`settings.json`（Windows Terminal）** … WSL 時代の残骸のため削除
- **`alacritty.toml`** … 未デプロイ・未導入だったため削除
- **fish / `scripts/fish-try`** … 対話シェルは bash に一本化
- **`iperf-test.sh` / `netcheck.sh`** … env 不適のネット診断脚本のため削除
- **`scripts/ssh-github.sh` / `scripts/ssh-publish.sh`** … 旧 SSH 方式。`gh` に一本化
- **`.bashrc` への grok 直書き** … `73-grok.sh` モジュール化
- **PATH 前置の `case ":$PATH:"` ボイラープレート** … `00-base.sh` の `prepend_path` に集約
- **手書き readline `bind`（menu-complete / history-search 等）** … `30-completion.sh` から除去し ble.sh に集約
- **fzf キーバインドの二重管理** … ble.sh 有無で `55-ble.sh` に集約（`31-fzf.sh` は環境変数のみ）
- **cargo PATH の三重管理**（`.profile` / `60-cargo.sh` / `cargo_env`） … `60-cargo.sh` に一本化、`cargo_env` 廃止
- **setup / deploy の二重コピー** … deploy に集約
- **非対話シェルでもモジュール全部 source** … `.bashrc` 先頭で interactive 判定
- **aerc 平文パスワードをリポジトリ管理** … example + gitignore
- **GitHub を SSH 鍵で複数アカウント管理** … `gh auth login` / `switch` に統一

## 更新フロー

```bash
rsync -a ~/.config/nvim/ ~/env/nvim/
rsync -a ~/.bashrc.d/ ~/env/bashrc.d/
cd ~/env && git add -A && git status
git commit -m "..." && git push
```
