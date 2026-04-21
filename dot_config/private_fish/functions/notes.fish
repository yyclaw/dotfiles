# Helper: List available commands (also used by completions)
function __notes_list_commands
    echo yazi
    echo fd
end

function notes --description "Show command cheatsheet with copy-by-index support"
    set -l cheatsheet_yazi \
        "Ctrl + a       | Select all files" \
        "Tab            | Show file information" \
        "c              | Copy" \
        "f              | Filter files" \
        "s              | Search files by name using fd" \
        ",              | Sort files" \
        "t              | Create a new tab with CWD" \
        "1, 2, ..., 9   | Switch to the N-th tab" \
        "[ ]            | Switch to the previous/next tab" \
        "Ctrl + c       | Close the current tab"

    set -l cheatsheet_fd \
        "fd -IHgt d '.{next,turbo}'             | Cleanup dev cache" \
        "fd -IHgt d '.{next,turbo}' -X rm -r" \
        "fd -IHg '**/.DS_Store'                 | Cleanup .DS_Store" \
        "fd -IHg '**/.DS_Store' -X rm"

    # Unified color variables
    set -l clr_grey    (set_color grey)
    set -l clr_green   (set_color green)
    set -l clr_normal  (set_color normal)
    set -l clr_magenta (set_color magenta)

    # Setup available commands
    set -l cmds (__notes_list_commands)

    set -l cmd $argv[1]
    set -l index $argv[2]

    # No arguments: list available commands
    if test -z "$cmd"
        echo "Available commands:"
        for c in $cmds
            printf "%s → %s%s\n" "$clr_grey" "$clr_magenta$c" "$clr_normal"
        end
        echo -e "\nUsage: "
        printf "%s  notes <command> [index]%s\n\n" "$clr_green" "$clr_normal"
        echo "Examples: "
        printf "%s  notes fd      %s# List all commands for fd\n" "$clr_green" "$clr_grey"
        printf "%s  notes fd 3    %s# Copy the 3rd command to clipboard%s\n" "$clr_green" "$clr_grey" "$clr_normal"
        return 0
    end

    # Validate command
    if not contains -- $cmd $cmds
        echo "Error: no cheatsheet for '$cmd'"
        return 1
    end

    # Get entries for the requested command
    set -l entries
    switch $cmd
        case yazi;  set entries $cheatsheet_yazi
        case fd;    set entries $cheatsheet_fd
    end

    # Helper to split entry into command and description
    function _parse_entry
        set -l parts (string split -m 1 "|" $argv[1])
        set -l cmd_part (string trim $parts[1])
        set -l desc_part (test -n "$parts[2]"; and string trim $parts[2]; or echo "")
        echo $cmd_part
        echo $desc_part
    end

    # Index provided: copy specific command to clipboard
    if test -n "$index"
        if not string match -rq '^[1-9][0-9]*$' -- $index
            echo "Error: index must be a positive integer"
            return 1
        end
        if test $index -gt (count $entries)
            echo "Error: index out of range (1-$(count $entries))"
            return 1
        end

        set -l target $entries[$index]
        set -l parsed (_parse_entry $target)
        set -l cmd_part $parsed[1]
        set -l desc_part $parsed[2]

        echo -n $cmd_part | pbcopy
        printf "%s✓ Copied: %s%s" "$clr_green" "$clr_magenta$cmd_part" "$clr_normal"
        if test -n "$desc_part"
            printf "%s   →  %s%s" "$clr_grey" "$desc_part" "$clr_normal"
        end
        echo
        return 0
    end

    # Calculate max width based on the longest cmd_part (capped at 80)
    set -l max_width 0
    set -l width_cap 80
    for entry in $entries
        set -l parsed (_parse_entry $entry)
        set -l len (string length -- $parsed[1])
        if test $len -gt $max_width
            set max_width $len
        end
    end
    if test $max_width -gt $width_cap
        set max_width $width_cap
    end

    # No index: display numbered list
    set -l i 1
    echo
    for entry in $entries
        set -l parsed (_parse_entry $entry)
        printf "  %2d. %s%-*s%s" $i "$clr_magenta" $max_width $parsed[1] "$clr_normal"
        set -l desc_part $parsed[2]
        if test -n "$desc_part"
            printf "      %s%s" "$clr_grey" $desc_part
        end
        echo
        set i (math $i + 1)
    end
    echo
    printf "Usage: %snotes %s <index>   %s# Copy the command to clipboard%s\n" \
        "$clr_green" "$cmd" "$clr_grey" "$clr_normal"
end

# Dynamic completions: disable file completion, show only command list
complete -c notes --no-files -a '(__notes_list_commands)' --description "Show cheatsheet"
