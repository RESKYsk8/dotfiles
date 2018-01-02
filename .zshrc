function is_exists() { type "$1" >/dev/null 2>&1; return $?; }
function is_osx() { [[ $OSTYPE == darwin* ]]; }
function is_screen_running() { [ ! -z "$STY" ]; }
function is_tmux_runnning() { [ ! -z "$TMUX" ]; }
function is_screen_or_tmux_running() { is_screen_running || is_tmux_runnning; }
function shell_has_started_interactively() { [ ! -z "$PS1" ]; }
function is_ssh_running() { [ ! -z "$SSH_CONECTION" ]; }

function tmux_automatically_attach_session()
{
    if is_screen_or_tmux_running; then
        ! is_exists 'tmux' && return 1

        if is_tmux_runnning; then
echo -e "\e[31m□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□"
echo -e "\e[31m□□□□□□□□□□□□□□□■■■■■□□□□■■■■■■■□□□□■■□■□□□■■■□□■■□□■■□□□■■□□□□□□□□□□□□□□□"
echo -e "\e[31m□□□□□□□□□□□□□□□□■□□□■□□□□■□□□□■□□□■□□■■□□□□■□□□■□□□■□□□□□■□□□□□□□□□□□□□□□"
echo -e "\e[31m□□□□□□□□□□□□□□□□■□□□□■□□□■□□□□■□□■□□□□■□□□□■□□□■□□□□■□□□■□□□□□□□□□□□□□□□□"
echo -e "\e[31m□□□□□□□□□□□□□□□□■□□□□■□□□■□□□□□□□■□□□□□□□□□■□□■□□□□□■□□□■□□□□□□□□□□□□□□□□"
echo -e "\e[33m□□□□□□□□□□□□□□□□■□□□□■□□□■□□■□□□□■□□□□□□□□□■□□■□□□□□■□□□■□□□□□□□□□□□□□□□□"
echo -e "\e[33m□□□□□□□□□□□□□□□□■□□□■□□□□■□□■□□□□□■■□□□□□□□■■■□□□□□□□■□■□□□□□□□□□□□□□□□□□"
echo -e "\e[33m□□□□□□□□□□□□□□□□■■■■□□□□□■■■■□□□□□□□■■□□□□□■□■□□□□□□□■□■□□□□□□□□□□□□□□□□□"
echo -e "\e[33m□□□□□□□□□□□□□□□□■□□■□□□□□■□□■□□□□□□□□□■□□□□■□□■□□□□□□□■□□□□□□□□□□□□□□□□□□"
echo -e "\e[33m□□□□□□□□□□□□□□□□■□□□■□□□□■□□■□□□□■□□□□□■□□□■□□■□□□□□□□■□□□□□□□□□□□□□□□□□□"
echo -e "\e[32m□□□□□□□□□□□□□□□□■□□□■□□□□■□□□□■□□■□□□□□■□□□■□□□■□□□□□□■□□□□□□□□□□□□□□□□□□"
echo -e "\e[32m□□□□□□□□□□□□□□□□■□□□■□□□□■□□□□■□□■□□□□□■□□□■□□□■□□□□□□■□□□□□□□□□□□□□□□□□□"
echo -e "\e[32m□□□□□□□□□□□□□□□□■□□□□■□□□■□□□□■□□■■□□□■□□□□■□□□□■□□□□□■□□□□□□□□□□□□□□□□□□"
echo -e "\e[32m□□□□□□□□□□□□□□□■■■□□□■■□■■■■■■■□□■□■■■□□□□■■■□□□■■□□■■■■■□□□□□□□□□□□□□□□□"
echo -e "\e[32m□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□"
       elif is_screen_running; then
           echo "This is on screen."
       fi
       else
       if shell_has_started_interactively && ! is_ssh_running; then
           if ! is_exists 'tmux'; then
               echo 'Error: tmux command not found' 2>&1
               return 1
           fi

           if tmux has-session >/dev/null 2>&1 && tmux list-sessions | grep -qE '.*]$'; then
                # detached session exists
                tmux list-sessions
                echo -n "Tmux: attach? (y/N/num) "
                read
                if [[ "$REPLY" =~ ^[Yy]$ ]] || [[ "$REPLY" == '' ]]; then
                    tmux attach-session
                    if [ $? -eq 0 ]; then
                        echo "$(tmux -V) attached session"
                        return 0
                    fi
                elif [[ "$REPLY" =~ ^[0-9]+$ ]]; then
                    tmux attach -t "$REPLY"
                    if [ $? -eq 0 ]; then
                        echo "$(tmux -V) attached session"
                        return 0
                    fi
                fi
            fi

            if is_osx && is_exists 'reattach-to-user-namespace'; then
                # on OS X force tmux's default command
                # to spawn a shell in the user's namespace
                tmux_config=$(cat $HOME/.tmux.conf <(echo 'set-option -g default-command "reattach-to-user-namespace -l $SHELL"'))
                tmux -f <(echo "$tmux_config") new-session && echo "$(tmux -V) created new session supported OS X"
            else
                tmux new-session && echo "tmux created new session"
            fi
        fi
    fi
}
tmux_automatically_attach_session


