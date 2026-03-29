# Minimal zsh config - no framework

# History
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt HIST_IGNORE_DUPS SHARE_HISTORY APPEND_HISTORY INTERACTIVE_COMMENTS

# Completion
autoload -Uz compinit
if [[ -n ~/.zcompdump(#qN.mh+24) ]]; then
  compinit
else
  compinit -C
fi
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}' # case-insensitive
zstyle ':completion:*' menu select # arrow-key menu
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}" # colored completions

# Key bindings
bindkey '^[[H' beginning-of-line    # Home
bindkey '^[[F' end-of-line          # End
bindkey '^[[1;5C' forward-word      # Ctrl+Right
bindkey '^[[1;5D' backward-word     # Ctrl+Left

# Utility functions
take() { mkdir -p "$1" && cd "$1" }

# Directory navigation (from oh-my-zsh)
setopt AUTO_CD AUTO_PUSHD PUSHD_IGNORE_DUPS PUSHD_SILENT
alias -g ...='../..'
alias -g ....='../../..'
alias -g .....='../../../..'
alias -- -='cd -'
alias 1='cd -1'
alias 2='cd -2'
alias 3='cd -3'
alias d='dirs -v | head -10'
alias l='ls -lah'
alias la='ls -lAh'
alias ll='ls -lh'
alias ls='ls -G'

# Git aliases (from oh-my-zsh git plugin)
alias g='git'
alias ga='git add'
alias gaa='git add --all'
alias gb='git branch'
alias gba='git branch -a'
alias gc='git commit -v'
alias gc!='git commit -v --amend'
alias gca='git commit -v -a'
alias gcam='git commit -a -m'
alias gcb='git checkout -b'
alias gcm='git checkout main'
alias gco='git checkout'
alias gcp='git cherry-pick'
alias gd='git diff'
alias gds='git diff --staged'
alias gf='git fetch'
alias gl='git pull'
alias glg='git log --stat'
alias glog='git log --oneline --graph --decorate'
alias gm='git merge'
alias gp='git push'
alias gpf='git push --force-with-lease'
alias grb='git rebase'
alias grbi='git rebase -i'
alias gst='git status'
alias gsw='git switch'
alias gswc='git switch -c'

# Homebrew (cached - avoids subprocess)
export HOMEBREW_PREFIX="/opt/homebrew"
export HOMEBREW_CELLAR="/opt/homebrew/Cellar"
export HOMEBREW_REPOSITORY="/opt/homebrew"
export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"
export MANPATH="/opt/homebrew/share/man${MANPATH+:$MANPATH}:"
export INFOPATH="/opt/homebrew/share/info:${INFOPATH:-}"

# Auto-suggestions (ghost text from history, accept with →)
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# mise (must come before starship, since mise manages it)
eval "$(mise activate zsh)"

# Prompt (Starship - shows directory, git branch, changes, and more)
eval "$(starship init zsh)"

# Go (cached - avoids subprocess)
export PATH="$PATH:$HOME/go/bin"

# Alias area
export BUNDLER_EDITOR="code -n"
BUILDKITE_ORG_DIR="$HOME/github.com/buildkite"

alias mitchbne="cd $HOME/github.com/mitchbne"
alias "cdbk"="cd $BUILDKITE_ORG_DIR/buildkite"
function kill-process-by-port {
  local port=$1
  lsof -i -P -n | grep LISTEN | grep -i "$port" | awk 'NR > 1 {print $2}' | xargs -n1 kill -9
}

alias "quick-setup"="cd $BUILDKITE_ORG_DIR/buildkite && (bundle check || bundle) && bin/rails db:prepare && yarn && echo 'Setup complete!'"

function bk-console {
  pushd $BUILDKITE_ORG_DIR/buildkite &> /dev/null
    bundle exec rails c
  popd &> /dev/null
}

function agents-kill {
  pgrep buildkite-agent | xargs kill -9
}

function bk-recognize-path {
  pushd $BUILDKITE_ORG_DIR/buildkite &> /dev/null
  if [ -z "$1" ]; then
    echo "No path specified"
    echo "Usage: bk-recognize-path <path>"
    return 1
  fi

  if [[ "$1" != http* ]]; then
    echo "Path must be a full URL"
    echo "Usage: bk-recognize-path <path>"
    echo "Example: bk-recognize-path https://buildkite.com/organizations/~/builds"
    return 1
  fi

  echo ""
  rails_command="bundle exec rails runner 'pp Rails.application.routes.recognize_path \"$1\"'"
  eval $rails_command
  popd &> /dev/null
}

export PROCFILE_RUNNER="overmind"

export BUILDKITE_ACCESS_TOKEN="[REDACTED:buildkite-agent-token]"

function prod-console {
  aws sso login --profile prod-console 2>/dev/null
  if [ -z "$1" ]; then
    AWS_PROFILE=prod-console bik console
  else
    AWS_PROFILE=prod-console bik console "'$@'"
  fi
}

function quarantine {
  local filename=$1

  if [ -z "$filename" ]; then
    echo "No file specified"
    echo "Usage: quarantine <file>"
    return 1
  fi

  xattr -d com.apple.quarantine $filename
}

# bun completions
[ -s "/Users/mitchsmith/.bun/_bun" ] && source "/Users/mitchsmith/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# pnpm
export PNPM_HOME="/Users/mitchsmith/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

export PATH="/opt/homebrew/opt/libpq/bin:$PATH"
export PATH="/Users/mitchsmith/.local/bin:$PATH"
