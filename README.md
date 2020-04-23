# Dotfiles [![pipeline status](https://gitlab.com/abel0b/dotfiles/badges/master/pipeline.svg)](https://gitlab.com/abel0b/dotfiles/commits/master)
Personal configuration files

## Usage
```bash
./dotman.sh sync [machine]
```

### Commands
- `sync`    Link and copy dotfiles
- `unsync`  Remove dotfiles
- `status`  Show dotfiles status
- `system`  Configure new machine
- `help`    Show help message

## Configure new machine
```bash
curl https://raw.githubusercontent.com/abel0b/dotfiles/master/autosetup.sh | bash -
```
