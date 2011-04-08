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

# Directories

optdir="/opt/wallmator"
bindir="$optdir/bin"
incdir="$optdir/include"

etcdir="/etc/opt/wallmator"

vardir="/var/opt/wallmator"
startsdir="$vardir/start-scripts"

# Files
logfile="/var/log/wallmator.log"
ifaces_conf="$etcdir/interfaces.conf"
bugfixer_conf="$etcdir/bugfixer.conf"

# Location of programs

chmod="/bin/chmod"
date="/bin/date"
mktemp="/bin/mktemp"
awk="/usr/bin/awk"
grep="/bin/grep"
rm="/bin/rm"

ip="/sbin/ip"
ipset="/usr/local/sbin/ipset"
iptrest="/sbin/iptables-restore"

SafeSource () {
  __temp=$($mktemp)
  # Get only actual parameters and strip out embedded commands
  $grep -E '^[[:space:]]*[a-z0-9_]+=' "$1" | $grep -v -e '\`' -e '$(' > $__temp
  source $__temp
  $rm -f $__temp
}

## THIS FILE IS SOURCED!!
## DO NOT END WITH exit !!!
