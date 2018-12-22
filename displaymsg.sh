#!/bin/bash


# usage_message function
usagemsg_displaymsg () {

    printf "%b\n" "${1%%.*}  version: ${VERSION}  created: ${CREATED}"\
        ""\
        "Usage: ${1##*/} [-?vVc] [-m message]"\
        ""\
        "Print a default message, 'Hello, World!', or a user defined message."\
        ""\
        "  -m MESSAGE    Print the user defined MESSAGE and exit"\
        "                (MESSAGE must be 3 charaters or longer)"\
        "  -v            Verbose mode - displays ${1%%.*} version info"\
        "                and the default message"\
        "  -V            Very Verbose Mode - debug output displayed"\
        "  -c            Print the location of the script configuration file"\
        "  -?            Help - display this message and exit"\
        ""\
        "  If a message is not specified by the user, a default message"\
        "  is displayed as defined by the configuration file."\
        ""\
        ""\
        "This shell script is interpreted with the ${SHEBANG#*!} shell."\
        ""\
        "author: ${AUTHOR}"\
        "email : ${EMAIL}"\
        "repos : ${REPO}"\
        ""\
        "\"AutoContent\" enabled"\
        ""\

}   # end of usagemsg_displaymsg function


################################################################
#### 
#### Description:
#### 
#### Place a full text description of your shell function here.
#### 
#### Assumptions:
#### 
#### Provide a list of assumptions your shell function makes,
#### with a description of each assumption.
#### 
#### Dependencies:
#### 
#### Provide a list of dependencies your shell function has,
#### with a description of each dependency.
#### 
#### Products:
#### 
#### Provide a list of output your shell function produces,
#### with a description of each product.
#### 
#### Configured Usage:
#### 
#### Describe how your shell function should be used.
#### 
#### Details:
#### 
################################################################


# function to invoke the sourcing of the confuguration file
configure_displaymsg() {

#### 
#### Notice this function is a POSIX function so that it can see local
#### and global variables from calling functions and scripts.
#### 
#### Configuration parameters can be stored in a file and
#### this script can be dynamically reconfigured by sending
#### the running script a HUP signal using the kill command.
#### 
#### Configuration variables can be defined in the configuration file using
#### the same syntax as defining a shell variable, e.g.: VARIABLE="value"

    CFILE=./.displaymsg.conf

    (( VERBOSE == TRUE )) && printf "# Configuration File: ${CFILE}\n"

    if [[ -f ${CFILE} ]]; then
        (( VERBOSE == TRUE )) && cat ${CFILE}
        . ${CFILE}
    fi

    return 0
}  # end of configure_displaymsg function


################################################################


# main function
diplaymsg () {

    declare VERSION="0.01"
    declare TRUE="1"
    declare FALSE="0"
    declare VERBOSE="${FALSE}"
    declare VERYVERB="${FALSE}"
    declare -g AUTHOR="George Kaimakis"
    declare -g EMAIL="geoptus@gmail.com"
    declare -g REPO="http://github.com/geokai"
    declare -g CREATED="2018/12/19"

#### Set up a trap of the HUP signal to cause this script
#### to dynamically configure or reconfigure itself upon
#### receipt of the HUP signal.

    trap "configure_displaymsg ${0}" HUP

#### Read the configuration file and initialize variables by
#### sending this script a HUP signal

    kill -HUP ${$}


#### Process the command line options and arguments.

    while getopts ":vVm:" OPTION; do
        case "${OPTION}" in
            'm') MSG="${OPTARG}";;
            'v') VERBOSE="${TRUE}";;
            'V') VERYVERB="${TRUE}";;
            '?') usagemsg_displaymsg "${0}" "${VERSION}" && return 1 ;;
            ':') usagemsg_displaymsg "${0}" "${VERSION}" && return 1 ;;
            '#') usagemsg_displaymsg "${0}" "${VERSION}" && return 1 ;;
        esac
    done

    shift $(( ${OPTIND} - 1 ))


    trap 'usagemsg_displaymsg "${0}" "${VERSION}"' EXIT

    (( ${#MSG} < 3 )) && return 2

    trap "-" EXIT

    ## TODO: roll the VERBOSE tests into one:
    (( VERYVERB == TRUE )) && set -x
    (( VERBOSE  == TRUE )) && printf "# Version........: ${VERSION}\n"
    (( VERBOSE == TRUE )) && printf "%s\n" "# Content of MSG: ${MSG}"
    (( VERBOSE == TRUE )) && printf "%s\n" "# Length  of MSG: ${#MSG}"

    printf "  %s\n" "${MSG}"

    trap "-" HUP

    return 0
}   # end of main function: displaymsg


################################################################
################################################################
################################################################
#### 
#### Main Body of Script Begins Here
#### 
################################################################


#### 
#### Extract the "shebang" line from the beginning of the script

read SHEBANG < "${0}"
export SHEBANG

#### 
#### Test the "shebang" line to determine what shell interpreter is specified

SHCODE="unknown"
[[ "_${SHEBANG}" == _*/ksh*  ]] && SHCODE="korn"
[[ "_${SHEBANG}" == _*/bash* ]] && SHCODE="bash"
[[ "_${SHEBANG}" == _*/zsh*  ]] && SHCODE="zshell"
export SHCODE

#### 
#### Modify the commands and script according to the shell intpreter

GBL_ECHO="echo -e"
[[ "_${SHCODE}" == "_korn"   ]] && GBL_ECHO="print --"
[[ "_${SHCODE}" == "_zshell" ]] && GBL_ECHO="print --" && emulate ksh93
[[ "_${SHCODE}" == "_bash"   ]] && shopt -s extglob    # Turn on extended globbing


#### 
#### Call the main script function to begin processing

diplaymsg "${@}"

exit ${?}
