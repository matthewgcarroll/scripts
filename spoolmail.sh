#!/usr/bin/ksh

# This script is called from the spooler, and expects two parameters,
#  $1=Email address (comma separated ok), or OWNER means look up address from ~/.email
#  $2=Path to file to be printed (usually like /var/spool/qdaemon/to4h7aa)
# The Infolease printer needs to be setup with the right target in /etc/qconfig
# And under options add either -o OWNER or -o email1@domain.com,email2@domain.com

# Work in a temp dir
cd /tmp
LOG=/tmp/print_to_rtf.log
date >> $LOG
echo $* >> $LOG

# Figure out subject, tr removes any leading ^L (aka formfeed, aka \f)
subj=`tr -d '\f' < $2 | grep 'PAGE[ ]*1' | head -1 | cut -d\  -f1`
file=$subj
subj=${subj:-"Your Infolease Report"}
echo "Subject=$subj" >> $LOG

# Pick a unique filename, use part of the subject if possible, rpt_ if not
file=${file:-rpt}
file=${file}_`date +%Y%m%d_%H%M%S.rtf`
# Replace anything that's not "A-Z" "0-9" "." "_" "-" with an underscore
# https://serverfault.com/questions/348482/how-to-remove-invalid-characters-from-filenames
file=`echo $file | sed -e 's/[^A-Za-z0-9._-]/_/g'`
echo "Filename=$file" >> $LOG

# Start with an RTF template setting font, margins
cp /info/local/bin/TEMPLATE.RTF $file

# Append the report to the RTF template
cat $2 >> $file

# Swap page breaks ^L for \\page and \n for \\par - perl golf!
perl -i -n -e 's{^L}{\\page }g;chomp;print $_,q(\\par );' $file

# Add a final paragraph marker to the end
echo \\par }} >> $file

# Decide who to send to
if [ "x$1" = "xOWNER" ]; then
  to=`cat /home/$USER/.email`
  echo "-o OWNER /home/$USER/.email=$to" >> $LOG
  to=${to:-"ian.mcgowan@gmail.com"}
else
  to=$1
  echo "Email provided=$to" >> $LOG
fi
echo "Final to=$to"

# If the file is too big, zip it good
# https://stackoverflow.com/questions/5920333/how-to-check-size-of-a-file
minimumsize=5000
actualsize=$(du -k "$file" | cut -f 1)
echo "Actual size=$actualsize" >> $LOG
if [ $actualsize -ge $minimumsize ]; then
  echo size is over $minimumsize kilobytes >> $LOG
  zip ${file}.zip $file
  rm $file
  file=${file}.zip
else
  echo size is under $minimumsize kilobytes >> $LOG
fi

#Send the email!  If you have access to uuenview or mutt, there are better ways to do this
echo uuencode $file $file \| mail -s "$subj" $to >> $LOG
uuencode $file $file | mail -s "$subj" $to

# Clean up
rm $file
# Uncomment this in the future to get rid of log
#rm $LOG
