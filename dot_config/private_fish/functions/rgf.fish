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
