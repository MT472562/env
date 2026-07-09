# ~/.bashrc: executed by bash(1) for non-login shells.

# ==========================================
# 1. 基本チェック
# ==========================================
case $- in
    *i*) ;;
      *) return;;
esac


# ==========================================
# 2. 履歴設定
# ==========================================
HISTCONTROL=ignoreboth
shopt -s histappend
HISTSIZE=1000
HISTFILESIZE=2000


# ==========================================
# 3. シェル動作設定
# ==========================================
shopt -s checkwinsize
export COLORTERM=truecolor


# ==========================================
# 4. Less設定
# ==========================================
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"


# ==========================================
# 5. エイリアス設定
# ==========================================

# Eza (ls の置き換え)
if command -v eza > /dev/null; then
    alias ls='eza --icons --git'
    alias ll='eza -lah --icons --git'
    alias la='eza -a --icons --git'
    alias lt='eza --tree --icons'
else
    alias ll='ls -alF'
    alias la='ls -A'
    alias l='ls -CF'
fi

# grep のカラー表示
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'


# ==========================================
# 6. 機能関数
# ==========================================

cd() {
    builtin cd "$@" && ls
}

tmpl() {
    local src
    case "$1" in
        python|py) src="main.py" ;;
        java)      src="Main.java" ;;
        rust|rs)   src="main.rs" ;;
        c++|cpp)   src="main.cpp" ;;
        *)         src="$1" ;;
    esac
    if [ -n "$2" ]; then
        mkdir -p "$2" && cp -i "$HOME/template/$src" "$2/$src"
    else
        cp -i "$HOME/template/$src" "./$src"
    fi
}


# ==========================================
# 7. 外部設定ファイルの読み込み
# ==========================================

# Bash Completion
if ! shopt -oq posix; then
    if [ -f /usr/share/bash-completion/bash_completion ]; then
        . /usr/share/bash-completion/bash_completion
    elif [ -f /etc/bash_completion ]; then
        . /etc/bash_completion
    fi
fi

# Custom aliases
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi


# ==========================================
# 8. 開発環境設定
# ==========================================

# NVM (Node Version Manager)
if [ -d "$HOME/.nvm" ]; then
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
fi

# Starship Prompt
if command -v starship > /dev/null; then
    eval "$(starship init bash)"
fi
export PATH=$PATH:/usr/local/go/bin
. "$HOME/.cargo/env"
# opencode
export PATH="$HOME/.opencode/bin:$PATH"
export BROWSER=wslview
alias ae="docker exec -it atcoder-env_devcontainer-dev-1 bash -i"
