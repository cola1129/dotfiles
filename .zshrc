# Path to your oh-my-zsh configuration.
ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
ZSH_THEME="robbyrussell"

# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# Set to this to use case-sensitive completion
# CASE_SENSITIVE="true"

# Comment this out to disable bi-weekly auto-update checks
# DISABLE_AUTO_UPDATE="true"

# Uncomment to change how often before auto-updates occur? (in days)
# export UPDATE_ZSH_DAYS=13

# Uncomment following line if you want to disable colors in ls
# DISABLE_LS_COLORS="true"

# Uncomment following line if you want to disable autosetting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment following line if you want to disable command autocorrection
DISABLE_CORRECTION="true"

# Uncomment following line if you want red dots to be displayed while waiting for completion
# COMPLETION_WAITING_DOTS="true"

# Uncomment following line if you want to disable marking untracked files under
# VCS as dirty. This makes repository status check for large repositories much,
# much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
#plugins=(git osx macports pip django python screen supervisor svn virtualenv virtualenvwrapper)
plugins=(git git-extras tmux osx macports pip django python screen supervisor svn ruby rbenv brew gem)

# 导入oh-my-zsh之前设置PATH
test -z $O_PATH && export O_PATH=$PATH
export PATH=/opt/local/php/bin:/opt/local/nginx/sbin:/opt/local/python/bin:/opt/local/bin:/opt/local/sbin:/usr/local/sbin:/usr/local/bin:$O_PATH

source $ZSH/oh-my-zsh.sh

# Customize to your needs...
#####################################################################
alias gotoproxy="ssh -p 11009 root@xj2o6hvnad.elb4.sinasws.com"
alias gotoanli="ssh andy@mylinode"

# python virtualenv
export WORKON_HOME=$HOME/Envs
source /opt/local/python/bin/virtualenvwrapper.sh

# rbenv init; using homebrew than .rbenv.git
#export PATH=~/.rbenv/bin:/opt/local/php/bin:/opt/local/nginx/sbin:/opt/local/python/bin:/opt/local/bin:/opt/local/sbin:$O_PATH
export RBENV_ROOT=/usr/local/var/rbenv
if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi

# left prompt
PROMPT='%{$fg_bold[red]%}➜  %{$reset_color%}'
# right prompt
RPROMPT='%~ %{$fg_bold[blue]%}$(git_prompt_info)%{$fg_bold[blue]%}%{$reset_color%}'

#eval $(gdircolors ~/.dir_colors)
#zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

export LS_OPTIONS='-F'
alias l='ls $LS_OPTIONS'
alias ll='ls $LS_OPTIONS -lh'
alias lla='ls $LS_OPTIONS -alh'
alias sl='ls $LS_OPTIONS'

# pip zsh completion start
#function _pip_completion {
  #local words cword
  #read -Ac words
  #read -cn cword
  #reply=( $( COMP_WORDS="$words[*]" \
             #COMP_CWORD=$(( cword-1 )) \
             #PIP_AUTO_COMPLETE=1 $words[1] ) )
#}
#compctl -K _pip_completion pip
# pip zsh completion end

