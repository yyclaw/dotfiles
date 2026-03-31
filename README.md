# dotfiles for me

Managed by [chezmoi](https://github.com/twpayne/chezmoi).

```sh
chezmoi init --apply https://github.com/yyclaw/dotfiles.git

chezmoi add ~/.config/ghostty/config.ghostty

chezmoi managed

chezmoi cd

git push -u
```