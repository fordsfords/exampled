#!/bin/bash
# port.sh - Create a new daemon based on exampled.

# This work is dedicated to the public domain under CC0 1.0 Universal:
# http://creativecommons.org/publicdomain/zero/1.0/
# 
# To the extent possible under law, Steven Ford has waived all copyright
# and related or neighboring rights to this work. In other words, you can 
# use this code for any purpose without any restrictions.
# This work is published from: United States.
# Project home: https://github.com/fordsfords/exampled

# See https://github.com/fordsfords/exampled for more information.

NAME="$1"
if [ -z "$NAME" ]; then :
  echo "ERROR, `date`: missing daemon name." >&2
  exit 1
fi

TOOLDIR="`dirname ${BASH_SOURCE[0]}`"

echo mkdir "$NAME"
mkdir "$NAME"
if [ $? -ne 0 ]; then exit 1; fi

for F in $TOOLDIR/.git?*; do :
  echo cp $F "$NAME/"
  cp $F "$NAME/"
done

for F in $TOOLDIR/exampled*.sh; do :
  f=`basename $F`
  SUFFIX="${f#exampled}"
  DEST="$NAME/$NAME$SUFFIX"

  echo "sed <$F >$DEST \"s/exampled/$NAME/g\""
  sed <$F >$DEST "s/exampled/$NAME/g"
done

echo "chmod +x \"$NAME\"/*.sh"
chmod +x "$NAME"/*.sh

cat <<__EOF__

Now edit $NAME/$NAME.sh and search for "TBD".
Modify per your requirements.
Test with "$NAME/${NAME}_tst.sh".
__EOF__

exit 0
