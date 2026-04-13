#!/usr/bin/env zsh
# Claude Code status line: model | context % | cache hit % | 5h usage % + reset | 7d usage % + reset

input=$(cat)

model=$(echo "$input" | jq -r '.model.display_name // "Unknown"')

used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
five_pct=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
five_reset=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // empty')
week_pct=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')
week_reset=$(echo "$input" | jq -r '.rate_limits.seven_day.resets_at // empty')

cache_read=$(echo "$input" | jq -r '.context_window.current_usage.cache_read_input_tokens // empty')
cache_create=$(echo "$input" | jq -r '.context_window.current_usage.cache_creation_input_tokens // empty')
input_tokens=$(echo "$input" | jq -r '.context_window.current_usage.input_tokens // empty')


format_reset() {
  local epoch="$1" mode="${2:-short}"
  if [ -z "$epoch" ]; then echo ""; return; fi
  local now
  now=$(date +%s)
  local diff=$((epoch - now))
  if [ $diff -le 0 ]; then echo "now"; return; fi
  if [ "$mode" = "days" ]; then
    local d=$((diff / 86400))
    local h=$(( (diff % 86400) / 3600 ))
    local m=$(( (diff % 3600) / 60 ))
    if [ $d -gt 0 ]; then
      printf "%dd·%dh·%dm" "$d" "$h" "$m"
    elif [ $h -gt 0 ]; then
      printf "%dh·%dm" "$h" "$m"
    else
      printf "%dm" "$m"
    fi
  else
    local h=$((diff / 3600))
    local m=$(( (diff % 3600) / 60 ))
    if [ $h -gt 0 ]; then
      printf "%dh·%dm" "$h" "$m"
    else
      printf "%dm" "$m"
    fi
  fi
}

parts=()
sep="$(printf ' \033[0;90m|\033[0m ')"

parts+=("$(printf '\033[0;36m%s\033[0m' "$model")")

if [ -n "$used_pct" ]; then
  used_int=$(printf '%.0f' "$used_pct")
  parts+=("$(printf 'Ctx → \033[0;33m%d%%\033[0m' "$used_int")")
fi

if [ -n "$cache_read" ] && [ -n "$input_tokens" ] && [ "$input_tokens" -gt 0 ] 2>/dev/null; then
  total_input=$((input_tokens + ${cache_read:-0} + ${cache_create:-0}))
  if [ "$total_input" -gt 0 ]; then
    cache_hit_pct=$(awk "BEGIN { printf \"%.0f\", ($cache_read / $total_input) * 100 }")
    parts+=("$(printf 'Cache → \033[0;32m%d%%\033[0m' "$cache_hit_pct")")
  fi
fi

if [ -n "$five_pct" ]; then
  five_int=$(printf '%.0f' "$five_pct")
  reset_str=$(format_reset "$five_reset")
  label="$(printf '5h → \033[0;35m%d%%' "$five_int")"
  [ -n "$reset_str" ] && label="${label} (↺ ${reset_str})"
  label="${label}$(printf '\033[0m')"
  parts+=("$label")
fi

if [ -n "$week_pct" ]; then
  week_int=$(printf '%.0f' "$week_pct")
  reset_str=$(format_reset "$week_reset" "days")
  label="$(printf '7d → \033[0;34m%d%%' "$week_int")"
  [ -n "$reset_str" ] && label="${label} (↺ ${reset_str})"
  label="${label}$(printf '\033[0m')"
  parts+=("$label")
fi

# Build single line
line=""
for part in "${parts[@]}"; do
  if [ -z "$line" ]; then
    line="$part"
  else
    line="${line}${sep}${part}"
  fi
done

printf '%b\n' "$line"
