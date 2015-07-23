#!/usr/bin/env bash

# Execute command as user.
# Example: execAs kostas "mkdir "$KERNDEV_HOME""
runAs ()
{
  if [ "$#" -ne 2 ];
  then
    echo "usage: runAs [user] [command]"
    return 1;
  fi
  su -c "$2" - "$1"
}

# Displays parameteters with command name prepended, outputted to stderr.
# $@: message to display.
error ()
{
  echo $(basename $0): $@ >&2
}

# Displays parameteters with command name prepended, outputted to stderr, then
# exits with error status.
# $@: message to display.
fatal ()
{
  error $@
  exit 1
}

# Pushes directory onto pushd stack without outputting anything.
# $1: Directory to add to pushd stack.
push ()
{
  pushd $1 >/dev/null
}

# Pops directory off pushd stack without outputting anything.
pop ()
{
  popd &>/dev/null || true
}

# Attempt to unmount, ignore any failures.
unmount ()
{
  # This _can_ be dangerous, theoretically, but this is usually shortly
  # followed by an attempt at a mount, which if the unmount fails, will
  # also fail and end the script with an error.
  if [ "$#" -ne 1 ];
  then
    return 1;
  fi

  umount "$1" &>/dev/null || true
}
