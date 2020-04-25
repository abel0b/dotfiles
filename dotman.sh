#!/usr/bin/env bash

DOTFILES_PATH=${DOTFILES_PATH:-$(cd "$(dirname "${BASH_SOURCE[0]}")" > /dev/null 2>&1 && pwd)}
CACHE_PATH=${CACHE_PATH:-$DOTFILES_PATH/cache}

bold=$(tput bold)
normal=$(tput sgr0)
default_host="ubuntu"
force=false
verbosity=1

function expand_home {
    echo "${1/#\~/$HOME}"
}

function fn_exists() {
    LC_ALL=C type -t $1 | grep -q "function"
}

function fetch {
    source=$1
    destination=$2

    if [[ ! $source =~ = ]]
    then
        return 1
    fi

    if [[ -e $destination ]]
    then
        return
    fi

    method=$(echo $source | cut -d = -f 1)
    resource=$(echo $source | cut -d = -f 2)
    mkdir -p $(dirname $destination)

    case $method in
        "get")
            curl -LJ0 $resource > $destination
            ;;
        "git")
            git clone $resource $destination
            ;;
        *)
            echo -e "\e[31m[error]\e[0m Unknown method $method"
            return 1
            ;;
    esac
}

function dotman_status() {
    if [[ ! -z "$1" ]]
    then
        config_dir="./machines/$1"
        if [[ ! -d "$config_dir" ]]
        then
            echo -e "\e[31m[error]\e[0m Directory does not exist $config_dir"
            exit 1
        fi
        CONFIGS=$(ls -d $(realpath $config_dir)/*)
    else
        CONFIGS=$(ls -d $DOTFILES_PATH/machines/$default_host/* $DOTFILES_PATH/system/*)
    fi

    for config in $CONFIGS
    do
        group=$(basename $(dirname $config))
        echo $bold$group/$(basename $config)$normal
        source "$config/config.sh" # potentially unsafe
        if [[ -v copy[@] ]]
        then
            for ((i=0; i<$((${#copy[@]}/2)); i++))
            do
                target=${copy[$((2*$i))]}
                copyname=$(expand_home ${copy[$((2*$i+1 ))]})

                if [[ $target =~ = ]]
                then
                    target=$CACHE_PATH/$(basename $config)/$(basename $copyname)
                else
                    target=$config/$target
                fi

                if [[ -e $copyname ]]
                then
                    if diff -b $copyname $target > /dev/null
                    then
                        echo -e "    \e[0;32m$copyname\e[0m"
                    else
                        echo -e "    \e[0;33m$copyname (modified)\e[0m"
                    fi
                else
                    echo -e "    \e[0;31m$copyname\e[0m"
                fi
            done
            unset copy
        fi
    done
}

function dotman_sync() {
    mkdir --parent $CACHE_PATH

    if [[ ! -z "$1" ]]
    then
        config_dir="./machines/$1"
        if [[ ! -d "$config_dir" ]]
        then
            echo -e "\e[31m[error]\e[0m Directory does not exist $config_dir"
            exit 1
        fi
        CONFIGS=$(ls -d $(realpath $config_dir)/*)
    else
        CONFIGS=$(ls -d $DOTFILES_PATH/hosts/$default_host/*)
    fi

    for config in $CONFIGS
    do
        echo -e "\e[32m+\e[0m $(basename $config)"
        if [ -f $config/config.sh ]
        then
            source "$config/config.sh" # potentially unsafe
            if [[ -v copy[@] ]]
            then
                for ((i=0; i<$((${#copy[@]}/2)); i++))
                do
                    target=${copy[$((2*$i))]}
                    copyname=$(expand_home ${copy[$((2*$i+1))]})
                    mkdir --parent $(dirname $copyname)

                    if [[ $target =~ = ]]
                    then
                        destination=$CACHE_PATH/$(basename $config)/$(basename $copyname)
                        fetch $target $destination
                        (($? != 0)) && continue
                        target=$destination
                    else
                        target=$config/$target
                    fi

                    if [[ -e "$copyname" ]]
                    then
                        if diff $copyname $target > /dev/null
                        then
                            :
                        elif [[ "$force" = "true" ]]
                        then
                            cp -rf $target $copyname
                        else
                            echo -e "\e[31m[error]\e[0m File already exists $copyname"
                            echo "Use -f option to overwrite"
                            if [[ "$verbosity" = 2 ]]
                            then
                                diff --color -u $copyname $target
                            fi
                        fi
                    else
                        cp -r $target $copyname
                    fi
                done
                unset copy
            fi
            if ! fn_exists "sync"
            then
                (cd $(dirname $config) && sync)
                unset sync
            fi
        fi
    done
}

function dotman_unsync() {
    if [[ ! -z "$1" ]]
    then
        config_dir="./hosts/$1"
        if [[ ! -d "$config_dir" ]]
        then
            echo -e "\e[31m[error]\e[0m Directory does not exist $config_dir"
            exit 1
        fi
        CONFIGS=$(ls -d $(realpath $config_dir)/*)
    fi

    for config in $CONFIGS
    do
        echo -e "\e[31m-\e[0m $(basename $config)"
        if ! fn_exists "unsync"
        then
            (cd $(dirname $config) && unsync)
            unset unsync
        fi
    done

    rm -rf $CACHE_PATH
}

function dotman_import() {
    dotfile=$1
    topic=$2

    if [[ -z ${dotfile:+x} ]]
    then
        echo -e "\e[31m[error]\e[0m Missing argument dotfile"
        exit 1
    fi

    if [[ -z ${topic:+x} ]]
    then
        echo -e "\e[31m[error]\e[0m Missing argument topic"
        exit 1
    fi

    target=$(basename $dotfile)
    linkname=$(realpath $dotfile)

    mkdir -p $DOTFILES_PATH/config/$topic

    mv $dotfile $DOTFILES_PATH/config/$topic

    echo "$target $linkname" >> $DOTFILES_PATH/base/$topic/link.txt
}

commands="sync unsync help status import path"
version=v$(git --git-dir $DOTFILES_PATH/.git rev-list --all --count).$(git --git-dir $DOTFILES_PATH/.git rev-parse --short HEAD)$([[ -z "$(git --git-dir $DOTFILES_PATH/.git status --porcelain --untracked-files=no)" ]] || echo "+")

function dotman_help() {
    echo "$bold@abel0b$normal dotfiles manager $version"
    echo "github.com/abel0b"
    echo "Usage: $(basename $0) [command] [-V] [-f] [-v|-q]"
    echo
    echo "Commands:"
    echo "  sync    Link and copy dotfiles"
    echo "  unsync  Remove dotfiles"
    echo "  status  Show dotfiles status"
    echo "  help    Show help message"
    echo "  import  Import a dotfile"
    echo
    echo "Options:"
    echo "  -f      Remove existing destination files"
    echo "  -v      Enable verbose output"
    echo "  -q      Enable quiet output"
    echo "  -V      Show version number"

}

command=""
arguments=""
for token in "$@"
do
    case $token in
        -f|--force)
            force=true
            ;;
        -q|--quiet)
            verbosity=0
            ;;
        -v|--verbose)
            verbosity=2
            ;;
        -d|--debug)
            set -x
            ;;
        -V)
            echo $version
            exit 0
            ;;
        -*)
            echo -e "\e[31m[error]\e[0m Unknown option $token"
            exit
            ;;
        *)
            if [[ -z "$command" ]]
            then
                command=$token
            else
                arguments="$arguments $token"
            fi
            ;;
    esac
done

command=${command:-help}

if [[ "$command" =~ ^(${commands//[[:space:]]/\|})$ ]]
then
    dotman_$command $arguments
else
    echo "\e[31m[error]\e[0m Unknown command '$command'"
    echo
    dotman_help
fi
