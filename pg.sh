#!/usr/bin/env bash
#
# Generate password from a string and a file
#
#/ Usage:
#/   ./pg.sh [-s|-c|-x] [<length>]
#/
#/ Options:
#/   length          Optional, must be an integer inside range (0, 105]
#/                   Default length is 29
#/   -s              Optional, show result in terminal only
#/                   Default not show result, copy result to clipboard
#/   -c              Optional, make first letter uppercase
#/   -x              Optional, output hex chars
#/                   Default base64 chars
#/   -h | --help     Show usage message

set -e
set -u

usage() {
    printf "%b\n" "$(grep '^#/' "$0" | cut -c4-)" && exit 1
}

set_var() {
    [[ -z "${PG_FILE:-}" ]] && PG_FILE="$0"
    [[ -z ${_LENGTH:-} ]] &&_LENGTH=29
    _SEPERATOR="$"
    _SALT=$(sha512sum "$PG_FILE" | cut -d' ' -f 1)
}

hash() {
    # $1: string
    # $2: length
    # $3: first letter uppercase, true or false
    local h

    if [[ "${_HEX_OUT:-}" == true ]]; then
        h=$(echo -n "$1" \
            | sha512sum \
            | sed -E 's,.....,&'"$_SEPERATOR"',g' \
            | cut -c-"$2")
    else
        h=$(echo -n "$1" \
            | sha512sum \
            | xxd -r -p \
            | base64 \
            | tr '\n' ',' \
            | sed 's/,$/\n/;s/,//g' \
            | sed -E 's,.....,&'"$_SEPERATOR"',g' \
            | cut -c-"$2")
    fi

    if [[ "${3:-}" == true ]]; then
        local l
        l=$(get_first_letter "$h")

        if [[ -n "$l" ]]; then
            local i
            i=$(get_str_index "$h" "$l")

            if [[ $i -eq 0 ]]; then
                echo "$(echo "${h:i:1}" | tr '[:lower:]' '[:upper:]')${h:i+1}"
            elif [[ $((i+1)) -eq ${#h} ]]; then
                echo "${h:0:i}$(echo "${h:i:1}" | tr '[:lower:]' '[:upper:]')"
            else
                echo "${h:0:i}$(echo "${h:i:1}" | tr '[:lower:]' '[:upper:]')${h:i+1}"
            fi
        else
            echo "A${h:1}"
        fi
    else
        echo "$h"
    fi
}

get_first_letter() {
    #1: str
    echo "$1" | grep -o -E '[a-z]' | head -1
}

get_str_index() {
    #1: str
    #2: match
    local s
    s="${1%%$2*}"
    [[ "$s" == "$1" ]] && echo -1 || echo "${#s}"
}

set_args() {
    expr "$*" : ".*--help" > /dev/null && usage
    _UPPERCASE=false
    while getopts ":hscx" opt; do
        case $opt in
            s)
                _SHOW_IT=true
                ;;
            c)
                _UPPERCASE=true
                ;;
            x)
                _HEX_OUT=true
                ;;
            h)
                usage
                ;;
            \?)
                echo "Invalid option: -$OPTARG" >&2
                usage
                ;;
        esac
    done
    shift $((OPTIND-1))
    _LENGTH="$@"
}

get_platform() {
    local platform
    platform="$(uname -s)"

    if [[ "$platform" == *"inux"* ]]; then
        uname -a | awk '{print $NF}'
    elif [[ "$platform" == *"arwin"* ]]; then
        echo "macos"
    else
        echo "OS not support!" && exit 1
    fi
}

get_string() {
    local str
    echo -n "Enter a string: " >&2
    read -rs str
    echo "$str"
}

main() {
    set_args "$@"
    set_var

    local p s c
    c="${_LENGTH:-}"
    s=$(get_string)
    echo ""

    if [[ "${_SHOW_IT:-}" ]]; then
        hash "$s$_SALT" "$c" $_UPPERCASE
    else
        p=$(get_platform)
        if [[ "$p" == 'GNU/Linux' ]]; then
            hash "$s$_SALT" "$c" $_UPPERCASE | xclip -selection c
        fi

        if [[ "$p" == 'Android' ]]; then
            termux-clipboard-set "$(hash "$s$_SALT" "$c" $_UPPERCASE)"
        fi

        if [[ "$p" == 'macos' ]]; then
            hash "$s$_SALT" "$c" $_UPPERCASE | pbcopy
        fi
    fi
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
