#!/usr/bin/env bash

DOTFILES_PATH=${DOTFILES_PATH:-$(cd "$(dirname "${BASH_SOURCE[0]}")" > /dev/null 2>&1 && pwd)}
CACHE_PATH=${CACHE_PATH:-$DOTFILES_PATH/cache}
CONFIGS=$(ls -d $DOTFILES_PATH/base/*)

bold=$(tput bold)
normal=$(tput sgr0)

force=false
verbosity=1

function expand_home {
    echo "${1/#\~/$HOME}"
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
        "curl")
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

function sync() {
    config=$1
    if [ -f "$config/link.txt" ]
    then
        while read line
        do
            if [[ "$line" =~ ^[[:blank:]]*$ ]]
            then
                continue
            fi
            tokens=($line)
            target=${tokens[0]}
            linkname=$(expand_home ${tokens[1]})

            mkdir --parent $(dirname $linkname)

            if [[ $target =~ = ]]
            then
                destination=$CACHE_PATH/$(basename $config)/$(basename $linkname)
                fetch $target $destination
                (($? != 0)) && continue
                target=$destination
            else
                target=$config/$target
            fi

            if [[ -f $linkname || -L $linkname ]]
            then
                if [[ -L "$linkname" && "$(readlink $linkname)" = "$target" ]]
                then
                    :
                elif [[ "$force" = true ]]
                then
                    ln -sf --no-target-directory $target $linkname
                else
                    echo -e "\e[31m[error]\e[0m File already exists $linkname"
                    diff --color -u $linkname $target
                fi
            else
                ln -s --no-target-directory $target $linkname
            fi
        done < "$config/link.txt"
    fi

    if [ -f "$config/copy.txt" ]
    then
        while read line
        do
            if [[ "$line" =~ ^[[:blank:]]*$ ]]
            then
                continue
            fi

            tokens=($line)
            target=${tokens[0]}
            copyname=$(expand_home ${tokens[1]})

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

            if [[ -f $copyname || -L $copyname ]]
            then
                if diff -b -u $copyname $target
                then
                    :
                elif [[ "$force" = true ]]
                then
                    cp -f $target $copyname
                else
                    echo -e "\e[31m[error]\e[0m File already exists $copyname"
                    diff --color -u $copyname $target
                fi
            else
                cp $target $copyname
            fi
        done < "$config/copy.txt"
    fi

    if [ -f "$config/sync.sh" ]
    then
        source $config/sync.sh
    fi
}

function unsync() {
    config=$1
    if [ -f "$config/link.txt" ]
    then
        while read line
        do
            tokens=($line)
            linkname=$(expand_home ${tokens[1]})
            if [[ -L $linkname && $(readlink $linkname) == $target ]]
            then
                rm $linkname
            fi
        done < "$config/link.txt"
    fi

    if [ -f "$config/unsync.sh" ]
    then
        source $config/unsync.sh
    fi
}

function dotfiles_status() {
    if [[ ! -z "$1" ]]
    then
        CONFIGS=$(ls -d $(realpath $1)/*)
    else
        CONFIGS=$(ls -d $DOTFILES_PATH/base/* $DOTFILES_PATH/system/*)
    fi

    for dir in $CONFIGS
    do
        group=$(basename $(dirname $dir))
        echo $bold$group/$(basename $dir)$normal
        if [ -f "$dir/link.txt" ]
        then
            while read line
            do
                if [[ "$line" =~ ^[[:blank:]]*$ ]]
                then
                    continue
                fi
                tokens=($line)
                target=${tokens[0]}
                linkname=$(expand_home ${tokens[1]})

                if [[ $target =~ = ]]
                then
                    target=$CACHE_PATH/$(basename dir)/$(basename $linkname)
                else
                    target=$dir/$target
                fi

                if [[ -e $linkname && -L $linkname && $(readlink $linkname) == $target ]]
                then
                    echo -e "    \e[0;32m$linkname -> $target\e[0m"
                else
                    echo -e "    \e[0;31m$linkname ->\e[0m"
                fi
            done < "$dir/link.txt"
        fi

        if [ -f "$dir/copy.txt" ]
        then
            while read line
            do
                if [[ "$line" =~ ^[[:blank:]]*$ ]]
                then
                    continue
                fi
                tokens=($line)
                target=${tokens[0]}
                copyname=$(expand_home ${tokens[1]})

                if [[ $target =~ = ]]
                then
                    target=$CACHE_PATH/$(basename dir)/$(basename $copyname)
                else
                    target=$dir/$target
                fi

                if [[ -f $copyname ]]
                then
                    echo -e "    \e[0;32m$copyname =\e[0m"
                else
                    echo -e "    \e[0;31m$copyname =\e[0m"
                fi
            done < "$dir/copy.txt"
        fi
    done
    echo
    if [[ -f $CACHE_PATH/datesync.txt ]]
    then
        echo "last synced on $(cat $CACHE_PATH/datesync.txt)"
    else
        echo "not synced"
    fi
}


function dotfiles_sync() {
    mkdir --parent $CACHE_PATH

    if [[ ! -z "$1" ]]
    then
        CONFIGS=$(ls -d $(realpath $1)/*)
    fi

    for dir in $CONFIGS
    do
        echo -e "\e[32m+\e[0m $(basename $dir)"
        sync $dir
    done

    date > $CACHE_PATH/datesync.txt
}

function dotfiles_unsync() {
    for dir in $CONFIGS
    do
        echo -e "\e[31m-\e[0m $(basename $dir)"
        unsync $dir
    done

    rm -rf $CACHE_PATH
}

function dotfiles_system() {
    source $DOTFILES_PATH/system/sync.sh
}

function dotfiles_import() {
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

    mkdir -p $DOTFILES_PATH/base/$topic

    mv $dotfile $DOTFILES_PATH/base/$topic

    echo "$target $linkname" >> $DOTFILES_PATH/base/$topic/link.txt
}

function dotfiles_remove() {
    dotfile_path=$1
    dotfile=$(basename $1)
    config=$(dirname $dotfile_path)

    if [[ -L "$dotfile_path" ]]
    then
        dotfile_path=$(readlink $dotfile_path)
        dotfile=$(basename $dotfile_path)
        config=$(dirname $dotfile_path)
    fi

    rm -rf $dotfile_path

    if [ -f "$config/link.txt" ]
    then
        echo "$dotfile_path $dotfile $config"
        tokens=$(cat $config/link.txt | grep $dotfile)

        if [[ ! -z "$tokens" ]]
        then
            tokens=($tokens)
            echo $tokens
            linkname=$tokens[1]
            cat $config/link.txt | grep -v $dotfile | tee $config/link.txt
            if [[ -L "$linkname" ]]
            then
                rm $linkname
            fi
        fi
    fi
}

function dotfiles_path() {
    echo $DOTFILES_PATH
}

commands="sync unsync help status import remove path"
version=v$(git --git-dir $DOTFILES_PATH/.git rev-list --all --count).$(git --git-dir $DOTFILES_PATH/.git rev-parse --short HEAD)$([[ -z "$(git --git-dir $DOTFILES_PATH/.git status --porcelain --untracked-files=no)" ]] || echo "+")

function dotfiles_help() {
    echo "$bold@abel0b$normal dotfiles manager $version"
    echo "Usage: $(basename $0) [command] [-V] [-f] [-v|-q]"
    echo
    echo "Commands:"
    echo "  sync    Link and copy dotfiles"
    echo "  unsync  Remove dotfiles"
    echo "  status  Show dotfiles status"
    echo "  help    Show help message"
    echo "  import  Import a dotfile"
    echo "  remove  Remove a dotfile"
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
    dotfiles_$command $arguments
else
    echo "\e[31m[error]\e[0m Unknown command '$command'"
    echo
    dotfiles_help
fi
