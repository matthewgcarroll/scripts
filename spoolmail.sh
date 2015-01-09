#!/bin/sh

# Email the spooled file to the current user, converted to RTF
# Parameters: 2 = full path to file

if [ "$1" == "TXT" ]; then
    file=/tmp/report.$$.txt
    # Leave things alone
    perl -p -e 's/\n$/\r\n/;' $2 > $file
else
    # RTF is the default
    file=`mktemp`
    # Copy the header to a working copy - obtain this header by setting fonts (fixed), 
    # margins (narrow) and any other defaults you need in an empty word doc,
    # save as RTF and then remove the final \\par }} from the doc
    cp /usr/local/lib/TEMPLATE.RTF $file
    # Append the report to the working copy
    cat $2 >> $file
    # Swap page breaks ^L for \\page and \n for \\par
    perl -i -n -e 's{^L}{\\page }g;chomp;print $_,q(\\par );' $file
    # Add a final paragraph marker to the end
    echo \\par }} >> $file
fi

# Figure out who to send to
TO=`getalias $LOGNAME`
FROM=$TO
SUBJECT="Your report"
/usr/local/bin/uuenview -b -f $FROM -m $TO -s "$SUBJECT" $file
rm $file
