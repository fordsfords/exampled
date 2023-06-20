#!/bin/bash
# exampled_check.sh - make sure daemon is still running; restart if need.

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

if [ ! -f "$ARGSFILE" ]; then :
  # No args file; daemon is disabled. Don't restart.
  exit
fi

PID=""
if [ -f "$PIDFILE" ]; then :
  PID=`cat $PIDFILE`
  RUNNING=`ps auxw | sed -n "/$COMMAND/s/^[^ ][^ ]*  *\($PID\).*/\1/p"`
  if [ "$RUNNING" = "$PID" ]; then :
    # Already running; don't restart.
    exit
  fi

  rm -f "$PIDFILE"
  if [ -f "$PIDFILE" ]; then :
    echo "ERROR, `date`: Could not remove $PIDFILE"
    exit 1
  fi
fi

rm -f $LOGFILE
if date >$LOGFILE; then :
else :
  echo "ERROR, `date`: Could not write to $LOGFILE"
  exit 1
fi

# Get the command-line parameters (with proper quoting) in the args file into $1 ...
ARGS=`cat $ARGSFILE`
eval set -- `cat $ARGSFILE`
setsid $TOOLDIR/$COMMAND "$@" >$LOGFILE 2>&1 </dev/null &
if [ "$?" -ne 0 ]; then :
  echo "ERROR, `date`: Could not start daemon. Here's the contents of $LOGFILE:"
  cat $LOGFILE
  exit 1
fi

# Wait no more than 5 seconds for daemon to start.
for I in {1..25}; do if [ ! -f "$PIDFILE" ]; then sleep 0.2; fi; done

if [ -f "$PIDFILE" ]; then :
  PID=`cat $PIDFILE`
  RUNNING=`ps auxw | sed -n "/$COMMAND/s/^[^ ][^ ]*  *\($PID\).*/\1/p"`
  if [ "$RUNNING" = "$PID" ]; then :
    exit
  fi

  echo "ERROR, `date`: daemon appeared to start, but no longer running? Here's the contents of $LOGFILE:"
  cat $LOGFILE
  exit 1
else :
  echo "ERROR, `date`: daemon could not start, or could not create $PIDFILE? Here's the contents of $LOGFILE:"
  cat $LOGFILE
  exit 1
fi

exit 0
