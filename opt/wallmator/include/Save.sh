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

declare -a unsafe_files=( $(grep --files-with-matches -E '(^ *exit)|(&& *exit)|(\|\| *exit)' $start_scripts/*) )

if [[ $unsafe_files ]]; then
  printf "\n${r}WARNING:${n} Unsafe files are found!\nThese will not be run by wallmator start:"
  for f in ${unsafe_files[@]}; do
    printf "\n ${r}* ${c}$f${n}"
  done
  printf "\n\n"
fi

## THIS FILE IS SOURCED!!
## DO NOT END WITH exit !!!

