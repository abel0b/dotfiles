# Dotfiles [![pipeline status](https://gitlab.com/abeliam/dotfiles/badges/master/pipeline.svg)](https://gitlab.com/abeliam/dotfiles/commits/master)
Personal configuration files

## Usage
```bash
./setup.sh [COMMAND]
```
### Commands
- `sync`    Link and copy dotfiles
- `unsync`  Remove dotfiles
- `status`  Show dotfiles status
- `system`  Configure new machine
- `help`    Show help message


## Configure new machine
```bash
curl https://raw.githubusercontent.com/abel0b/dotfiles/master/system/sync.sh | bash -
```
