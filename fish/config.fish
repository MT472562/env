# fish 設定（対話用）。スクリプト・setup は bash のまま。
# 配置先: ~/.config/fish/config.fish

# --- PATH（login 直 fish でも最低限揃える）---
fish_add_path -g $HOME/.local/bin
fish_add_path -g $HOME/.cargo/bin
fish_add_path -g $HOME/bin
fish_add_path -g /usr/local/go/bin
fish_add_path -g $HOME/.opencode/bin
fish_add_path -g $HOME/.grok/bin

# nvm（あれば）— fish では簡易に default の node を PATH へ
if test -d $HOME/.nvm/versions/node
    set -l latest (ls -1 $HOME/.nvm/versions/node | tail -1)
    if test -n "$latest"
        fish_add_path -g $HOME/.nvm/versions/node/$latest/bin
    end
end

# --- エディタ ---
if type -q nvim
    set -gx EDITOR nvim
    set -gx VISUAL nvim
    alias vim nvim
end

# --- eza ---
if type -q eza
    alias ls 'eza --icons --git'
    alias ll 'eza -lah --icons --git'
    alias la 'eza -a --icons --git'
    alias lt 'eza --tree --icons'
end

# --- starship ---
if type -q starship
    starship init fish | source
end

# --- 便利 ---
# bash に戻る
alias bashexec 'exec bash'
# いまのシェル確認
alias whichshell 'echo $fish_pid; ps -p $fish_pid -o comm='

# 挨拶は初回だけ（うるさい場合は消してよい）
if status is-interactive
    # fish の提案・補完はそのまま活かす
    set -g fish_greeting 'fish です。bash に戻る: exit  または  bashexec'
end
