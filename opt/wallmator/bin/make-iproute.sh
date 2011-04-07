#!/bin/bash

source /opt/wallmator/include/CONSTANTS.sh

source $incdir/MAKEBLOCKS.sh

rulelist="$(ip rule sh | awk '$1!="0:" && $1!="32766:" && $1!="32767:" && !x[$0]++ {gsub (/:/,"",$1); print $0}')"

cat - <<__EOT
$WALLMATOR_scriptheader

# When sourced, this script will restore the RPDB and routing tables

WALLMATOR_STAGEBEGIN "Building routing table"

### Rules ###

WALLMATOR_LOG "Populating RPDB"
__EOT


## Emit Rules
  while read ord rule; do
    printf "    \$ip rule add order %3s %s ||\n        WALLMATOR_ERROR \"adding order # %s\"\n" "$ord" "$rule" "$ord"
  done <<< "$(ip rule sh | awk '$1!="0:" && $1!="32766:" && $1!="32767:" && !x[$0]++ {gsub (/:/,"",$1); print $0}')"
  echo


## Emit Routes
  printf "### Routes ###\n\n"
  for table in $(ip rule | awk '$NF!="local" && $NF!="main" && $NF!="default" && !x[$NF]++ {print $NF}'); do
    echo "WALLMATOR_LOG \"Populating routing table: $table\""
    while read r; do
      [[ -z "$r" ]] && continue
      echo "    \$ip route add $r table $table ||"
      echo "        WALLMATOR_ERROR \"insert route ${r%% *} into $table\""
    done <<< "$(ip route show table $table)"
    echo
  done

echo "$WALLMATOR_scriptfooter"

exit 0

echo "#!/bin/bash"

echo
echo 'readonly c="\x1B[1;36m"'
echo 'readonly g="\x1B[1;32m"'
echo 'readonly n="\x1B[m"'
echo "readonly ip=\"$(which ip)\""

echo
echo 'printf "\n$c * ${HOSTNAME} : iproute2-init... "'

echo
echo "# Rules"
ip rule | awk '$1!="0:" && $1!="32766:" && $1!="32767:" && !x[$0]++ {gsub(/:/,"",$1); print "$ip rule add order",$0}'

echo
echo "# Routes"
for t in $(ip rule | awk '$NF!="local" && $NF!="main" && $NF!="default" && !x[$NF]++ {print $NF}'); do
  echo "# == table: $t"
  while read r; do
    [[ -z "$r" ]] && continue
    echo "\$ip route add $r table $t"
  done <<< "$(ip route show table $t)"
done

echo
echo 'printf "${g}done.$n\n\n"'

echo
echo "exit 0"

exit 0

