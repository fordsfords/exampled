#!/bin/bash
# exampled_tst.sh
# See https://github.com/fordsfords/exampled for more information.

TOOLDIR="`dirname ${BASH_SOURCE[0]}`"
COMMAND="exampled.sh"
CMD="exampled"
ARGSFILE="/tmp/$CMD.args"
PIDFILE="/tmp/$CMD.pid"
LOGFILE="/tmp/$CMD.log"  # This file won't be used unless there are errors.

CURLOG="$LOGFILE.`date +%a`"  # Append 3-letter day of week to log file name.

ASSRT() {
  eval "test $1"

  if [ $? -ne 0 ]; then
    echo "ASSRT ERROR, `date`: `basename ${BASH_SOURCE[1]}`:${BASH_LINENO[0]}, not true: '$1'" >&2
    exit 1
  else :
    echo "fyi, `date`: `basename ${BASH_SOURCE[1]}`:${BASH_LINENO[0]}: OK"
  fi
}  # ASSRT


# Too many command-line args
rm -f /tmp/$CMD.* tst.log
./exampled_start.sh 1 2 >tst.log 2>&1 ; ASSRT "$? -ne 0"
NUM_ERRS=`egrep "^ERROR .*inside single quotes" tst.log | wc -l` ; ASSRT "$NUM_ERRS -eq 1"

./exampled_status.sh >tst.log 2>&1 ; ASSRT "$? -eq 0"
NUM_ERRS=`egrep "^Daemon not running" tst.log | wc -l` ; ASSRT "$NUM_ERRS -eq 1"

# Successful start (with warning)
rm -f /tmp/$CMD.*
echo "xxx" >$PIDFILE
./exampled_start.sh >tst.log 2>&1 ; ASSRT "$? -eq 0"
sleep 0.2
NUM_STARTINGS=`egrep "^Starting log," $CURLOG | wc -l` ; ASSRT "$NUM_STARTINGS -eq 1"
NUM_ERRS=`egrep "^Warning.*: /tmp/$CMD.pid exists, contains 'xxx', but not running" tst.log | wc -l` ; ASSRT "$NUM_ERRS -eq 1"
NUM_GOODS=`egrep "^Good: daemon started" tst.log | wc -l` ; ASSRT "$NUM_GOODS -eq 1"

./exampled_status.sh >tst.log 2>&1 ; ASSRT "$? -eq 0"
NUM_RUNNING=`egrep "^Daemon is running" tst.log | wc -l` ; ASSRT "$NUM_RUNNING -eq 1"

# Running, no restart needed.
./exampled_check.sh >tst.log 2>&1 ; ASSRT "$? -eq 0"
NLOGS=`wc -l <tst.log` ; ASSRT "$NLOGS -eq 0"

# Test exampled_sample.sh
NUM_SAMPLES=`egrep "^Sample, " $CURLOG | wc -l` ; ASSRT "$NUM_SAMPLES -eq 1"
NUM_SAMPLES=`egrep "^USR1 sample, " $CURLOG | wc -l` ; ASSRT "$NUM_SAMPLES -eq 0"
./exampled_sample.sh
sleep 0.7
NUM_SAMPLES=`egrep "^Sample, " $CURLOG | wc -l` ; ASSRT "$NUM_SAMPLES -eq 1"
NUM_SAMPLES=`egrep "^USR1 sample, " $CURLOG | wc -l` ; ASSRT "$NUM_SAMPLES -eq 1"

PID=`cat /tmp/$CMD.pid`
kill -9 $PID
sleep 0.5

./exampled_status.sh >tst.log 2>&1 ; ASSRT "$? -eq 1"
NUM_WARNINGS=`egrep "^Warning.*does not appear to be running" tst.log | wc -l` ; ASSRT "$NUM_WARNINGS -eq 1"

# Restart needed.
./exampled_check.sh >tst.log 2>&1 ; ASSRT "$? -eq 0"
NLOGS=`wc -l <tst.log` ; ASSRT "$NLOGS -eq 0"
sleep 0.2

./exampled_status.sh >tst.log 2>&1 ; ASSRT "$? -eq 0"
NUM_RUNNING=`egrep "^Daemon is running" tst.log | wc -l` ; ASSRT "$NUM_RUNNING -eq 1"
NUM_STARTINGS=`egrep "^Starting log," $CURLOG | wc -l` ; ASSRT "$NUM_STARTINGS -eq 2"

PID=`cat /tmp/$CMD.pid`
kill -9 $PID
sleep 0.5

./exampled_stop.sh >tst.log 2>&1 ; ASSRT "$? -eq 0"
NUM_LOGS=`egrep "^PID.*does not appear to be running" tst.log | wc -l` ; ASSRT "$NUM_WARNINGS -eq 1"

# Stopped, no restart needed.
./exampled_check.sh >tst.log 2>&1 ; ASSRT "$? -eq 0"
NUM_LOGS=`wc -l <tst.log` ; ASSRT "$NUM_LOGS -eq 0"

./exampled_status.sh >tst.log 2>&1 ; ASSRT "$? -eq 0"
NUM_LOGS=`egrep "^Daemon not running" tst.log | wc -l` ; ASSRT "$NUM_LOGS -eq 1"

NUM_STARTINGS=`egrep "^Starting log," $CURLOG | wc -l` ; ASSRT "$NUM_STARTINGS -eq 2"
NUM_SAMPLES=`egrep "^Sample, " $CURLOG | wc -l` ; ASSRT "$NUM_SAMPLES -eq 2"
NUM_FINALS=`egrep "^Final sample," $CURLOG | wc -l` ; ASSRT "$NUM_FINALS -eq 0"

rm -f /tmp/$CMD.*
./exampled_start.sh '-s 0' >tst.log 2>&1 ; ASSRT "$? -eq 0"

sleep 0.1
NUM_WARNINGS=`egrep "^Warning: SECS=0, must be > 0" $CURLOG | wc -l` ; ASSRT "$NUM_WARNINGS -eq 1"
NUM_SAMPLES=`egrep "^Sample, " $CURLOG | wc -l` ; ASSRT "$NUM_SAMPLES -eq 1"
NUM_FINALS=`egrep "^Final sample," $CURLOG | wc -l` ; ASSRT "$NUM_FINALS -eq 0"

./exampled_stop.sh >tst.log 2>&1 ; ASSRT "$? -eq 0"
NUM_SAMPLES=`egrep "^Sample, " $CURLOG | wc -l` ; ASSRT "$NUM_SAMPLES -eq 1"
NUM_FINALS=`egrep "^Final sample," $CURLOG | wc -l` ; ASSRT "$NUM_FINALS -eq 1"

echo "Done, `date`"
