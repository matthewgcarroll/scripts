#!/bin/bash
# 12/31/2014 Ian   Drastically simplify, remove cruft, use logdir
# 12/22/2004 mrj   port to bay
# 06/17/2003 Ian   Use getalias to correctly get email address to send to
# 06/19/2003 Ian   Clean up a bit, if user contains "@" do not look up alias
# Parameters: 1 = name of user (OWNER=current user)
#             2 = full path to file

function cleanup {
    # A little paranoid that $logdir might end up as "." at some point
    cd ${TMPDIR:=/tmp}
    rm -rf `basename $logdir`
    exit 0
}

logdir=`mktemp -d -t pdfmail.XXXXXXXXXX`
log=$logdir/log

if [ $# -ne 2 ]; then
  echo "Usage: pdfmail user filename" >> $log
  cleanup
fi

# Infolease reports have a header page that need to be ignored
queue=`grep "QUEUE NAME:" $2`
if [ $? == 0 ]; then
   echo "This is a contents page, ignoring..." >> $log
   cleanup
fi

user=$1
ps="$logdir/$$.ps"
pdf="$logdir/report.$$.pdf"
subject="[IL] Your Report"

# Figure out who to email the report to, if it's the current user
if [ "$user" == "OWNER" ]; then
    # Send to the current user
    user=`getalias $LOGNAME`
fi

# Figure out who it's from
from=`fname $LOGNAME`
if [ -z "$from" ]; then
    # This shouldn't happen, since everyone has an alias
    from=$LOGNAME
fi

# Turn ascii into postscript
echo /opt/freeware/bin/a2ps --columns 1 -B -R -l"132" $2 -o $ps >> $log
/opt/freeware/bin/a2ps --columns 1 -B -R -l"132" $2 -o $ps >> $log 2>&1

if [ ! -e $ps ]; then
    echo "File $ps does not exist!!" >> $log
    cleanup
fi

# Turn postscript into pdf
echo /opt/freeware/bin/ps2pdf $ps $pdf >> $log
/opt/freeware/bin/ps2pdf $ps $pdf >> $log 2>&1

if [ ! -s $pdf ]; then
    echo "File $pdf does not exist or is empty!!" >> $log
    cleanup
fi

# Finally, send the email
/usr/local/bin/uuenview -f "$from" -m "$user" -s "$subject" "$pdf" >> $log 2>&1

# Remove the mess
cleanup
