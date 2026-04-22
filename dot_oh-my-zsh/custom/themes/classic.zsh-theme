compose_battery_info() {
  PROMPT_BATTERY_INFO=""

  [[ $(pmset -g batt) =~ ([0-9]+)% ]] || return

  local percent=${match[1]}

  if (( percent <= 10 )); then
    PROMPT_BATTERY_INFO="%F{009}󰂎 $percent%%%f"
  elif (( percent <= 30 )); then
    PROMPT_BATTERY_INFO="%F{208}󰁽 $percent%%%f"
  fi
}

compose_git_info() {
  PROMPT_GIT_INFO=""

  git rev-parse --is-inside-work-tree &>/dev/null || return

  # branch > tag > commit
  local ref
  ref=$(git symbolic-ref --quiet --short HEAD 2>/dev/null) ||
  ref=$(git describe --tags --exact-match 2>/dev/null) ||
  ref=$(git rev-parse --short HEAD 2>/dev/null)

  local color flag
  if [[ -z "$(git status --porcelain 2>/dev/null)" ]]; then
    color="082"
    flag="✓"
  else
    color="208"
    flag="⇪"
  fi

  PROMPT_GIT_INFO="%F{008}git:(%F{$color}$ref $flag%F{008})%f"
}

# Use add-zsh-hook (Zsh's official hook manager) to safely append precmd functions without duplication.
autoload -Uz add-zsh-hook
add-zsh-hook precmd compose_git_info
add-zsh-hook precmd compose_battery_info

# # Expand variables and commands in PROMPT/RPROMPT variables.
# # Already been set up in oh-my-zsh.
# setopt prompt_subst

PROMPT='
🧑🏻‍💻 %F{008}in (%F{006}%~%F{008})  $PROMPT_GIT_INFO
%F{154}❯%f '
RPROMPT='$PROMPT_BATTERY_INFO'
