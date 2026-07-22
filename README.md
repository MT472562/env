# env

個人用ドットファイル。端末差分はモジュール単位で持ち、`setup.sh` / `deploy.sh` で展開する。

## GitHub = SSH 複数アカウント（Host 別名）

アカウントごとに **鍵を分け**、`~/.ssh/config` の **Host 別名**で取り違えを防ぐ。

| アカウント | Host 別名 | 鍵 |
|---|---|---|
| maruchandev | `github.com-maruchandev` | `~/.ssh/id_maruchan` |
| MT472562 | `github.com-mt472562` | `~/.ssh/id_mt472562` |

```bash
# 状態確認（誰として認証されるか）
bash scripts/ssh-github.sh status

# 公開鍵を各アカウントに登録（Settings → SSH and GPG keys）
bash scripts/ssh-github.sh pubkey maruchandev
bash scripts/ssh-github.sh pubkey mt472562
# → https://github.com/settings/keys

# clone（URL の Host がアカウントを決める）
git clone git@github.com-maruchandev:maruchandev/env.git
git clone git@github.com-mt472562:MT472562/env.git

# この repo の origin 付け替え
bash scripts/ssh-github.sh remote maruchandev maruchandev/env
bash scripts/ssh-github.sh remote mt472562 MT472562/env

# publish / push
bash scripts/ssh-publish.sh maruchandev maruchandev/env
```

**ルール:** remote に素の `git@github.com:...` を書かない。必ず `github.com-<account>` を使う。

LAN / OCI など **サーバ用鍵**は `setup.sh --ssh-paste`。  
`gh` は PR/issue 用の補助（`scripts/gh-publish.sh`）として残してある。

## クイックセットアップ

```bash
git clone git@github.com-maruchandev:maruchandev/env.git ~/env
cd ~/env && bash setup.sh
```

### よく使うオプション

| コマンド | 意味 |
|---|---|
| `bash setup.sh` | パッケージ + 設定 + SSH 対話 |
| `bash setup.sh --deploy-only` | 設定ファイルだけ反映 |
| `bash setup.sh --ssh-paste` | 鍵ペースト / 生成 / multi-account 確認 |
| `bash setup.sh --no-ssh` | SSH 対話をスキップ |
| `bash setup.sh --yes` | 非対話 |
| `bash deploy.sh` | 設定の再適用のみ |
| `bash scripts/ssh-github.sh status` | アカウント別 `ssh -T` |
| `bash scripts/ssh-publish.sh …` | SSH で origin 設定 + push |

### サーバ用 SSH 鍵（GitHub 以外）

```bash
bash setup.sh --ssh-paste
# → 2) Paste private key … 本文のあと単独行で END
```

秘密鍵は **リポジトリに含めない**。`ssh_config` の Host 定義だけ共有する。

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
- **素の `github.com` に全アカウントの鍵を載せる** … Host 別名で分離

## 更新フロー

```bash
rsync -a ~/.config/nvim/ ~/env/nvim/
rsync -a ~/.bashrc.d/ ~/env/bashrc.d/
cd ~/env && git add -A && git status
git commit -m "..." && git push
```
