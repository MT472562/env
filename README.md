# env

個人用ドットファイル。端末差分はモジュール単位で持ち、`setup.sh` / `deploy.sh` で展開する。

## 役割分担

| 用途 | 手段 |
|---|---|
| **GitHub**（clone / push / PR / 複数アカウント） | **`gh` に統一** |
| **サーバ**（LAN / OCI / GCP 等） | **SSH 鍵の貼り付け**（`setup.sh`） |
| **対話シェル** | デフォルト **bash**。**fish は任意**（`fish` で起動、`exit` で戻る） |

### fish を試す

```bash
# 入っていれば
fish

# このマシンでは ~/.local/bin/fish（sudo 不要で入れた場合）
# 設定: env/fish/config.fish → ~/.config/fish/config.fish
# bash に戻る: exit
# ログインシェルは変えないのが安全（変えるなら chsh の前に十分試す）
```

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
gh repo clone maruchandev/env ~/env
cd ~/env && bash setup.sh

# または
bash <(curl -fsSL https://raw.githubusercontent.com/maruchandev/env/main/setup.sh)
```

`setup.sh` の流れ（日本語プロンプト）:

1. パッケージ導入 + **gh インストール / ログイン**
2. `deploy.sh` で設定配置
3. **サーバ用 SSH 鍵**の貼り付け（GitHub 鍵は聞かない）

### よく使うオプション

| コマンド | 意味 |
|---|---|
| `bash setup.sh` | パッケージ + gh + 設定 + サーバ鍵 |
| `bash setup.sh --deploy-only` | 設定ファイルだけ |
| `bash setup.sh --ssh-paste` | サーバ鍵の貼り付けのみ |
| `bash setup.sh --no-ssh` | サーバ鍵ウィザードをスキップ |
| `bash setup.sh --yes` | 非対話 |
| `bash deploy.sh` | 設定の再適用のみ |
| `bash scripts/gh-publish.sh` | gh で remote 作成 + push |

秘密鍵は **リポジトリに含めない**。`ssh_config` には Host / IdentityFile のパスだけ。

## 構成

### ルート

| パス | 説明 |
|---|---|
| `.bashrc` | 対話シェル判定 + `bashrc.d/*.sh` を source |
| `.profile` | ログインシェル / PATH / cargo |
| `.tmux.conf` | `tmux/` モジュールを source-file |
| `nvim/` | Neovim 設定一式 → `deploy` で `~/.config/nvim` に配置 |
| `ssh_config` | → `~/.ssh/config`（サーバ用 Host のみ） |
| `scripts/gh-publish.sh` | gh で create + push |
| `starship.toml` | Starship |
| `setup.sh` | 初回ブートストラップ |
| `deploy.sh` | 設定の再適用 |

### bashrc.d/

| ファイル | 内容 |
|---|---|
| `00-base.sh` | 履歴・shopt・truecolor |
| `10-aliases.sh` | eza / ls / grep |
| `20-functions.sh` | `cd` 自動 ls、`tmpl` |
| `30-completion.sh` | bash-completion |
| `40-nvm.sh` | NVM（あれば） |
| `50-starship.sh` | Starship |
| `60-cargo.sh` | cargo / go PATH（存在時のみ） |
| `70-opencode.sh` | opencode PATH |
| `71-gh.sh` | gh PATH / completion（任意） |
| `72-editor.sh` | `vim` → nvim、EDITOR |
| `73-grok.sh` | Grok CLI PATH / completion |
| `75-atcoder.sh` | AtCoder 用 BROWSER / `ae` |
| `80-local.sh` | `~/.bashrc.local` |
| `90-tmux.sh` | default セッションへ auto-attach |

無効化例:

```bash
touch ~/.no_tmux_auto
# または
export NO_TMUX_AUTO=1
```

端末固有の追加は `~/.bashrc.local` へ。

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
| `00-base.conf` | mouse / 端末 |
| `10-theme.conf` | Tokyo Night 風 status |
| `20-keybinds.conf` | ペイン操作 |
| `30-plugins.conf` | tpm |
| `40-copy-paste-wayland.conf` | wl-clipboard（Wayland 時） |

`.tmux.conf` で `source-file` のコメントを切り替えて端末差を吸収。

### aerc

`aerc/accounts.conf` は **gitignore**（アプリパスワード等）。  
雛形は `aerc/accounts.conf.example`。

## 整理済みの無駄

- **`.vimrc` / vim-plug / coc** … Neovim へ移行済みのため削除
- **モノリシック `nvim/init.lua`** … `lua/` 分割構成に置換
- **WSL 固定** (`BROWSER=wslview` / docker `ae`) … ネイティブ Linux 向けに修正
- **`.bashrc` への grok 直書き** … `73-grok.sh` モジュール化
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
