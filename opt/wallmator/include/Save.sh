#!/bin/false

## THIS SCRIPT WILL BE SOURCED by wallmator.sh
## Do not execute directly!

buildscripts="
# make-<Method>  Target file <number>
  reset          00
  netinit        10
  ipset          20
  iptables       30
  iproute        40
"

### INTERNALS - DO NOT EDIT!!! ###

echo

while read method target; do
  [[ -z $method ]] && continue
  [[ ${method:0:1} == "#" ]] && continue
  printf "%b" " $c* ${n}Building $w$target-$method$n using ${w}make-$method$n... "
  _meth="$bindir/make-$method.sh"
  _targ="$start_scripts/$target-$method.sh"
  if $_meth > $_targ ; then
    printf "${g}OK$n\n"
  else
    printf "${r}ERROR!$n\n"
  fi
done <<< "$buildscripts"

echo

## THIS FILE IS SOURCED!!
## DO NOT END WITH exit !!!

