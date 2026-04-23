# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository purpose

Personal dotfiles managed by [chezmoi](https://github.com/twpayne/chezmoi). The source-of-truth lives here at `~/.local/share/chezmoi` and chezmoi renders it to `$HOME`.

## chezmoi naming convention

File/directory names in this repo are **chezmoi source names**, not the real target paths. When editing, keep the mapping in mind:

- `dot_foo` → `~/.foo` (e.g. `dot_zshrc` → `~/.zshrc`, `dot_config/` → `~/.config/`)
- `private_foo` → target has group/other perms stripped (e.g. `dot_config/private_fish` → `~/.config/fish` with 0700)
- `*.tmpl` → rendered as a Go template (none currently in this repo — all files are plain)

To find where a source file lands, run `chezmoi target-path <source-file>`.

## Common commands

```sh
# Apply source → $HOME (what you'll run after editing a file here)
chezmoi apply -v

# See what would change without applying
chezmoi diff

# Add a new existing dotfile into this repo (converts name to chezmoi convention automatically)
chezmoi add ~/.config/some/file

# Edit a managed file via chezmoi (opens source file, applies on save)
chezmoi edit ~/.zshrc

# List managed files
chezmoi managed --include=files

# Jump to this repo
chezmoi cd
```

Typical edit workflow: edit the file under this repo → `chezmoi diff` → `chezmoi apply` → commit.

## What lives here

- `dot_zshrc`, `dot_zsh/`, `dot_oh-my-zsh/custom/themes/` — zsh shell config and a custom oh-my-zsh theme
- `dot_config/private_fish/` — fish shell config (private perms)
- `dot_config/yazi/` — yazi file manager (`yazi.toml`, `keymap.toml`, `plugins/`)
- `dot_config/ghostty/`, `dot_config/bat/`, `dot_config/lsd/`, `dot_config/starship.toml`, `dot_config/navi/`, `dot_config/fresh/`, `dot_config/git/ignore` — per-tool configs
- `dot_claude/` — Claude Code config (`settings.json`, `statusline-command.zsh`)

## Commit style

Conventional-commits-ish prefixes used in git history: `feat:`, `fix:`, `chore:`, `docs:`. Keep messages short and in this style.
