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

### MANAGED BY RANCHER DESKTOP START (DO NOT EDIT)
export PATH="/Users/takuto.otsuka/.rd/bin:$PATH"
### MANAGED BY RANCHER DESKTOP END (DO NOT EDIT)

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
