#!/usr/bin/ksh93
#!/bin/zsh
#!/bin/bash
################################################################
#### 
#### This script will run in KornShell93, Zshell, or Bash, all you need to do 
#### is put the desired "shebang" line at the top of the script.
#### 
################################################################
function usagemsg_your_function {
  CMD_ECHO="${GBL_ECHO:-echo -e }"
  [[ "_${SHCODE}" == "_korn" ]] && typeset CMD_ECHO="${GBL_ECHO:-echo -e }"
  [[ "_${SHCODE}" == "_bash" ]] && declare CMD_ECHO="${GBL_ECHO:-echo -e }"
  ${CMD_ECHO} ""
  ${CMD_ECHO} "${1:+Program: ${1}}${2:+        Version: ${2}}"

  ${CMD_ECHO} "
Place a brief description ( < 255 chars ) of your shell
function here.

Usage: ${1##*/} [-?vV] 

  Where:
    -v = Verbose mode - displays your_function function info
    -V = Very Verbose Mode - debug output displayed
    -? = Help - display this message

Author: Your Name (YourEmail@address.com)

\"AutoContent\" enabled
\"Multi-Shell\" enabled
"
}
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
#### Place nothing here, the details are your shell function.
#### 
################################################################
configure_your_function()
{
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

  CFILE=~/.your_function.conf

  (( VERBOSE == TRUE )) && ${CMD_ECHO} "# Configuration File: ${CFILE}"

  if [[ -f ${CFILE} ]]
  then
      (( VERBOSE == TRUE )) && cat ${CFILE}
      . ${CFILE}
  fi

  return 0
}  
################################################################
function your_function {

if [[ "_${SHCODE}" == "_korn"   ]] ||
   [[ "_${SHCODE}" == "_zshell" ]]
then
  typeset VERSION="1.0"
  typeset TRUE="1"
  typeset FALSE="0"
  typeset VERBOSE="${FALSE}"
  typeset VERYVERB="${FALSE}"
  typeset CMD_ECHO="${GBL_ECHO:-echo -e }"
elif [[ "_${SHCODE}" == "_bash" ]]
then
  declare VERSION="1.0"
  declare TRUE="1"
  declare FALSE="0"
  declare VERBOSE="${FALSE}"
  declare VERYVERB="${FALSE}"
  declare CMD_ECHO="${GBL_ECHO:-echo -e }"
else
  VERSION="1.0"
  TRUE="1"
  FALSE="0"
  VERBOSE="${FALSE}"
  VERYVERB="${FALSE}"
  CMD_ECHO="${GBL_ECHO:-echo -e }"
fi

#### Set up a trap of the HUP signal to cause this script
#### to dynamically configure or reconfigure itself upon
#### receipt of the HUP signal.

  trap "configure_your_function ${0}" HUP

#### Read the configuration file and initialize variables by
#### sending this script a HUP signal

  kill -HUP ${$}

#### Process the command line options and arguments.

  while getopts ":vV" OPTION
  do
      case "${OPTION}" in
          'v') VERBOSE="${TRUE}";;
          'V') VERYVERB="${TRUE}";;
          '?') usagemsg_your_function "${0}" "${VERSION}" && return 1 ;;
          ':') usagemsg_your_function "${0}" "${VERSION}" && return 1 ;;
          '#') usagemsg_your_function "${0}" "${VERSION}" && return 1 ;;
      esac
  done
   
  shift $(( ${OPTIND} - 1 ))
  
  trap "usagemsg_your_function ${0} ${VERSION}" EXIT

#### Place any command line option error checking statements
#### here.  If an error is detected, print a message to
#### standard error, and return from this function with a
#### non-zero return code.  The "trap" statement will cause
#### the "usagemsg" to be displayed.

  trap "-" EXIT
  
  (( VERYVERB == TRUE )) && set -x
  (( VERBOSE  == TRUE )) && ${CMD_ECHO} "# Version........: ${VERSION}"

################################################################

####
#### Your shell function should perform it's specfic work here.
#### All work performed by your shell function should be coded
#### within this section of the function.  This does not mean that
#### your function should be called from here, it means the shell
#### code that performs the work of your function should be 
#### incorporated into the body of this function.  This should
#### become your function.
#### 

  ${CMD_ECHO} "# MSG = ${MSG}"

#### If you need to define array values inside a while or until loop, and you
#### read input from a file, redirect input into the while loop instead of
#### using a pipe. Bash requires this syntax if you need the array values to
#### be visible outside of the loop.

  trap "-" HUP

  return 0
}
################################################################
################################################################
################################################################
#### 
#### Main Body of Script Begins Here
#### 
################################################################

TRUE="1"
FALSE="0"

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
#### Call the script function to begin processing

your_function "${@}"

exit ${?}


