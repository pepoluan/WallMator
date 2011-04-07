#!/bin/bash

source /opt/wallmator/include/CONSTANTS.sh

source $incdir/MAKEBLOCKS.sh

# This array lists IP sets that should not have its contents saved
# (will be auto-populated by iptables)
declare -a without_contents=( $(ipset --save | awk '/tree/ {print $2}') )

awkpattern="1"

for s in ${without_contents[@]}; do
  awkpattern+=" && !/A $s/"
done

cat - <<__EOT
$WALLMATOR_scriptheader

# When sourced, this script will restore the IP sets.
# Caution: The IP sets must be --flushed and --destroyed before sourcing this!

WALLMATOR_STAGEBEGIN "Restoring IP sets"

\$ipset --restore <<< "\\
$(ipset --save | awk "$awkpattern")
" || WALLMATOR_ERROR "cannot restore IPset"

$WALLMATOR_scriptfooter
__EOT

exit 0

