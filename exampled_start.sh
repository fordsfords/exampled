#!/bin/bash
# exampled_start.sh - Start daemon.

# This code and its documentation is Copyright 2022-2023 Steven Ford
# and licensed "public domain" style under Creative Commons "CC0":
#   http://creativecommons.org/publicdomain/zero/1.0/
# To the extent possible under law, the contributors to this project have
# waived all copyright and related or neighboring rights to this work.
# In other words, you can use this code for any purpose without any
# restrictions.  This work is published from: United States.  The project home
# is https://github.com/fordsfords/exampled

# See https://github.com/fordsfords/exampled for more information.

TOOLDIR="`dirname ${BASH_SOURCE[0]}`"
COMMAND="exampled.sh"
CMD="exampled"
ARGSFILE="/tmp/$CMD.args"
PIDFILE="/tmp/$CMD.pid"
LOGFILE="/tmp/$CMD.log"  # This file won't be used unless there are errors.

if [ "$#" -gt 1 ]; then :
  echo "ERROR `date`, place daemon arguments inside single quotes."
  exit 1
fi

PID=""
if [ -f "$PIDFILE" ]; then :
  PID=`cat $PIDFILE`
  RUNNING=`ps auxw | sed -n "/$COMMAND/s/^[^ ][^ ]*  *\($PID\).*/\1/p"`
  if [ "$RUNNING" = "$PID" ]; then :
    echo "Daemon already running with PID $PID"
    echo "If you want to change the arguments, use $CMD_stop.sh first."
    exit 0
  fi

  echo "Warning `date`: $PIDFILE exists, contains '$PID', but not running. Deleting..."
  rm -f "$PIDFILE"
  if [ -f "$PIDFILE" ]; then :
    echo "ERROR: Could not remove $PIDFILE"
    exit 1
  fi
fi

if [ "$#" -eq 1 ]; then :
  # New set of arguments supplied, use them.
  if echo "$1" >"$ARGSFILE"; then :
  else :
    echo "ERROR: could not write to $ARGSFILE"
    exit 1
  fi
  rm -f "$ARGSFILE.stopped"
else :
  # No arguments passed. If there's an args file, or a ".stopped"
  # args file, use it. Otherwise, create an empty args file.
  if [ -f "$ARGSFILE" ]; then :
    # Already an args file, don't need the ".stopped" one (if any).
    rm -f "$ARGSFILE.stopped"
  else :
    # No args file, check for ".stopped".
    if [ -f "$ARGSFILE.stopped" ]; then :
      # Use the ".stopped" args file.
      if mv "$ARGSFILE.stopped" "$ARGSFILE"; then :
        echo "Using $ARGSFILE.stopped"
      else :
        echo "ERROR: could not rename $ARGSFILE.stopped to $ARGSFILE"
        exit 1
      fi
    else :
      # No args file or ".stopped" args file. Create empty one.
      if echo "" >"$ARGSFILE"; then :
        echo "Created empty $ARGSFILE"
      else :
        echo "ERROR: could not create an empty $ARGSFILE"
        exit 1
      fi
    fi
  fi
fi

# Args file set up; start daemon.
if $TOOLDIR/exampled_check.sh; then :
  echo "Good: daemon started, PID=`cat $PIDFILE`"
fi

exit 0
