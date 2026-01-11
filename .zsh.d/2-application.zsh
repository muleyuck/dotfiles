# homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"

# antigen
source ~/.config/antigen/antigen.zsh

antigen bundle zsh-users/zsh-syntax-highlighting
antigen bundle zsh-users/zsh-autosuggestions
antigen bundle zsh-users/zsh-completions
antigen bundle olets/zsh-abbr@main
antigen bundle zsh-users/zsh-history-substring-search

antigen apply

bindkey '^P' history-substring-search-up
bindkey '^N' history-substring-search-down
HISTORY_SUBSTRING_SEARCH_ENSURE_UNIQUE=1000

# starship init
export STARSHIP_CONFIG=~/.config/startship/starship.toml
eval "$(starship init zsh)"

# zoxide
eval "$(zoxide init zsh --hook prompt)"

# mise
eval "$(mise activate zsh)"

# linippet
export LINIPPET_DATA="$HOME/.config/linippet"
export LINIPPET_TRIGGER_BIND_KEY="^o"
eval "$(linippet init zsh)"

# gnu-sed instead of sed
export PATH="/opt/homebrew/opt/gnu-sed/libexec/gnubin:$PATH"

# mysql-client
export PATH="/opt/homebrew/opt/mysql-client/bin:$PATH"

# fzf
export FZF_DEFAULT_OPTS="--bind 'ctrl-j:preview-down,ctrl-k:preview-up,ctrl-u:preview-half-page-up,ctrl-d:preview-half-page-down'"
