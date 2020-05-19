# gopostal_bash
A bash script to create unique emails for testing purposes
gopostal.sh README.txt

PURPOSE:
These script will send unique, randomize and searchable text emails and csv attachments for the purpose of testing Retain and the email servers it connects to.
-gopostal.sh sends messages to a set of users and is expected to be used with cron to send messages on a regular basis so there are always new messages available for testing. 
-posthowmany.sh takes a command line argument for the number of messages to send. #>./posthowmany.sh 1000

IMPORTANT: 
This script has no error checking or other safeties in place. It expects you to know what you are doing. 
WARNING: 
For internal use only. This will send lots of email very quickly. 
This script acts like a simple spambot and most real world mail servers are configured to block domains that spam.

REQUIREMENTS: 
You must set the domain name of your email system in the script.
Enable mail in YaST. The sending mailserver must be configured with: connection type Permanent, Outgoing Mail set to the IP address of your receiving mail server. 
The receiving mail server must have the target users defined in the script or change the users in the script. 

SCHEDULE: 
To send messages hourly use "crontab -e", change the file path to where you stored the script. For example, "00 */1 * * * /root/Desktop/gopostal/gopostal.sh"

Attachements: 
This script can also send files as attachments. Just enable Attachments and place files in the files/ directory. The script will choose a random one and add it to the attachments. It will also create random attachments files that are unique.
Creating Attachment Dataset: This only comes with 20 files to attachment. The more data you add to the files/ directory the better. Some suggested sources:
http://www.gutenberg.org/wiki/Gutenberg:The_CD_and_DVD_Project
http://www.textfiles.com/ and http://pdf.textfiles.com/
http://lifehacker.com/5774707/download-the-entire-archive-of-nasas-astronomy-picture-of-the-day-with-one-command
https://www.quora.com/Where-can-I-find-large-datasets-open-to-the-public
https://snap.stanford.edu/data/email-EuAll.html
https://catalog.data.gov/dataset?tags=email
https://www.cs.cmu.edu/~./enron/
https://www.springboard.com/blog/free-public-data-sets-data-science-project/

Changing defaults:
You will need to set the domain of your email system in the script
By default gopostal.sh expects to be in /root/Desktop/gopostal with the support files:
textdata.dat This is a text file, currently using Alice in Wonderland, a public domain text. Any text file can be used.
csvdata.dat This is a comma delimited file used as a base to fill the csv file attachment.
csvheader.dat This is a comma delimited file used as the header to the csv file attachment. 
