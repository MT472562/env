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

### ルート

| ファイル | 説明 |
|---|---|
| `.bashrc` | bashrc.d/*.sh を読み込むだけ |
| `.tmux.conf` | tmux/ モジュールを source-file |
| `.vimrc` | Vim: プラグイン、テーマ設定 |
| `.profile` | ログインシェル設定 |
| `cargo_env` | Rust/Cargo 環境変数（`~/.cargo/env`） |
| `ssh_config` | SSH 接続設定（`~/.ssh/config`） |
| `starship.toml` | Starship プロンプトテーマ |
| `alacritty.toml` | Alacritty 設定（参考） |
| `settings.json` | VSCode 設定（参考） |

### bashrc.d/ (bash モジュール)

| ファイル | 内容 | 有効化 |
|---|---|---|
| `00-base.sh` | 基本チェック、履歴、shopt | 常時 |
| `10-aliases.sh` | エイリアス (eza/ls, grep) | 常時 |
| `20-functions.sh` | cd() 自動ls, tmpl() | 常時 |
| `30-completion.sh` | bash-completion | 常時 |
| `40-nvm.sh` | NVM 読み込み | NVM 使用端末 |
| `50-starship.sh` | Starship プロンプト | Starship 使用端末 |
| `60-cargo.sh` | Cargo パス、Go パス | Rust/Go 使用端末 |
| `70-opencode.sh` | opencode PATH、エイリアス | 端末固有 |
| `80-local.sh` | ~/.bashrc.local があれば読む | 常時 |

不要なモジュールは削除するか、空ファイルで上書き:
```bash
# NVM 要らない場合
echo -n > ~/.bashrc.d/40-nvm.sh
```

### tmux/ (tmux モジュール)

| ファイル | 内容 | 有効化 |
|---|---|---|
| `00-base.conf` | mouse on、基本設定 | 常時 |
| `10-theme.conf` | Tokyo Night テーマ、CPU/RAM 表示 | 常時 |
| `20-keybinds.conf` | ペイン移動、リサイズ | 常時 |
| `30-plugins.conf` | tpm、tmux-sensible、tmux-cpu | 常時 |
| `40-copy-paste-wayland.conf` | wl-clipboard 連携コピペ | Wayland 端末のみ |

`.tmux.conf` でコメントアウト制御:
```tmux
source-file ~/.tmux/00-base.conf
source-file ~/.tmux/10-theme.conf
source-file ~/.tmux/20-keybinds.conf
source-file ~/.tmux/30-plugins.conf
# source-file ~/.tmux/40-copy-paste-wayland.conf  # ← Wayland端末で解除
```

## 端末ごとのカスタマイズ

tmux は `.tmux.conf` のコメントアウト、bash は `~/.bashrc.local` に書く、または `bashrc.d/` の該当ファイルを空にする、で対応します。
