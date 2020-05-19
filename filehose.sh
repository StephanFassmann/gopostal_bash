#!/bin/bash
date
#**********************************************************************************************************************
#filehose.sh
#Stephan Fassmann 06/07/2017
#Purpose: This script is designed to produce and send a large amount of unique email for the testing of the database and storage area of Retain.  
#This requires postfix or other mail server to be available. The body is shuffled large text file. The attachment is a shuffled csv file. 
#09/22/2016 SF updated to use array for the userlist, and random harvard sentences for subject lines
#09/23/2016 SF added html attachment, optional logging
#12/05/2016 SF made it so attachments can be turned on and off
#12/07/2016 SF created option to send arbitary amounts of mail to designated users. Using i in subject for number of items sent. Sends ~15 messages/sec 10,000 in 17 minutes
#06/07/2017 SF stripped attachments from posthowman.sh into filehose.sh to make it faster and simpler to send just attachments from dateset/.
#**********************************************************************************************************************
#IMPORTANT: This script has no error checking or other safeties in place. It expects you to know what you are doing. 
#WARNING: For internal use only. This will quickly send lots of email. This is a simple spambot and most real world mail servers are configured to block domains that spam.
#**********************************************************************************************************************
#PREREQUISITE: Enable mailserver in YaST. The sending mailserver must be configured with: connection type Permanent, Outgoing Mail set to the IP address of your receiving mail server. 
#**********************************************************************************************************************

#***CHANGE: Set your email domain!
#DOMAIN=set.your.domain
#DOMAIN=sfgw14.gwava.net
DOMAIN=doc.mf.net

#***CHANGE: Specify the usernames to send to, they must exist in your email system. http://stackoverflow.com/questions/8880603/loop-through-array-of-strings-in-bash-script
declare -a USERNAME=('Aiden' 'Blake' 'Carter' 'Dakota' 'Eden' 'Finley' 'Hayden' 'Jayden' 'Kamryn' 'Riley' 'test0' 'test1' 'test2' 'test3' 'test4' 'test5' 'test6' 'test7' 'test8' 'test9')

#declare -a USERNAME=('Aiden' 'Blake' 'Carter' 'Dakota' 'Eden' 'Finley' 'Hayden' 'Jayden' 'Kamryn' 'Riley')
#declare -a USERNAME=('user0' 'user1' 'user2' 'user3' 'user4' 'user5' 'user6' 'user7' 'user8' 'user9' 'user10' 'user11' 'user12' 'user13' 'user14' 'user15' 'user16' 'user17' 'user18' 'user19' 'user20')
#declare -a USERNAME=('test0' 'test1' 'test2' 'test3' 'test4' 'test5' 'test6' 'test7' 'test8' 'test9' 'test10' 'test11' 'test12' 'test13' 'test14' 'test15' 'test16' 'test17' 'test18' 'test19' 'test20' 'test21' 'test22' 'test23' 'test24' 'test25' 'test26' 'test27' 'test28' 'test29' 'test30' 'test31' 'test32' 'test33' 'test34' 'test35' 'test36' 'test37' 'test38' 'test39' 'test40' 'test41' 'test42' 'test43' 'test44' 'test45' 'test46' 'test47' 'test48' 'test49' 'test50' 'test51' 'test52' 'test53' 'test54' 'test55' 'test56' 'test57' 'test58' 'test59' 'test60' 'test61' 'test62' 'test63' 'test64' 'test65' 'test66' 'test67' 'test68' 'test69' 'test70' 'test71' 'test72' 'test73' 'test74' 'test75' 'test76' 'test77' 'test78' 'test79' 'test80' 'test81' 'test82' 'test83' 'test84' 'test85' 'test86' 'test87' 'test88' 'test89' 'test90' 'test91' 'test92' 'test93' 'test94' 'test95' 'test96' 'test97' 'test98' 'test99' 'test100')

