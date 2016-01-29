#!/opt/freeware/bin/python
# Program: mail.py, send an email attachment with a message body (cf uuenview)
# Author : Ian McGowan
# Date   : 2015-12-09
import smtplib
import os
import sys
from email.MIMEMultipart import MIMEMultipart
from email.MIMEBase import MIMEBase
from email.MIMEText import MIMEText
from email.Utils import formatdate
from email import Encoders

# These args need to be wrapped in "" if there are spaces
send_from=str(sys.argv[1])
send_to=str(sys.argv[2])
send_cc=str(sys.argv[3])
send_bcc=str(sys.argv[4])
subject=str(sys.argv[5])
text=str(sys.argv[6])
file=str(sys.argv[7])
server="smtpz-om.bankofthewest.com"

# Create the message body
msg = MIMEMultipart()
msg['From'] = send_from
msg['To'] = send_to
msg['Cc'] = send_cc
msg['Date'] = formatdate(localtime=True)
msg['Subject'] = subject
msg.attach( MIMEText(text) )

# Now add the file as an attachment, it would be handy to accept a comma-seperated list
part = MIMEBase('application', "octet-stream")
part.set_payload( open(file,"rb").read() )
Encoders.encode_base64(part)
part.add_header('Content-Disposition', 'attachment; filename="%s"' % os.path.basename(file))
msg.attach(part)

# Just send it!
smtp = smtplib.SMTP(server)
smtp.sendmail(send_from, send_to+","+send_cc+","+send_bcc, msg.as_string())
smtp.close()
