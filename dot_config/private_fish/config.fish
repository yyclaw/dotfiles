# ========== PATH ==========
fish_add_path /opt/homebrew/bin
fish_add_path $HOME/.local/bin
fish_add_path $HOME/.utoo-proxy


# ========== Mirrors ==========
set -gx ELECTRON_MIRROR "https://npmmirror.com/mirrors/electron/"
set -gx HOMEBREW_BOTTLE_DOMAIN "https://mirrors.ustc.edu.cn/homebrew-bottles"
set -gx HOMEBREW_NO_AUTO_UPDATE 1


# ========== Shell Completions ==========
# fish auto-loads ~/.config/fish/completions/; keep the old zsh dir too:
set -p fish_complete_path $HOME/.zsh/completions


# ========== Setup ==========
fnm env --shell fish | source  # add --use-on-cd if wanted
zoxide init fish | source
starship init fish | source


# ========== Utils ==========
set -gx EDITOR subl

# yazi
function y
    set -l tmp (mktemp -t "yazi-cwd.XXXXXX")
    command yazi $argv --cwd-file="$tmp"
    set -l cwd (command cat -- "$tmp")
    if test -n "$cwd"; and test "$cwd" != "$PWD"; and test -d "$cwd"
        builtin cd -- "$cwd"
    end
    rm -f -- "$tmp"
end

# ripgrep + fzf
function rgf
    if test (count $argv) -eq 0
        echo "Usage: rgf <string> [rg options...]" >&2
        return 1
    end
    set -l string $argv[1]
    set -e argv[1]
    rg -l -F "$string" $argv | fzf \
        --preview "rg -n --color=always -C 3 -F -- '$string' {}" \
        --preview-window="right:60%:wrap" \
        --bind "ctrl-/:toggle-preview" \
        --header="Ctrl-/ to toggle preview" \
        --delimiter=":" \
        --with-nth=1
end

# geolocation
function geo
    set -l ip $argv[1]
    if test -z "$ip"
        set ip (curl -s https://ifconfig.co/ip 2>/dev/null)
    end
    curl -s "http://ip-api.com/json/$ip" | jq .
end

# nosleep
function nosleep
    set -l h $argv[1]
    test -z "$h"; and set h 8
    set -l word hour
    test "$h" -gt 1; and set word hours
    printf "System will stay awake for %d %s..." $h $word
    caffeinate -t (math "$h * 3600")
end


# ========== Check IP before launching Claude Code ==========
source $HOME/.config/fish/check-ip-before-launching-claude-code.fish


# ========== Alias ==========
alias agb="agent-browser"
alias cz="chezmoi"
alias nls="time npm ls -g --depth=0"
alias findDS="fd -IHg '**/.DS_Store'"
alias cleanDS="fd -IHg '**/.DS_Store' -X rm"
alias ip="curl -s https://ifconfig.co/ip"
alias l="lsd"
alias ll="lsd -A"
alias la="lsd -lA --git"


# ========== EOF ==========
