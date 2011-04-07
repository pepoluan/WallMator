#!/bin/bash

source /opt/wallmator/include/CONSTANTS.sh

source $incdir/MAKEBLOCKS.sh

ifaces_conf=$etcdir/interfaces.conf

declare -a interfaces
if ! [[ -f $ifaces_conf ]]; then
  cat - > $ifaces_conf <<__EOD
# interfaces.conf - WallMator configuration file for interfaces

# Space-separated list of interfaces to save/restore
interfaces=( $(ip -o link show | awk '!/loopback/ {gsub (/:/,"",$2); print $2}') )

# (Optional) Parameters per interface
# If an interface's parameter is not specified, then WallMator will not try to
# set the interface's parameter
eth0_parameters="txqueuelen 2000"

__EOD
fi
source $ifaces_conf

# Sanity sanitization - make sure we only process interfaces that exist
declare -a ifaces
local_ifaces="$(ip -o link show | awk '!/loopback/ {gsub (/:/,"",$2); print $2}')"
for i in ${interfaces[@]}; do
  [[ $local_ifaces =~ $i ]] && ifaces+=( $i  )
done

#declare -a interfaces=( $(ip -o link show | awk '!/loopback/ {gsub (/:/,"",$2); print $2}') )

# This function is just a shorthand to print out a line common for all interfaces
# The location where the interface name is to be substituted in is marked using a pair of braces {}
# (a la find)
ForAllInterfaces () {
  local i
  for i in ${ifaces[@]}; do
    printf "%s\n" "${1//\{\}/$i}"
  done
}

cat - <<__EOT
$WALLMATOR_scriptheader

# When sourced, this script will initialize all networking interfaces

WALLMATOR_STAGEBEGIN "Initializing network interfaces"

WALLMATOR_LOG "Downing interfaces"
__EOT

ForAllInterfaces "\$ip link set {} down || WALLMATOR_ERROR \"cannot down {}\""

echo '
WALLMATOR_LOG "Flushing addresses"'
ForAllInterfaces "\$ip address flush dev {} || WALLMATOR_ERROR \"cannot remove addresses of {}\""

echo '
WALLMATOR_LOG "Re-adding addresses"'
for i in ${ifaces[@]}; do
  while read ipmask; do
    printf "\$ip address add %18s brd + dev %s || WALLMATOR_ERROR \"cannot add %s to %s\"\n" $ipmask $i $ipmask $i
  done <<< "$(ip add sh dev $i | awk '$1=="inet" && $NF~/eth/ {print $2}')"
done

echo '
WALLMATOR_LOG "Setting parameters"'
for i in ${ifaces[@]}; do
  params="${i}_parameters"  # First, get the variable name in interfaces.conf
  params="${!params}"       # Then, indirectly get the variable's value
  [[ $params ]] && printf "\$ip link set $i $params || WALLMATOR_ERROR \"setting params for $i\"\n"
done

echo '
WALLMATOR_LOG "Upping interfaces"'
ForAllInterfaces "\$ip link set {} up || WALLMATOR_ERROR \"cannot up {}\""

echo "
$WALLMATOR_scriptfooter"

# Since we're the generating script, we *must* exit 0
exit 0

