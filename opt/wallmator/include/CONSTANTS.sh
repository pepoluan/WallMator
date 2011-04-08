#!/bin/false

## THIS SCRIPT WILL BE SOURCED by various WallMator scripts
## Do not execute directly!

# When sourced, this script will set all common variables

WALLMATOR_version="0.1.0"

c="\x1B[1;36m"
g="\x1B[1;32m"
r="\x1B[1;41m"
w="\x1B[1;37m"
n="\x1B[m"

logfile="/var/log/wallmator.log"
start_scripts="/var/opt/wallmator/start-scripts"

bindir="/opt/wallmator/bin"
etcdir="/etc/opt/wallmator"
incdir="/opt/wallmator/include"

# Location of programs

chmod="/bin/chmod"
date="/bin/date"
mktmp="/bin/mktemp"
awk="/usr/bin/awk"
grep="/bin/grep"
rm="/bin/rm"

ip="/sbin/ip"
ipset="/usr/local/sbin/ipset"
iptrest="/sbin/iptables-restore"

SafeSource () {
  __temp=$($mktemp)
  # Get only actual parameters ...
  $grep -E '^[[:space:]]*[a-z0-9_]+=' "$1" |
    # ... and strip out embedded commands ...
    $grep -v -e '`' -e '$(' >
      # ... and stow it somewhere temporary
      $__temp
  source $__temp
  $rm -f $__temp
}

## THIS FILE IS SOURCED!!
## DO NOT END WITH exit !!!
