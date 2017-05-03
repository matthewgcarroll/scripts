#!/usr/bin/ksh
# Work in a temp dir
cd /tmp

# Pick a unique (useful) filename               
file=rpt_`date +%Y%m%d_%H%M`.rtf

# Start with an RTF template setting font, margins
cp /info/local/bin/TEMPLATE.RTF $file

# Append the report to the RTF template
cat $1 >> $file

# Swap page breaks ^L (literal in this file, use ^V to insert) for \\page and \n for \\par
perl -i -n -e 's{^L}{\\page }g;chomp;print $_,q(\\par );' $file

# Add a final paragraph marker to the end
echo \\par }} >> $file

# Decide who to send to
to=`cat /home/$USER/.email`
to=${to:-"fallback.user@domain.com"}                    

# Figure out subject
subj=`grep 'PAGE[ ]*1' $1 | head -1 | cut -d\  -f1`
subj=${subj:-"Your Infolease Report"}

#Send the email!
uuencode $file $file |  mail -s "$subj" $to

# Clean up
rm $file        
