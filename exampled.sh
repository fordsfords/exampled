#!/bin/bash
# exampled.sh - Generic daemon script with rolling output file.

# This code and its documentation is Copyright 2022-2023 Steven Ford
# and licensed "public domain" style under Creative Commons "CC0":
#   http://creativecommons.org/publicdomain/zero/1.0/
# To the extent possible under law, the contributors to this project have
# waived all copyright and related or neighboring rights to this work.
# In other words, you can use this code for any purpose without any
# restrictions.  This work is published from: United States.  The project home
# is https://github.com/fordsfords/exampled

# See https://github.com/fordsfords/exampled for more information.

cd /  # Release working dir (good practice for daemons).

TOOLDIR="`dirname ${BASH_SOURCE[0]}`"
COMMAND="exampled.sh"
CMD="exampled"
ARGSFILE="/tmp/$CMD.args"
PIDFILE="/tmp/$CMD.pid"
LOGFILE="/tmp/$CMD.log"  # This file won't be used unless there are errors.

CURLOG=""  # Rolling log file.

if echo "$$" >$PIDFILE; then :
else :
  echo "ERROR, `date`: could not write to $PIDFILE" >&2
  exit 1
fi

WARNINGS=""

usage() {
  cat <<__EOF__ 1>&2
Usage: $COMMAND [-h] [-s seconds]
Where:
  -h help
  -s seconds - Seconds to wait between samples; default: 600 (10 min)
See https://github.com/fordsfords/exampled for more information.
__EOF__
  exit 1
}  # usage


# Figure out the current log file name. Call for every loop.
# On a midnight crossing, the log file name will change.
setlog() {
  PREVLOG="$CURLOG"
  # Set the daily log file name and delete it if it's last week's.
  CURLOG="$LOGFILE.`date +%a`"  # Append 3-letter day of week to log file name.
  if MODTIME=`date -r $CURLOG +%s 2>/dev/null`; then :
    NOWTIME=`date +%s`
    LOG_AGE=`expr $NOWTIME - $MODTIME`
    if [ $LOG_AGE -gt 518400 ]; then :  # more than 6 days old?
      rm -f $CURLOG
    fi
  fi
  if [ "$PREVLOG" != "$CURLOG" ]; then :
    # Either this is the first time running, or it's after midnight.
    if echo "Starting log, `date`: $CURLOG on `hostname`" >>$CURLOG; then :
    else :
      echo "ERROR, `date`: could not write to $CURLOG" >&2
      exit 1
    fi

    echo "" >>$CURLOG; echo "Daemon `hostname`: SECS='$SECS'" >>$CURLOG
    if [ -n "$WARNINGS" ]; then echo "$WARNINGS"  >>$CURLOG; fi
    # TBD: collect system-level information once per day.
    echo "" >>$CURLOG; echo "uname -r" >>$CURLOG; uname -r >>$CURLOG 2>&1
    echo "" >>$CURLOG; echo "cat /etc/os-release" >>$CURLOG; cat /etc/os-release >>$CURLOG 2>&1
    echo "" >>$CURLOG; echo "uptime" >>$CURLOG; uptime >>$CURLOG 2>&1
    echo "" >>$CURLOG; echo "lscpu" >>$CURLOG; lscpu >>$CURLOG 2>&1
  fi
}  # setlog


# Function to print a sample.
sample () {
  if echo "" >>$CURLOG; echo "$1, `date`" >>$CURLOG; then :
  else :
    echo "ERROR, `date`: could not write to $CURLOG" >&2
    exit 1
  fi

  # TBD: Do the work of the daemon (i.e. append the desired information to $CURLOG).
  echo "" >>$CURLOG; echo "netstat -us" >>$CURLOG; netstat -us >>$CURLOG 2>&1
  echo "end netstat -us" >>$CURLOG
}  # sample


# TBD: process command-line parameters.
SECS=600  # Default: sleep for 10 minutes between samples.
while getopts "hs:" OPTION
do
  case $OPTION in
    h) usage ;;
    s) SECS="$OPTARG" ;;
    \?) usage ;;
  esac
done
shift `expr $OPTIND - 1`  # Make $1 the first positional param after options
if [ -n "$1" ]; then echo "Error, `date`: unrecognized positional parameter '$1'" >&2; exit 1; fi

# Check for warnings.
if [ "$SECS" -le 0 ]; then :
  WARNINGS="$WARNINGS
Warning: SECS=$SECS, must be > 0 (setting to 5)"
  SECS=5
fi

RUNNING=1
trap "RUNNING=0" HUP INT QUIT TERM
SAMPLE=0
trap "SAMPLE=1" USR1

NOW_SECS=`date +%s`
END_SECS=`expr $NOW_SECS + $SECS`
while [ "$RUNNING" -eq 1 ]; do :
  setlog
  sample "Sample"

  echo "" >>$CURLOG; echo "Waiting for $SECS seconds" >>$CURLOG
  while [ "$RUNNING" -eq 1 -a `date +%s` -lt "$END_SECS" ]; do :
    sleep 0.5
    if [ "$SAMPLE" -eq 1 ]; then :
      sample "USR1 sample"
      SAMPLE=0
    fi
  done

  END_SECS=`expr $END_SECS + $SECS`
done

sample "Final sample"  # One more sample before exit.

echo "" >>$CURLOG; echo "exiting daemon, date=`date`" >>$CURLOG

exit 0
