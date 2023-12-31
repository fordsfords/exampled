#!/bin/bash
# exampled_status.sh - tells you if daemon is running or not.

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

STATUS=0
PID=""
if [ -f "$PIDFILE" ]; then :
  if [ ! -f "$ARGSFILE" ]; then :
    echo "Warning: $PIDFILE exists but $ARGSFILE not."
    STATUS=1
  fi
  PID=`cat $PIDFILE`
  RUNNING=`ps auxw | sed -n "/$COMMAND/s/^[^ ][^ ]*  *\($PID\).*/\1/p"`
  if [ "$RUNNING" = "$PID" ]; then :
    echo "Daemon is running with PID $PID."
    echo "Options:"; cat "$ARGSFILE"
    exit $STATUS
  fi
  echo "Warning: PID $PID does not appear to be running, but $PIDFILE thinks it should be."
  STATUS=1
  exit $STATUS
fi

if [ -f "$ARGSFILE" ]; then :
  echo "Warning: $PIDFILE does not exist but $ARGSFILE does."
  STATUS=1
fi

echo "Daemon not running."
if [ -f "$ARGSFILE.stopped" ]; then :
  echo "Saved options:"; cat "$ARGSFILE.stopped"
fi

exit $STATUS