################################
## zplug設定
if [[ ! -d ~/.zplug ]];then
  git clone https://github.com/zplug/zplug ~/.zplug
fi

source ~/.zplug/init.zsh

# enhancd config
export ENHANCD_COMMAND=ed
export ENHANCD_FILTER=ENHANCD_FILTER=fzy:fzf:peco

# Vanilla shell
zplug "yous/vanilli.sh"

# Additional completion definitions for Zsh
zplug "zsh-users/zsh-completions"

# Load the theme.
# zplug 'yous/lime', as:theme
# zplug 'dracula/zsh', as:theme
# zplug "sindresorhus/pure", use:pure.zsh, from:github, as:theme
# prezto のプラグインやテーマを使用する
zplug "modules/osx", from:prezto, if:"[[ $OSTYPE == *darwin* ]]"
zplug "modules/prompt", from:prezto

# zstyle は zplug load の前に設定する
zstyle ':prezto:module:prompt' theme 'giddie'

# Syntax highlighting bundle. zsh-syntax-highlighting must be loaded after
# excuting compinit command and sourcing other plugins.
zplug "zsh-users/zsh-syntax-highlighting", defer:2

# ZSH port of Fish shell's history search feature
zplug "zsh-users/zsh-history-substring-search", hook-build:"__zsh_version 4.3"

# fzf インタラクティブフィルタ
zplug "junegunn/fzf-bin", as:command, from:gh-r, rename-to:fzf
zplug "junegunn/fzf", as:command, use:bin/fzf-tmux

# Tracks your most used directories, based on 'frecency'.
zplug "rupa/z", use:"*.sh"

# A next-generation cd command with an interactive filter
zplug "b4b4r07/enhancd", use:init.sh

# This plugin adds many useful aliases and functions.
zplug "plugins/git",   from:oh-my-zsh

# Install plugins if there are plugins that have not been installed
if ! zplug check --verbose; then
    printf "Install? [y/N]: "
    if read -q; then
        echo; zplug install
    fi
fi

# Then, source plugins and add commands to $PATH
zplug load --verbose

# Lime theme settings
export LIME_DIR_DISPLAY_COMPONENTS=2

# Better history searching with arrow keys
if zplug check "zsh-users/zsh-history-substring-search"; then
    bindkey "$terminfo[kcuu1]" history-substring-search-up
    bindkey "$terminfo[kcud1]" history-substring-search-down
fi

# Add color to ls command
export CLICOLOR=1

# NeoVim config
export XDG_CONFIG_HOME=$HOME/.xdgconfig

# Load rbenv
if [ -e "$HOME/.rbenv" ]; then
eval "$(rbenv init - zsh)"
fi

# Set GOPATH for Go
if command -v go &> /dev/null; then
  [ -d "$HOME/go" ] || mkdir "$HOME/go"
  export GOPATH="$HOME/go"
  export GOROOT=/usr/local/opt/go/libexec
  export PATH="$PATH:$GOPATH/bin:$GOROOT/bin"
fi

# Set PATH for GAE
export PATH=$HOME/go/appengine:$PATH


# -------------------------------------
# その他の設定
# -------------------------------------

# cdしたあとで、自動的に ls する
function chpwd() { ls -al }

# Linuxbrewの設定
export PATH="$HOME/.linuxbrew/bin:$PATH"
export LD_LIBRARY_PATH="$HOME/.linuxbrew/lib:$LD_LIBRARY_PATH"

# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
export PATH="$PATH:$HOME/.rvm/bin"

########################################
# peco設定
function peco-history-selection() {
    BUFFER=`history -n 1 | tail -r  | awk '!a[$0]++' | peco`
    CURSOR=$#BUFFER
    zle reset-prompt
}

zle -N peco-history-selection
bindkey '^R' peco-history-selection


[[ -s /Users/RESKY/.tmuxinator/scripts/tmuxinator ]] && source /Users/RESKY/.tmuxinator/scripts/tmuxinator
source ~/.tmuxinator/tmuxinator.zsh
