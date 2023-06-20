# exampled

Generic bash script for a daemon.

# Table of contents

- [exampled](#exampled)
- [Table of contents](#table-of-contents)
- [Introduction](#introduction)
- [Usage:](#usage)
  - [exampled.sh](#exampledsh)
  - [exampled_start.sh](#exampled_startsh)
  - [exampled_check.sh](#exampled_checksh)
  - [exampled_sample.sh](#exampled_samplesh)
  - [exampled_stop.sh](#exampled_stopsh)
  - [exampled_tst.sh](#exampled_tstsh)
- [Design](#design)
- [Porting](#porting)
- [License](#license)

<sup>(table of contents from https://luciopaiva.com/markdown-toc/)</sup>

# Introduction

Over the years, I've had many occasions where I wanted to create a
daemon process that has a long runtime, usually with the intention
that the process runs all the time the system is running.

# Usage:

This repo contains example files for how to manage a daemon.
The intention is to customize these files for the daemon
that you want to manage.

## exampled.sh

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

To assist in running the tool continuously,
there is a "exampled_start.sh" script that starts the exampled.sh
script as a daemon (e.g. you can log out and the daemon will continue
running).

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

Included is a script "port.sh".
I'm not sure it should be used;
maybe it's more of a reference.

But if you're feeling brave and want to give it a go,
decide on a name for your daemon (in this example, I use "pingerd"),
go to the parent directory of the exampled repo, and enter
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

Now edit pingerd/pingerd.sh and search for "TBD".
Modify per your requirements.
Test with "pingerd/pingerd_tst.sh".
````

This will create a directory named "pinger" and modify the
exampled files for it.

Search for "TBD" in "pingerd.sh" and modify as per what you want
to collect.

# License

I want there to be NO barriers to using this code,
so I am releasing it to the public domain.
But "public domain" does not have an internationally agreed upon definition,
so I use CC0:

Copyright 2022-2023 Steven Ford http://geeky-boy.com and licensed
"public domain" style under
[CC0](http://creativecommons.org/publicdomain/zero/1.0/):
![CC0](https://licensebuttons.net/p/zero/1.0/88x31.png "CC0")

To the extent possible under law, the contributors to this project have
waived all copyright and related or neighboring rights to this work.
In other words, you can use this code for any purpose without any
restrictions.  This work is published from: United States.  The project home
is https://github.com/fordsfords/exampled

To contact me, Steve Ford, project owner, you can find my email address
at http://geeky-boy.com.  Can't see it?  Keep looking.
