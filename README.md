# dotfiles for me

Managed by [chezmoi](https://github.com/twpayne/chezmoi).

```sh
chezmoi init --apply --ssh git@github.com:yyclaw/dotfiles.git

chezmoi add ~/.config/ghostty/config.ghostty

chezmoi managed --include=files

chezmoi cd

git push -u
```