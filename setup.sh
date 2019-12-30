#!/usr/bin/env bash

DOTFILES_PATH=${DOTFILES_PATH:-$(pwd)}
CACHE_PATH=${CACHE_PATH:-$DOTFILES_PATH/cache}
CONFIGS=$(ls -d $DOTFILES_PATH/base/*)

bold=$(tput bold)
normal=$(tput sgr0)

force=false
verbosity=1

function expand_home {
    echo "${1/#\~/$HOME}"
}

function sync() {
    config=$1
    if [ -f "$config/link.txt" ]
    then
        while read line
        do
            if [[ "$line" =~ [[:blank:]]* ]]
            then
                continue
            fi
            tokens=($line)
            target=${tokens[0]}
            linkname=$(expand_home ${tokens[1]})

            echo "$target $linkname"
            mkdir --parent $(dirname $linkname)

            if [[ $target =~ "://" ]]
            then
                protocol=$(echo $target | cut -d : -f 1)
                case $protocol in
                    "http"|"https")
                        tmp=$CACHE_PATH/$(basename $linkname)
                        if [[ ! -f $tmp ]]
                        then
                            curl -LJ0 $target > $tmp
                        fi
                        target=$tmp
                        ;;
                    *)
                        echo -e "\e[31m[error]\e[0m Unknown protocol $protocol"
                        continue
                        ;;
                esac
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
            if [[ "$line" =~ [[:blank:]]* ]]
            then
                continue
            fi
            
            tokens=($line)
            target=${tokens[0]}
            copyname=$(expand_home ${tokens[1]})

            mkdir --parent $(dirname $copyname)

            if [[ $target =~ "://" ]]
            then
                protocol=$(echo $target | cut -d : -f 1)
                case $protocol in
                    "http"|"https")
                        tmp=$CACHE_PATH/$(basename $copyname)
                        if [[ ! -f $tmp ]]
                        then
                            curl -LJ0 $target > $tmp
                        fi
                        target=$tmp
                        ;;
                    *)
                        echo -e "\e[31m[error]\e[0m Unknown protocol $protocol"
                        continue
                        ;;
                esac
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
    if [[ -f $CACHE_PATH/datesync.txt ]]
    then
        echo "Dotfiles last synced on $(cat $CACHE_PATH/datesync.txt)"
    else
        echo "Dotfiles not synced"
    fi
    echo

    for dir in $CONFIGS
    do
        echo $bold$(basename $dir)$normal
        if [ -f "$dir/link.txt" ]
        then
            while read line
            do
                tokens=($line)
                target=${tokens[0]}
                linkname=$(expand_home ${tokens[1]})

                if [[ $target =~ "://" ]]
                then
                    protocol=$(echo $target | cut -d : -f 1)
                    case $protocol in
                        "http"|"https")
                            target=$CACHE_PATH/$(basename $linkname)
                            ;;
                        *)
                            echo -e "\e[31m[error]\e[0m Unknown protocol $protocol"
                            continue
                            ;;
                    esac
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
    done
}


function dotfiles_sync() {
    mkdir --parent $CACHE_PATH

    if [[ ! -z "$1" ]]
    then
        CONFIGS=$(ls -d $(realpath $1)/*)
    fi

    for dir in $CONFIGS
    do
        sync $dir
        echo -e "\e[32m+\e[0m $(basename $dir)"
    done

    date > $CACHE_PATH/datesync.txt
}

function dotfiles_unsync() {
    for dir in $CONFIGS
    do
        unsync $dir
        echo -e "\e[31m-\e[0m $(basename $dir)"
    done

    rm -rf $CACHE_PATH
}

function dotfiles_system() {
    source $DOTFILES_PATH/system/sync.sh
}

function dotfiles_import() {
    echo Feature not implemented
}

DOTFILES_COMMAND="sync unsync help status import"

function dotfiles_help() {
    echo "$bold@abel0b$normal dotfiles manager $(git rev-parse --short HEAD)"
    echo "Usage: $(basename $0) [command] [-f] [-v|-q]"
    echo
    echo "Commands:"
    echo "  sync    Link and copy dotfiles"
    echo "  unsync  Remove dotfiles"
    echo "  status  Show dotfiles status"
    echo "  help    Show help message"
    echo "  import  Import a dotfile"
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
        -*)
            echo "\e[31m[error]\e[0m Unknown option $token"
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

if [[ "$command" =~ ^(${DOTFILES_COMMAND//[[:space:]]/\|})$ ]]
then
    dotfiles_$command $arguments
else
    echo "\e[31m[error]\e[0m Unknown command '$command'"
    echo
    dotfiles_help
fi

