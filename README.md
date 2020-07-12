# Dotfiles [![pipeline status](https://gitlab.com/abel0b/dotfiles/badges/master/pipeline.svg)](https://gitlab.com/abel0b/dotfiles/commits/master)
Set of tools to bootstrap new machines.

## Usage
```bash
./dotman.sh sync [machine]

# Ubuntu
./dotman.sh sync ubuntu

# Archlinux
./dotmatn.sh sync arch

# Windows Subsystem Linux
./dotman.sh sync wsl
```

### Commands
- `sync`    Configure machine
- `unsync`  Unconfigure machine
- `status`  Display configuration status

## Bootstrap a new machine
```bash
curl https://raw.githubusercontent.com/abel0b/dotfiles/master/dotboot.sh | bash -
```
