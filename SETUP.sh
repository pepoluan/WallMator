#!/bin/bash

CONSTANTS="opt/wallmator/include/CONSTANTS.sh"
TARGET="${TARGET:-/usr/local/sbin}"

if ! [[ -f $CONSTANTS ]]; then
  printf "\nI can't find $CONSTANTS!"
  printf "\nRun this script from the basedir of wallmator installer package.\n\n"
  exit 1
fi

source $CONSTANTS

printf "\nInstalling WallMator $WALLMATOR_version:"

MustExist () {
  if ! which $1 &> /dev/null; then
    printf "ERROR!\n\n'$1' does not seem to be installed."
    printf "\nWallMator depends on '$1'.\n\n"
    exit 2
  fi
}

printf "\n * Checking for sanity... "
  if ! [[ -f MANIFESTS ]]; then
    printf "ERROR!\n\nI can't find the MANIFESTS file. Can't continue."
    printf "\nIf you want to bypass sanity checking, do 'touch MANIFESTS' and"
    printf "\nrun this script again.\n\n"
    exit 1
  fi
  printf "iproute2:"
  MustExist ip
  printf "OK iptables:"
  MustExist iptables
  printf "OK ipset:"
  MustExist ipset
  printf "OK files:"
  while read fname hashval; do
    [[ -z $fname ]] && continue
    [[ ${fname:0:1} == "#" ]] && continue
    if ! [[ -f $fname ]] ; then
      printf "ERROR!\n\nI can't find %s . Can't continue.\n\n" "$fname"
      exit 1
    fi
  done < MANIFESTS
  printf "OK"

CreateDir () {
  if ! mkdir -p $1; then
    printf "ERROR!\n\nI can't create the $1 directory. Can't continue.\n\n"
    exit 3
  fi
}

printf "\n * Creating /opt directories... "
  CreateDir $bindir
  CreateDir $incdir
  CreateDir $skeldir/etc/bugfix.d
  printf "OK"

printf "\n * Creating /etc/opt directories... "
  CreateDir $etcdir/bugfix.d
  printf "OK"

printf "\n * Creating /var/opt directories... "
  CreateDir $startsdir
  printf "OK"

CopyFiles () {
  if ! cp -r $1 $2; then
    printf "ERROR!\n\nI can't copy the files from $1 to $2. Can't continue.\n\n"
    exit 4
  fi
}

printf "\n * Copying /opt files... "
  CopyFiles "opt/wallmator/*" $optdir
  chmod +x $bindir/*
  printf "OK"

printf "\n * Copying /etc/opt files... "
  CopyFiles "$optdir/skel/etc/*" $etcdir
  printf "OK"

printf "\n * Making symbolic link for wallmator.sh... "
  [[ -f $TARGET/wallmator ]] && rm -f $TARGET/wallmator
  if ! ln -s $bindir/wallmator.sh $TARGET/wallmator &> /dev/null; then
    printf "ERROR!\n\nI can't make symbolic link.\nYou have to make it yourself.\n"
  fi
  printf "OK"

printf "\n * Generating basic configuration files... "
  interfaces=( $(ip -o link show | awk '!/loopback/ {gsub (/:/,"",$2); printf $2 " "}') )
  cat - > $ifaces_conf <<__EOD__
# interfaces.conf - WallMator configuration file for interfaces

# Space-separated list of interfaces to save/restore
interfaces=( ${interfaces[@]} )

# (Optional) Parameters per interface
# If an interface's parameter is not specified, then WallMator will not try to
# set the interface's parameter
__EOD__
  for i in ${interfaces[@]}; do
    echo "${i}_parameters=\"\"" >> $ifaces_conf
  done
  printf "OK"

cat - <<__EOD__


Installation done. You still need to do the following things:
  1. Check $ifaces_conf file. Modify it to match your system.
  2. Modify $bugfixer_conf file according to your needs.
  3. Configure your IP sets, iptables rulesets, and RPDB/routing table(s)
  4. Run 'wallmator save'
  5. Modify your startup script(s) so that 'wallmator start' is invoked
     during boot.

If you have any feedback (suggestions, bugreports, etc), Create a New Issue
on GitHub: https://github.com/pepoluan/WallMator/issues

__EOD__

exit 0

Original INSTALL file content (placed here for reference):

HOW-TO INSTALL
==============

 1. Make directory /opt/wallmator
 2. Copy the contents of opt/wallmator (recursively) to your /opt/wallmator
 3. Make directory /etc/opt/wallmator
 4. Copy the contents of etc/opt/wallmator to your /etc/opt/wallmator
 5. Make directory /var/opt/wallmator/start-scripts
 6. Make a symbolic link in /usr/local/sbin to /opt/wallmator/bin/wallmator.sh

Yeah, the above should be made into a script, but I'm lazy... uh, I mean, I'll
get to it. Like Real Soon™. Yeah.

 7. Make your system execute "/opt/wallmator/bin/wallmator.sh start" during
    startup, after all network interfaces are up.

Now, with the proliferation of startup managers (upstart, systemd, initng, etc
etc etc), I can't possibly code for them all.

The only way I'm *sure* will work is to insert that line into /etc/rc.local
*just* before the "exit 0" line.

 8. Edit the /etc/opt/wallmator/bugfixer.conf file (info within the file)
 9. Configure your ipset, iptables, and iproute to your liking
10. Run "wallmator save"
11. Done
