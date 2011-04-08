# This .awk script is used to fix iptables-save bugs
# Note that the rules here are customized; it might not apply
# when the whole iptables ruleset is changed
/^\*/ {table=$1}
# This is the fix for iptables-save 1.4.4 bug
# where --ctstate does not have its arg
table=="*mangle" && $2=="PREROUTING" && $5=="--ctstate" {
  $5="--ctstate UNTRACKED"
  }
{print $0}

