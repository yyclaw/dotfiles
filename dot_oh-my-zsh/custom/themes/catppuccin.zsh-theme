compose_battery_info() {
  PROMPT_BATTERY_INFO=""

  [[ $(pmset -g batt) =~ ([0-9]+)% ]] || return

  local percent=${match[1]}

  if (( percent <= 10 )); then
    PROMPT_BATTERY_INFO=" 󰂎 $percent%% "
  elif (( percent <= 30 )); then
    PROMPT_BATTERY_INFO=" 󰁽 $percent%% "
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

  local flag
  if [[ -z "$(git status --porcelain 2>/dev/null)" ]]; then
    flag="✓"
  else
    flag="⇪"
  fi

  PROMPT_GIT_INFO="  $ref $flag "
}

# Use add-zsh-hook (Zsh's official hook manager) to safely append precmd functions without duplication.
autoload -Uz add-zsh-hook
add-zsh-hook precmd compose_git_info
add-zsh-hook precmd compose_battery_info

# # Expand variables and commands in PROMPT/RPROMPT variables.
# # Already been set up in oh-my-zsh.
# setopt prompt_subst

# Palette: https://github.com/catppuccin/catppuccin
local green="#a6e3a1"
local pink="#f5c2e7"
local peach="#fab387"
local yellow="#f9e2af"
local sapphire="#74c7ec"
local lavender="#b4befe"
local crust="#11111b"

PROMPT='
%F{$pink}'
PROMPT+='%K{$pink}%F{$crust}🧑🏻‍💻 ㍿ '
PROMPT+='%K{$peach}%F{$pink} %F{$crust}%~ '
PROMPT+='%K{$yellow}%F{$peach}%F{$crust}$PROMPT_GIT_INFO'
PROMPT+='%K{$sapphire}%F{$yellow}%F{$crust}$PROMPT_BATTERY_INFO'
PROMPT+='%K{$lavender}%F{$sapphire} %F{$crust} %* %k'
PROMPT+='%F{$lavender}
%F{green}❯%f '
