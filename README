# env

設定ファイル管理リポジトリ。端末ごとの差分はモジュール単位で管理し、setup.sh でデプロイします。

## クイックセットアップ

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/MT472562/env/main/setup.sh)
```

またはクローンして実行:
```bash
git clone git@github.com:MT472562/env.git ~/env
cd ~/env && bash setup.sh
```

## 構成

| ファイル | 説明 |
|---|---|
| `.bashrc` | bash: プロンプト、エイリアス、NVM/starship 連携 |
| `.tmux.conf` | tmux: モジュールを `source-file` で読み込み |
| `.vimrc` | Vim: プラグイン、テーマ設定 |
| `.profile` | ログインシェル設定 |
| `cargo_env` | Rust/Cargo 環境変数（`~/.cargo/env`） |
| `ssh_config` | SSH 接続設定（`~/.ssh/config`） |
| `starship.toml` | Starship プロンプトテーマ |
| `alacritty.toml` | Alacritty 設定（参考） |
| `settings.json` | VSCode 設定（参考） |

### tmux モジュール (`tmux/`)

| ファイル | 内容 | 有効化 |
|---|---|---|
| `00-base.conf` | mouse on、基本設定 | 常時 |
| `10-theme.conf` | Tokyo Night テーマ、CPU/RAM 表示 | 常時 |
| `20-keybinds.conf` | ペイン移動、リサイズ | 常時 |
| `30-plugins.conf` | tpm、tmux-sensible、tmux-cpu | 常時 |
| `40-copy-paste-wayland.conf` | wl-clipboard 連携コピペ | Wayland 端末のみ |

`.tmux.conf` で不要なモジュールをコメントアウト:
```tmux
source-file ~/.tmux/00-base.conf
source-file ~/.tmux/10-theme.conf
source-file ~/.tmux/20-keybinds.conf
source-file ~/.tmux/30-plugins.conf
# source-file ~/.tmux/40-copy-paste-wayland.conf  # ← Wayland端末で解除
```

## 端末ごとのカスタマイズ

`~/.tmux.conf` のモジュールコメントアウトで対応。ブランチは切らず、単一の `main` で管理します。

tmux モジュール以外の端末固有設定（`.bashrc` の追記など）は `~/.bashrc.local` などのローカルファイルに書き、`.gitignore` で管理外とします。
