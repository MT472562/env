# env

個人用ドットファイル。端末差分はモジュール単位で持ち、`setup.sh` / `deploy.sh` で展開する。

## クイックセットアップ

```bash
# HTTPS (鍵がまだ無いマシン)
bash <(curl -fsSL https://raw.githubusercontent.com/MT472562/env/main/setup.sh)

# または clone 後
git clone git@github.com:MT472562/env.git ~/env
cd ~/env && bash setup.sh
```

### よく使うオプション

| コマンド | 意味 |
|---|---|
| `bash setup.sh` | パッケージ導入 + 設定配置 + SSH 対話 |
| `bash setup.sh --deploy-only` | 設定ファイルだけ反映 |
| `bash setup.sh --ssh-paste` | SSH 鍵の貼り付け / 生成だけ |
| `bash setup.sh --no-ssh` | SSH 対話をスキップ |
| `bash setup.sh --yes` | 非対話（SSH 貼り付けはスキップ） |
| `bash deploy.sh` | 設定の再適用のみ（install なし） |

### SSH 鍵をペーストする

```bash
bash setup.sh --ssh-paste
# → 2) Paste private key
# 鍵本文を貼り付け、最後に単独行で END
```

対応:

1. スキップ
2. **秘密鍵をペースト**して `~/.ssh/<name>` に保存（権限 600）
3. ed25519 を新規生成
4. 既存ファイルから import
5. 公開鍵一覧表示

秘密鍵は **リポジトリに含めない**。`ssh_config` のパスだけ共有する。

## 構成

### ルート

| パス | 説明 |
|---|---|
| `.bashrc` | 対話シェル判定 + `bashrc.d/*.sh` を source |
| `.profile` | ログインシェル / PATH / cargo |
| `.tmux.conf` | `tmux/` モジュールを source-file |
| `nvim/` | Neovim 設定（lazy.nvim + Lua 分割） |
| `ssh_config` | → `~/.ssh/config` |
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
