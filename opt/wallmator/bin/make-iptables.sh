#!/bin/bash

source /opt/wallmator/include/CONSTANTS.sh

source $incdir/MAKEBLOCKS.sh

EmitFixedIptables () {
  __tmp1=$(mktemp)
  __tmp2=$(mktemp)

  # Reset chains' counters
  iptables-save | awk '/^:/ { gsub(/[0-9]+/,"0",$3) } {print $0}' > $__tmp1
  
  ## Let's check if we need bugfixing

    # First, check iptables' version (ties to iptables-save)
    iptver=($( iptables -V ))
    iptver="${iptver[1]}"
  
    while read what vers meth file comt; do
      [[ -z $what ]] && continue
      [[ ${what:0:1} == "#" ]] && continue
      if [[ "iptables-save" == $what ]]; then
        if [[ $iptver == $vers ]]; then
          case $meth in
            "awk")
              awk -f $etcdir/bugfix.d/$file $__tmp1 > $__tmp2
              # cp instead of mv to prevent error during cleanup
              cp $__tmp2 $__tmp1
              ;;
          esac
        fi
      fi
    done < $bugfixer_conf
  
  # Finally, we print out the temp file while escaping the quotes
  # (because this will be fed through a quoted constant)
  sed 's/"/\\"/g' $__tmp1
  
  # Cleanup
  rm -f $__tmp1 $__tmp2
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
