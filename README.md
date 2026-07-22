# env

個人用ドットファイル。端末差分はモジュール単位で持ち、`setup.sh` / `deploy.sh` で展開する。

## GitHub は全部 `gh` に任せる

SSH 鍵の組み合わせ・deploy key・remote URL の迷路に入らない。

```bash
# 1回だけ（ブラウザでログイン）
gh auth login          # GitHub.com → HTTPS → Login with a web browser
gh auth setup-git      # git の credential を gh に接続

# 以後
gh repo clone owner/env ~/env
cd ~/env && bash setup.sh --deploy-only

# 初回 publish / push（このリポジトリ自身）
bash scripts/gh-publish.sh              # 非公開で create + push
bash scripts/gh-publish.sh --repo maruchandev/env
```

| やりたいこと | コマンド |
|---|---|
| ログイン | `gh auth login` |
| clone | `gh repo clone owner/env` |
| push | `git push`（setup-git 済みならそのまま） |
| 新規作成して push | `bash scripts/gh-publish.sh` |
| PR / issue | `gh pr create` / `gh issue list` |
| 誰で入ってるか | `gh auth status` |

サーバ用 SSH 鍵（LAN / OCI 等）はこれまでどおり `setup.sh --ssh-paste`。  
**GitHub 用だけは `gh` に寄せる**のが幸せ。

## クイックセットアップ

```bash
# 鍵と Host 別名が済んでいるマシン
git clone git@github.com-maruchandev:maruchandev/env.git ~/env
cd ~/env && bash setup.sh

# 生の curl bootstrap（公開 repo のとき）
bash <(curl -fsSL https://raw.githubusercontent.com/maruchandev/env/main/setup.sh)
```
### よく使うオプション

| コマンド | 意味 |
|---|---|
| `bash setup.sh` | パッケージ + gh + 設定 + （任意）SSH |
| `bash setup.sh --deploy-only` | 設定ファイルだけ反映 |
| `bash setup.sh --ssh-paste` | サーバ用 SSH 鍵の貼り付け / 生成 |
| `bash setup.sh --no-ssh` | SSH 対話をスキップ |
| `bash setup.sh --yes` | 非対話（gh login / SSH 貼り付けはスキップ） |
| `bash deploy.sh` | 設定の再適用のみ |
| `bash scripts/gh-publish.sh` | `gh` で remote 作成 + push |

### サーバ用 SSH 鍵（GitHub 以外）

```bash
bash setup.sh --ssh-paste
# → 2) Paste private key … 本文のあと単独行で END
```

秘密鍵は **リポジトリに含めない**。`ssh_config` のホスト定義だけ共有する。
## 構成

### ルート

| パス | 説明 |
|---|---|
| `.bashrc` | 対話シェル判定 + `bashrc.d/*.sh` を source |
| `.profile` | ログインシェル / PATH / cargo |
| `.tmux.conf` | `tmux/` モジュールを source-file |
| `nvim/` | Neovim 設定（lazy.nvim + Lua 分割） |
| `ssh_config` | → `~/.ssh/config`（GitHub Host 別名 + LAN/cloud） |
| `scripts/ssh-github.sh` | 複数アカウント status / remote / pubkey |
| `scripts/ssh-publish.sh` | SSH で push |
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
| `72-editor.sh` | `vim` → nvim、EDITOR |
| `73-grok.sh` | Grok CLI PATH / completion |
| `75-atcoder.sh` | AtCoder 用 BROWSER / `ae` |
| `80-local.sh` | `~/.bashrc.local` |
| `90-tmux.sh` | default セッションへ auto-attach |

無効化例:

```bash
# tmux 自動起動を止める
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

## 更新フロー

```bash
# マシン上で調整したあと repo に取り込む例
rsync -a ~/.config/nvim/ ~/env/nvim/
rsync -a ~/.bashrc.d/ ~/env/bashrc.d/
cd ~/env && git add -A && git status
git commit -m "..." && git push
```
