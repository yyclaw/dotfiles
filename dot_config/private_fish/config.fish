# ========== Setup $PATH ==========
fish_add_path /opt/homebrew/bin
fish_add_path $HOME/.local/bin
fish_add_path $HOME/.utoo-proxy


# ========== Setup mirrors ==========
set -gx ELECTRON_MIRROR "https://npmmirror.com/mirrors/electron/"
set -gx HOMEBREW_BOTTLE_DOMAIN "https://mirrors.ustc.edu.cn/homebrew-bottles"
set -gx HOMEBREW_NO_AUTO_UPDATE 1


# ========== Setup default Editor ==========
set -gx EDITOR subl


# ========== Initialize CLI tools ==========
fnm env --shell fish | source  # add --use-on-cd if wanted
zoxide init fish | source
starship init fish | source


# ========== Shell completions ==========
# fish auto-loads ~/.config/fish/completions/; keep the old zsh dir too:
set -p fish_complete_path $HOME/.zsh/completions


# ========== Setup aliases ==========
alias agb="agent-browser"
alias play="afplay"
alias fd="fd --glob"
alias nls="time npm ls -g --depth=0"
alias ip="curl -s https://ifconfig.co/ip"
alias l="lsd"
alias ll="lsd -A"
alias la="lsd -lA --git"


# ========== EOF ==========
