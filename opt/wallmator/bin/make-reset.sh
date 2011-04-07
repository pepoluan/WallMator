#!/bin/bash

source /opt/wallmator/include/CONSTANTS.sh

source $incdir/MAKEBLOCKS.sh

cat - <<__EOT
$WALLMATOR_scriptheader

# When sourced, this script will reset all tables and interfaces

routing_tables=(
__EOT

#while read num name; do
#  [[ -z $num ]] && continue ## Skip blank lines
#  [[ ${num:0:1} == "#" ]] && continue ## Skip comments
#  echo "  \"$name\""
#done < $conf_tables

while read name; do
  echo "  \"$name\""
done <<< "$(ip rule | awk '$1!="0:" && $1!="32766:" && $1!="32767:" && !x[$NF]++ {print $NF}')"

cat - <<__EOT
)

WALLMATOR_STAGEBEGIN "Resetting states"

WALLMATOR_LOG "Flushing RPDB"
\$ip rule flush || WALLMATOR_ERROR "ip rule flush"

WALLMATOR_LOG "Flushing routing tables"
for table in \${routing_tables[@]}; do
  \$ip route flush table \$table || WALLMATOR_ERROR "ip route flush \$table"
done

WALLMATOR_LOG "iptables reset"
\$iptrest <<< "\
*nat
:PREROUTING ACCEPT [0:0]
:POSTROUTING ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
COMMIT
*mangle
:PREROUTING ACCEPT [0:0]
:INPUT ACCEPT [0:0]
:FORWARD ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
:POSTROUTING ACCEPT [0:0]
COMMIT
*raw
:PREROUTING DROP [0:0]
:OUTPUT ACCEPT [0:0]
COMMIT
*filter
:INPUT DROP [0:0]
:FORWARD DROP [0:0]
:OUTPUT ACCEPT [0:0]
COMMIT
" || WALLMATOR_ERROR "during iptables reset"

WALLMATOR_LOG "ipset reset"
\$ipset -F || WALLMATOR_ERROR "during ipset flush"
\$ipset -X || WALLMATOR_ERROR "during ipset destroy"

$WALLMATOR_scriptfooter
__EOT

exit 0

