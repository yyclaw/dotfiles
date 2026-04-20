function nosleep
    set -l h $argv[1]
    test -z "$h"; and set h 8
    set -l word hour
    test "$h" -gt 1; and set word hours
    printf "System will stay awake for %d %s..." $h $word
    caffeinate -t (math "$h * 3600")
end
