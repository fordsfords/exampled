# exampled

Generic bash script for a daemon.

# Table of contents

<!-- mdtoc-start -->
&bull; [exampled](#exampled)  
&bull; [Table of contents](#table-of-contents)  
&bull; [Introduction](#introduction)  
&bull; [Usage:](#usage)  
&nbsp;&nbsp;&nbsp;&nbsp;&bull; [exampled.sh](#exampledsh)  
&nbsp;&nbsp;&nbsp;&nbsp;&bull; [exampled_start.sh](#exampled_startsh)  
&nbsp;&nbsp;&nbsp;&nbsp;&bull; [exampled_check.sh](#exampled_checksh)  
&nbsp;&nbsp;&nbsp;&nbsp;&bull; [exampled_sample.sh](#exampled_samplesh)  
&nbsp;&nbsp;&nbsp;&nbsp;&bull; [exampled_stop.sh](#exampled_stopsh)  
&nbsp;&nbsp;&nbsp;&nbsp;&bull; [exampled_tst.sh](#exampled_tstsh)  
&bull; [Design](#design)  
&bull; [Porting](#porting)  
&bull; [License](#license)  
<!-- TOC created by '../mdtoc/mdtoc.pl README.md' (see https://github.com/fordsfords/mdtoc) -->
<!-- mdtoc-end -->

# Introduction

Over the years, I've had many occasions where I wanted to create a
daemon process that has a long runtime, usually with the intention
that the process runs all the time the system is running.

This repo is a skeletal version that pulls together the features
I've found most useful.

Many daemons that I find myself running are intended to collect information
periodically over a long time.
in many cases, I want the daemon running perpetually.
But I obiously don't want the collected information filling the disk.

This skeletal daemon design is written on the assumption that
the daemon will write to a given log file for a full day,
then switch to a fresh log file at midnight.
It keeps 6 days of history in addition to the current day's log.
The files are named according to the day of the week.
E.g. "/tmp/exampled.log.Mon", "/tmp/exampled.log.Tue", etc.

This daemon is designed to wake up periodically and
collect a "sample" of data.
This data is often just the output of a standard Unix command,
like "netstat" or "ethtool" (or both).

Almost all of the scripting in this repo is concerned with
managing the daemon - starting it, stopping it, etc.

# Usage:

## exampled.sh

This is the actual daemon script.
I.e. this is the script that is intended to run in the background
and periodically wakes up, takes a sample, and goes back to sleep.
As such, this is the script that actually knows how to take a data sample,
and is therefore the one that you will customize for your own needs.

Normally you would not execute this script directly.
Use "exampled_start.sh", "exampled_stop.sh", etc.

Here's the help from the exampled.sh tool:
````
Usage: exampled.sh [-h] [-s seconds]
Where:
  -h help
  -s seconds - Seconds to wait between samples. Default: 600 (10 min)
See https://github.com/fordsfords/exampled for more information.
````

## exampled_start.sh

The "exampled_start.sh" script starts "exampled.sh" running as a daemon
(e.g. you can log out and the daemon will continue running).

The "exampled_start.sh" tool also records the desired command-line parameters
of "exampled.sh" so that it can be restarted easily with the same settings.
Those command-line parameters must be enclosed in single quotes.

For example:

````
$ ./exampled_start.sh '-s 300'
````

This records the daemon options in "/tmp/exampled.args".
Subsequently, you can stop and restart the tool without options
and it will re-use the saved ones.
For example:

`````
$ ./exampled_start.sh '-s 300'
$ ./exampled_stop.sh
$ ./exampled_start.sh
Using /tmp/exampled.args.stopped
`````

## exampled_check.sh

The "exampled_check.sh" script is intended to be run
periodically (perhaps hourly) as a cron job.
It checks to see if daemon should be running and restarts it if needed.
This is useful after a system reboot.

No command-line parameters are permitted.

````
$ ./exampled_start.sh '-s 300'
$ kill -9 `cat /tmp/exampled.pid`  # abnormally stop
$ ./exampled_check.sh
````
The daemon check restarts the abnormally killed daemon.

## exampled_sample.sh

The "exampled_sample.sh" script tells the daemon to
generate an extra sample (using the USR1 signal).
This can be useful if the daemon was configured to run infrequently,
and you notice something that makes you want an extra sample.

No command-line parameters are permitted.

````
$ ./exampled_sample.sh
````

Note that it might take a second for daemon to respond.

## exampled_stop.sh

The "exampled_stop.sh" script not only stops the daemon,
but also prevents the "exampled_check.sh" script from restarting it
by renaming "/tmp/exampled.args" to "/tmp/exampled.args.stopped".

No command-line parameters are permitted.

````
$ ./exampled_stop.sh
````

## exampled_tst.sh

Self-test script that runs the tools through their functions.

# Design

Just a few misc design tips.

Each tool starts with a standardized block of symbol definitions
for:
* TOOLDIR - used by tools to refer to each other. E.g. the
exampled_start.sh tool invokes the exampled_check.sh tool.
* COMMAND - used in conjunction with the "ps" command to
determine if the daemon is currently running.
* CMD - used to construct certain file names (see below).
* ARGSFILE - file that holds command-line arguments to facilitate restarting.
* PIDFILE - file that holds the PID of the daemon.
* LOGFILE - file that holds standard out and standard error for daemon.
Normally should be empty.
Also used as the base to construct the "rolling" log files by appending
".xxx" where "xxx" is the 3-letter abbreviation of the day of the week.
E.g. a rolling log file might be "/tmp/exampled.log.Mon".

# Porting

The "port.sh" script makes a copy of the "exampled" repo and
changing the names of the files and their contents to reflect
the new name.

Decide on a name for your daemon (in this example, I use "pingerd").
Then go to the parent directory of the exampled repo, and enter
"exampled/port.sh pingerd".

For example:
````
$ exampled/port.sh pingerd
mkdir pingerd
cp exampled/.gitattributes pingerd/
cp exampled/.gitignore pingerd/
sed <exampled/exampled.sh >pingerd/pingerd.sh "s/exampled/pingerd/g"
sed <exampled/exampled_check.sh >pingerd/pingerd_check.sh "s/exampled/pingerd/g"
sed <exampled/exampled_sample.sh >pingerd/pingerd_sample.sh "s/exampled/pingerd/g"
sed <exampled/exampled_start.sh >pingerd/pingerd_start.sh "s/exampled/pingerd/g"
sed <exampled/exampled_status.sh >pingerd/pingerd_status.sh "s/exampled/pingerd/g"
sed <exampled/exampled_stop.sh >pingerd/pingerd_stop.sh "s/exampled/pingerd/g"
sed <exampled/exampled_tst.sh >pingerd/pingerd_tst.sh "s/exampled/pingerd/g"
chmod +x "pingerd"/*.sh
````

* Now cd into pingerd and edit pingerd.sh and search for "TBD".
* Modify per your requirements.
* Test with "pingerd_tst.sh".

# License

I want there to be NO barriers to using this code, so I am releasing it to the public domain.  But "public domain" does not have an internationally agreed upon definition, so I use CC0:

This work is dedicated to the public domain under CC0 1.0 Universal:
http://creativecommons.org/publicdomain/zero/1.0/

To the extent possible under law, Steven Ford has waived all copyright
and related or neighboring rights to this work. In other words, you can 
use this code for any purpose without any restrictions.
This work is published from: United States.
Project home: https://github.com/fordsfords/exampled
