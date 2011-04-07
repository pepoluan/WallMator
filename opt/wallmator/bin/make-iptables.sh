#!/bin/bash

source /opt/wallmator/include/CONSTANTS.sh

source $incdir/MAKEBLOCKS.sh

awk_fixbug_script="$etcdir/iptables-save-fix.awk"

[[ -f $awk_fixbug_script ]] || cat - > $awk_fixbug_script <<__EOT
# This .awk script is used to fix iptables-save bugs
# Please customize this according to your need
#
# By default, this script contains just one line: { print }
# (Do not delete this line, or else iptables-save's output will be lost!
{ print }
__EOT

EmitFixedIptables () {
  iptables-save |
    # Reset chains' counters
    awk '/^:/ { gsub(/[0-9]+/,"0",$3) } {print $0}' |
    # Fix iptables-save bugs
    awk -f $awk_fixbug_script |
      # Escape the quotes (because this will be fed through a quoted constant)
      sed 's/"/\\"/g'
}

cat - <<__EOT
$WALLMATOR_scriptheader

# When sourced, this script will initialize the iptables ruleset

WALLMATOR_STAGEBEGIN "Loading iptables rulesets"

\$iptrest <<< "\\
__EOT

EmitFixedIptables

cat - <<__EOT
" || WALLMATOR_ERROR "cannot restore iptables"

$WALLMATOR_scriptfooter
__EOT

exit 0

## Below is the original version

echo "#!/bin/bash"

echo
echo 'readonly c="\x1B[1;36m"'
echo 'readonly g="\x1B[1;32m"'
echo 'readonly n="\x1B[m"'
echo "readonly iptrest=\"$(which iptables-restore)\" "

echo
echo 'printf "\n$c * ${HOSTNAME} : IPtables-Init... "'

echo
echo '$iptrest <<___END'
# The awk is to reset the chains' counters [xx:yy]
iptables-save |
  # Reset chains' counters
  awk '/^:/ { gsub(/[0-9]+/,"0",$3) } {print $0}' |
  # Fix iptables-save bugs
  awk -f /etc/opt/aeacus/fixbug.awk
echo "___END"

echo
echo 'printf "${g}done.$n\n\n"'

echo
echo "exit 0"

exit 0

