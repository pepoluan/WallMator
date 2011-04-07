#!/bin/bash

source /opt/wallmator/include/CONSTANTS.sh

Show_Help () {
  printf "\n%b\n" "\
${w}wallmator$n - ${c}fireWALL autoMATOR$n

Syntax:
    $w$0$n $c<command>$n

$c<command>$n can be:

    ${w}start$n
        Starts the firewall system (ifaces, ipsets, iptables, iproutes)

    ${w}save$n
        Saves the current firewall state

    ${w}help$n
        Prints this help

Unknown command will be assumed as '${w}help$n'
"
}

command=${1:-help}

case $command in
  start)
    chainto="Start.sh"
    ;;
  save)
    chainto="Save.sh"
    ;;
  help)
    Show_Help
    ;;
esac

[[ $chainto ]] && source $incdir/$chainto

exit 0

