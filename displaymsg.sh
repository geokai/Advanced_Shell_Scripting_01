#!/bin/bash


# usage_message function
usagemsg_displaymsg () {

    printf "%b\n" "${1%%.*}  version: ${VERSION}  created: ${CREATED}"\
        ""\
        "Usage: ${1##*/} [-hvVc] [-m message]"\
        ""\
        "Print a default message, 'Hello, World!', or a user defined message."\
        ""\
        "  -m MESSAGE    Print the user defined MESSAGE and exit"\
        "                (MESSAGE must be 3 charaters or longer)"\
        "  -v            Verbose mode - displays ${1%%.*} version info"\
        "                and the default message"\
        "  -V            Very Verbose Mode - debug output displayed"\
        "  -c            Print the location of the script configuration file"\
        "  -h            Help - display this message and exit"\
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

    CFILE="${1}"
    if [[ -f ${CFILE} ]]; then
        (( VERBOSE == TRUE )) && printf "  %b\n" ""\
                                                 "# Configuration   file: ${CFILE}"\
                                                 "# Config file contents: $(cat ${CFILE})"\
                                                 ""
        # source config file
        . ${CFILE}
    else
        printf "  %b\n" ""\
                        "# Configuration file \"${CFILE}\" not found!"\
                        ""
        exit 2
    fi

    return 0
}  # end of configure_displaymsg function


################################################################


# main function
diplaymsg () {

    unset MSG
    declare TRUE="1"
    declare FALSE="0"
    declare VERBOSE="${FALSE}"
    declare VERYVERB="${FALSE}"
    declare CONF_LOC="$HOME/bin/Advanced_Shell_Scripting_01"
    declare CONF_FILE="${CONF_LOC}/.displaymsg.conf"

    declare -g VERSION="0.01.01"   # 0.00.00 - major.minor.patch
    declare -g AUTHOR="George Kaimakis"
    declare -g EMAIL="geoptus@gmail.com"
    declare -g REPO="http://github.com/geokai"
    declare -g CREATED="2018/12/19"


#### Process the command line options and arguments.

    while getopts ":hvVcm:" OPTION; do
        case "${OPTION}" in
            m) MSG="${OPTARG}";;
            v) VERBOSE="${TRUE}";;
            V) VERYVERB="${TRUE}";;
            c) printf "  %b\n" "" "# configuateion file: ${CONF_FILE}" ""\
               && return 0;;
            h) usagemsg_displaymsg "${0}" "${VERSION}" && return 1 ;;
            :) printf "  %b\n" "" "# missing argument(s)!" ""
               usagemsg_displaymsg "${0}" "${VERSION}" && return 1 ;;
            *) printf "  %b\n" "" "# unknown option: ${1}" ""
               usagemsg_displaymsg "${0}" "${VERSION}" && return 1 ;;
        esac
    done

    shift $(( ${OPTIND} - 1 ))


    (( VERYVERB == TRUE )) && set -x


#### Set up a trap of the HUP signal to cause this script
#### to dynamically configure or reconfigure itself upon
#### receipt of the HUP signal, if MSG is unset.

    if [[ -z ${MSG} ]]; then
        trap "configure_displaymsg ${CONF_FILE}" HUP
        kill -HUP ${$}
    fi

#### Read the configuration file and initialize variables by
#### sending this script a HUP signal



    trap 'usagemsg_displaymsg "${0}" "${VERSION}"' EXIT

    (( ${#MSG} < 3 )) && { ${GBL_ECHO} "\n  # Message too short!\n"; return 2; }

    trap "-" EXIT

    # verbose output
    (( VERBOSE  == TRUE )) && printf "  %b\n" ""\
                                              "# Version.......: ${VERSION}"\
                                              "# Content of MSG: ${MSG}"\
                                              "# Length  of MSG: ${#MSG}"\
                                              ""

    # print the message
    printf "  %s\n" ""\
                    "${MSG}"\
                    ""

    # disable the HUP trap
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

case "_${SHEBANG}" in
    _*/bash*)
        SHCODE="bash"
        ;;

    _*/ksh*)
        SHCODE="korn"
        ;;

    _*/zsh*)
        SHCODE="zshell"
        ;;

    *)
        SHCODE="sh"
        ;;
esac


#### 
#### Modify the commands and script according to the shell intpreter

case "_${SHCODE}" in
    _bash)
        shopt -s extglob    # turn on extended globing
        GBL_ECHO="printf"
        ;;

    _korn)
        GBL_ECHO="print --"
        ;;

    _zshell)
        GBL_ECHO="print --" && emulate ksh93
        ;;

    *)
        GBL_ECHO="echo -e"
        ;;
esac


#### 
#### Call the main script function to begin processing

diplaymsg "${@}"

exit ${?}
