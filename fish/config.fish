# fish 対話用設定（スクリプト・setup は bash のまま）
# 配置: ~/.config/fish/config.fish
#
# 起動:
#   fish-try          # このマシン（~/.local に入れた fish + bwrap）
#   fish              # apt の fish がある場合

# --- PATH ---
fish_add_path -g $HOME/.local/bin
fish_add_path -g $HOME/.cargo/bin
fish_add_path -g $HOME/bin
fish_add_path -g /usr/local/go/bin
fish_add_path -g $HOME/.opencode/bin
fish_add_path -g $HOME/.grok/bin

if test -d $HOME/.nvm/versions/node
    set -l latest (ls -1 $HOME/.nvm/versions/node | tail -1)
    if test -n "$latest"
        fish_add_path -g $HOME/.nvm/versions/node/$latest/bin
    end
end

# --- エディタ ---
if command -q nvim
    set -gx EDITOR nvim
    set -gx VISUAL nvim
    alias vim nvim
end

# --- eza ---
if command -q eza
    alias ls 'eza --icons --git'
    alias ll 'eza -lah --icons --git'
    alias la 'eza -a --icons --git'
    alias lt 'eza --tree --icons'
end

# --- starship ---
if command -q starship
    starship init fish | source
end

# --- 便利 ---
alias bashexec 'exec bash'

if status is-interactive
    set -g fish_greeting 'fish です。bash に戻る: exit  または  bashexec'
end
