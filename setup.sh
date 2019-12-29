#!/usr/bin/env bash

DOTFILES=${DOTFILES:-$(pwd)}
CACHE_DIRECTORY=${CACHE_DIRECTORY:-$DOTFILES/cache}

function expand_home {
    echo "${1/#\~/$HOME}"
}

function list() {
    for dir in $(ls config)
    do
        echo $dir
    done
}

function status() {
    for dir in $(ls $DOTFILES/config)
    do
        echo $dir
        if [ -f "$DOTFILES/config/$dir/link.txt" ]
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
                            target=$CACHE_DIRECTORY/$(basename $linkname)
                            ;;
                        *)
                            echo -e "\e[31m[error]\e[0m Unknown protocol $protocol"
                            continue
                            ;;
                    esac
                else
                    target=$DOTFILES/config/$target
                fi

                if [[ -e $linkname && -L $linkname && $(readlink $linkname) == $target ]]
                then
                    echo -e "    \e[0;32m$linkname -> $target\e[0m"
                else
                    echo -e "    \e[0;31m$linkname ->\e[0m"
                fi
            done < "$DOTFILES/config/$dir/link.txt"
        fi
    done
}


function link() {
    if [ -f "$DOTFILES/config/$1/link.txt" ]
    then
        while read line
        do
            tokens=($line)
            target=${tokens[0]}
            linkname=$(expand_home ${tokens[1]})

            mkdir --parent $(dirname $linkname)

            if [[ $target =~ "://" ]]
            then
                protocol=$(echo $target | cut -d : -f 1)
                case $protocol in
                    "http"|"https")
                        tmp=$CACHE_DIRECTORY/$(basename $linkname)
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
                target=$DOTFILES/config/$target
            fi

            if [ -e $linkname ]
            then
                if [[ -L $linkname && $(readlink $linkname) == $target ]]
                then
                    :
                else
                    echo -e "\e[31m[error]\e[0m File already exists $linkname"
                    diff --color -u $linkname $target
                fi
            else
                ln -s --no-target-directory $target $linkname
            fi
        done < "$DOTFILES/config/$1/link.txt"
    fi
}

function unlink() {
    if [ -f "$DOTFILES/config/$1/link.txt" ]
    then
        while read line
        do
            tokens=($line)
            linkname=$(expand_home ${tokens[1]})
            rm -f $linkname
        done < "$DOTFILES/config/$1/link.txt"
    fi
}

function sync() {
    mkdir --parent cache

    for dir in $(ls config)
    do
        link $dir
        echo -e "\e[32m+\e[0m $dir"
    done
}

function unsync() {
    for dir in $(ls config)
    do
        unlink $dir
        echo -e "\e[31m-\e[0m $dir"
    done

    rm -rf cache
}

function system() {
    $DOTFILES/system/sync.sh
}

function help() {
    echo "@abel0b dotfiles $(git rev-parse --short HEAD)"
    echo "Usage: $0 (sync|unsync|setup|status)"
    echo
    echo "Commands:"
    echo "  sync    Link and copy dotfiles"
    echo "  unsync  Remove dotfiles"
    echo "  status  Show dotfiles status"
    echo "  system  Configure system"
    echo "  help    Show help message"
}

command=$1
if [[ "$command" =~ ^(sync|unsync|system|status)$ ]]
then
    $command $2
else
    help
fi