#Specify the number of messages to send on the command line. http://unix.stackexchange.com/questions/25945/how-to-check-if-there-are-no-parameters-provided-to-a-command
if [ $# -eq 0 ]
then
    echo "Please specify the number of messages to send. For Example: firehose.sh 100"
    exit 1
fi
SEND=$1

#OPTIONAL: How large to fill the body of the message, in bytes.
BODYSIZEMIN=256
BODYSIZEMAX=1024

#OPTIONAL: Do you want logging? YES | NO
LOGGING=YES
#Set maximum size of log file in kb. Default 1048576 (1GB)
max_log_size_kb=1048576

#**********************************************************************************************************************
#You should not have to change anything below this line. 
#FILES
#Set the location of the script and the support files

#Set path http://stackoverflow.com/questions/4774054/reliable-way-for-a-bash-script-to-get-the-full-path-to-itself
FILELOCATION="$( cd "$(dirname "$0")" ;  pwd -P )"

#Where is the script
#CODEFILE="$FILELOCATION/filehose.sh"

#SUBJECT: Data file for the subject.
SUBJECTIN="$FILELOCATION/subjectdata.dat"
#SUBJECTOUT is the completed randomized csv attachment. This file is temporary.
SUBJECTOUT="$FILELOCATION/subjectdata.tmp"

#BODY: Data files required for creating the body. This script is using "Alice in Wonderland" as it is in the public domain. You can replace it with any large text file.
BODYIN="$FILELOCATION/bodydataBasic.dat"
#BODYOUT and BODY are shuffled and truncated output files. These files are temporary.
BODYOUT="$FILELOCATION/bodyshuf.tmp"
BODY="$FILELOCATION/bodytext.tmp"

#LOG: Logging for developmental troubleshooting
LOGFILE="$FILELOCATION/filehose.log"

#LOG: Check for maximum size of log file in kb. Default 1048576 (1GB)
#LOG: when did it start
if [[ "$LOGGING" == YES ]]
then
	file_size_kb=`du -k "$LOGFILE" | cut -f1`
	echo Log size = "$file_size_kb" >> $LOGFILE 2>&1
	if [[ $file_size_kb -gt $max_log_size_kb ]]
	then
		rm $LOGFILE
		echo Removing log file
		LOGFILE="$FILELOCATION/filehose.log"
	fi
fi

#LOG: when did it start
if [[ "$LOGGING" == YES ]]
then
	#echo "$(date "+%m%d%Y %T"): Beginning"
	echo "$(date "+%m%d%Y %T"): Beginning" >> $LOGFILE 2>&1
fi

#**********************************************************************************************************************
#MAIN
j=0 #initialize user array counter
#Get number of items in user array http://www.thegeekstuff.com/2010/06/bash-array-tutorial
NUMUSERS=${#USERNAME[@]}

#Mail item counter
for (( i=1; i<=$SEND; i++ )) 
do
	#Create emails
	#Randomize a file so we have non-duplicates in Retain
	n=$RANDOM

	#BODY: Randomize body text from a range
	shuf -n $n $BODYIN > $BODYOUT
	BODYSIZE="$( shuf -i $BODYSIZEMIN-$BODYSIZEMAX -n 1 )"
	#Get single block of text and suppress stderr
	dd if=$BODYOUT of=$BODY ibs=$BODYSIZE count=1 status=noxfer >& /dev/null
	#echo "$BODY"

	#SUBJECT: Shuffle subject line
	shuf -n 1 $SUBJECTIN > $SUBJECTOUT
	SUBJECT=$(<$SUBJECTOUT)
	#echo $SUBJECT
	
	#FILE: select a random file from dataset/ directory
	#https://unix.stackexchange.com/questions/131766/why-does-my-shell-script-choke-on-whitespace-or-other-special-characters
	RANDFILE=( "$(find $FILELOCATION/dataset -type f | shuf -n 1)" )
	#echo RANDFILE "${RANDFILE}"

	#MAIL: send email to user without attachments
	(cat $BODY)  | mail -s "$i$n $SUBJECT $(date)" -a "${RANDFILE}" "${USERNAME[j]}"@$DOMAIN

	#LOG: each email sent
	if [[ "$LOGGING" == YES ]]
	then
		echo "$(date "+%m%d%Y %T")" "User:" "${USERNAME[j]}" "Item#:" "$i" "RE:" "PHM: $SUBJECT $n"  >> $LOGFILE 2>&1;
	fi
		
	#Increment to the next user in the array, if we have gone through all the users recycle the counter 
	((j++))	
	if [[ $j -ge $NUMUSERS ]]
	then
		j=0
	fi
done

#LOG: When did it finish
if [[ "$LOGGING" == YES ]]
then
	#echo "$(date "+%m%d%Y %T"): Done";
	echo "$(date "+%m%d%Y %T"): Done" >> $LOGFILE 2>&1;
fi
date
exit $?  
