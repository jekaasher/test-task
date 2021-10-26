#!/bin/bash
# Step 1 : Bash internal configuration

set -o nounset    # no undefined variables
set -o pipefail   # internal pipe failures cause an exit

#bash prompt internal configuration
declare BD=""
declare NBD=""
declare BLUE=""
declare NBLUE=""
declare RED=""
declare NRED=""
declare YELL=""
declare NYELL=""
# Test if stdout and stderr are open to a terminal
if [[ -t 1 ]]; then
  BD=$(tput bold)
  NBD=$(tput sgr0)
fi
if [[ -t 2 ]]; then
  BLUE=$(tput setaf 6)
  NBLUE=$(tput sgr0)
fi
if [[ -t 2 ]]; then
  RED=$(tput setaf 1)
  NRED=$(tput sgr0)
fi
if [[ -t 2 ]]; then
  YELL=$(tput setaf 2)
  NYELL=$(tput sgr0)
fi

#-------------------------------------------------------------------------------
#
# Step 2 : Global variables
# here shoul be enviroment varieble
declare FILE_PATH=""
declare OUT_FILE=""
#-------------------------------------------------------------------------------
#

function error() {
  local lineno=$1
  shift
  if [[ -n "$lineno" ]]; then
    printf "${BD}ERROR${NBD} (line:$lineno) : ${*//%/%%}\n" 1>&2
  else
    printf "${BD}ERROR${NBD} : ${*//%/%%}\n" 1>&2
  fi
}

function warning() {
  local lineno=$1
  shift
  if [[ -n "$lineno" ]]; then
    printf "${YELL}WARNING${NYELL} (line:$lineno) : ${*//%/%%}\n" 1>&2
  else
    printf "${YELL}WARNING${NYELL}: ${*//%/%%}\n" 1>&2
  fi
}

function dump_arguments() {
  local arg_list=""
  for arg do
    arg_list+=" '$arg'"
  done
  echo $arg_list
}

function help() {
  local path=$0
  cat << EOF
Usage: ${path##*/} [ options ]
Options:

  --help, -h                         Dispalys this help text.

EOF
}

function convert_to_csv() {

if ( "$FILE_PATH" == "" )
then
        FILE_PATH="/var/log/nginx/access.log"
fi
if ( "$OUT_FILE" == "" )
then
        OUT_FILE="resault.csv"
fi

echo "Date | Hostname | Threat | DATE+time | Critical/High | Count | --- | External IP | Internal IP | TCP/UDP | Port | External Port | Category | Vulnerability" > $OUT_FILE

< $FILE_PATH awk '{print $1" "$2" "$3 " | " $4 " | " $5 " | " $6" "$7 " | " $8" "$9" "$10 " | " $11" "$12 " | " $13" "$14 " | " $15" "$16 " | " $17 " | " $18 " | " $19" "$20" "$21" "$22" "$23" "$24}' >> $OUT_FILE
}

function parse_args() {
  local go_out=""

  # TODO: kennt, what happens if we don't have a functional getopt()?
  # Check if we have a functional getopt(1)
  if ! getopt --test; then
    go_out="$(getopt --options=edv --longoptions=help,h,file-path:,out-file: --name="$(basename "$0")" -- "$@")"
    eval set -- "$go_out"
  fi
  if [[ $go_out == " --" ]];then
    help
    exit 1
  fi

  for arg
  do
    case "$arg" in
      -- )
        shift
        break
        ;;
      --h|--help)
        help
        exit 0
        ;;
     --file-path)
        FILE_PATH=$2
        shift 2
        ;;
     --out-file)
        OUT_FILE=$2
        shift 2
        ;;
       *)
        shift
        ;;
    esac
  done
}
parse_args "$@"
convert_to_csv