#!/bin/false

## THIS SCRIPT WILL BE SOURCED by wallmator.sh
## Do not execute directly!

# Point to location of progs
readonly ip="/sbin/ip"
readonly ipset="/usr/local/sbin/ipset"
readonly iptrest="/sbin/iptables-restore"

readonly chmod="/bin/chmod"
readonly date="/bin/date"
readonly mktmp="/bin/mktemp"
readonly awk="/usr/bin/awk"
readonly grep="/bin/grep"

WALLMATOR_ERROR=""

WALLMATOR_LOG () {
  printf "\n$($date +'%Y-%m-%d %H:%M:%S.%N') | %s" "$*" >> $logfile
}

WALLMATOR_ERROR () {
  WALLMATOR_STAGE_ERROR="$1"
  WALLMATOR_ERROR="1"  ## Any non-blank value
  WALLMATOR_LOG "ERROR: $1"
}

WALLMATOR_STAGEBEGIN () {
  WALLMATOR_STAGE_ERROR=""
  WALLMATOR_STAGE="$1"
  printf "\n$c   * $w$1 ... "
  WALLMATOR_LOG "[$1] begins"
}

WALLMATOR_STAGECOMPLETE () {
  if [[ -z $WALLMATOR_STAGE_ERROR ]]; then
    printf "${g}success.$n"
    WALLMATOR_LOG "[$WALLMATOR_STAGE] completes without error"
  else
    printf "${r}ERROR!$n"
    WALLMATOR_LOG "[$WALLMATOR_STAGE] completes with error(s)"
  fi
}

printf "\n $c*$w WALLMATOR$n - fireWALL autoMATOR - ${w}starting:$n"

WALLMATOR_LOG "WALLMATOR Starting"

for i in {00..99}; do
  for script in $start_scripts/${i}-*; do
    if [[ -f $script ]] ; then
      $chmod 0644 $script
      # Ensure no "exit" command in the sourced script
      $grep -E '(^ *exit)|(&& *exit)|(\|\| *exit)' $script ||
        source $script
    fi
  done
done

WALLMATOR_LOG "WALLMATOR Complete"

printf "\n $c*$w WALLMATOR$n - fireWALL autoMATOR - "
if [[ $WALLMATOR_ERROR ]]; then
  printf "${r}ERROR! Please check log: ${c}$logfile${n}\n\n"
  WALLMATOR_LOG "ERROR(S) HAPPENED; please check the log above"
else
  printf "${g}SUCCESS!${n}\n\n"
fi


## THIS FILE IS SOURCED!!
## DO NOT END WITH exit !!!
