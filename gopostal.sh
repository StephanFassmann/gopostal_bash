#!/bin/bash
date
#**********************************************************************************************************************
#gopostal.sh
#Stephan Fassmann 09/21/2015
#Purpose: This script is designed to produce and send a large amount of unique email for the testing of the database and storage area of Retain.  
#This requires postfix or other mail server to be available. The body is shuffled large text file. The attachment is a shuffled csv file. 
#12/05/2015 SF made it so attachments can be turned on and off
#09/22/2016 SF updated to use array for the userlist, and random harvard sentences for subject lines
#09/23/2016 SF added html attachment, optional logging
#06/05/2017 SF changed body size to be random between a range, fixed spaces in file names issues, added random sender, CC and BCC.
#**********************************************************************************************************************
#IMPORTANT: This script has no error checking or other safeties in place. It expects you to know what you are doing. 
#WARNING: For internal use only. This will send lots of email, fast. This is a simple spambot and most real world mail servers are configured to block domains that spam.
#**********************************************************************************************************************
#PREREQUISITE: Enable mailserver in YaST. The sending mailserver must be configured with: connection type Permanent, Outgoing Mail set to the IP address of your receiving mail server. 
#SCHEDULE: To send messages hourly user "crontab -e", change the file path to where you stored the script "00 */1 * * * /root/Desktop/gopostal/gopostal.sh"
#**********************************************************************************************************************

#***CHANGE: Set your email domain!
#DOMAIN=set.your.domain
#DOMAIN=sfgw14.gwava.net
#DOMAIN=doc.mf.net

#***CHANGE: Specify the usernames to send to, they must exist in your email system. http://stackoverflow.com/questions/8880603/loop-through-array-of-strings-in-bash-script
declare -a USERNAME=('Aiden' 'Blake' 'Carter' 'Dakota' 'Eden' 'Finley' 'Hayden' 'Jayden' 'Kamryn' 'Riley' 'test0' 'test1' 'test2' 'test3' 'test4' 'test5' 'test6' 'test7' 'test8' 'test9')
#declare -a USERNAME=('user0' 'user1' 'user2' 'user3' 'user4' 'user5' 'user6' 'user7' 'user8' 'user9' 'user10' 'user11' 'user12' 'user13' 'user14' 'user15' 'user16' 'user17' 'user18' 'user19' 'user20')
#declare -a USERNAME=('test0' 'test1' 'test2' 'test3' 'test4' 'test5' 'test6' 'test7' 'test8' 'test9' 'test10' 'test11' 'test12' 'test13' 'test14' 'test15' 'test16' 'test17' 'test18' 'test19' 'test20' 'test21' 'test22' 'test23' 'test24' 'test25' 'test26' 'test27' 'test28' 'test29' 'test30' 'test31' 'test32' 'test33' 'test34' 'test35' 'test36' 'test37' 'test38' 'test39' 'test40' 'test41' 'test42' 'test43' 'test44' 'test45' 'test46' 'test47' 'test48' 'test49' 'test50' 'test51' 'test52' 'test53' 'test54' 'test55' 'test56' 'test57' 'test58' 'test59' 'test60' 'test61' 'test62' 'test63' 'test64' 'test65' 'test66' 'test67' 'test68' 'test69' 'test70' 'test71' 'test72' 'test73' 'test74' 'test75' 'test76' 'test77' 'test78' 'test79' 'test80' 'test81' 'test82' 'test83' 'test84' 'test85' 'test86' 'test87' 'test88' 'test89' 'test90' 'test91' 'test92' 'test93' 'test94' 'test95' 'test96' 'test97' 'test98' 'test99' 'test100')

#SET OPTIONS: Change these options, if desired.
#OPTIONAL: Specify the number of messages to send. By default will send 1 message to each user each time the script is run.
LOOP=1

#OPTIONAL: How large to fill the body of the message, in bytes, 1023 by default.
BODYSIZEMIN=256
BODYSIZEMAX=1024

#OPTIONAL: Do you want logging? YES | NO. 
LOGGING=YES
max_log_size_kb=10240

#OPTIONAL: Enable Attachments?  YES | NO
ATTACHMENTS=YES

#OPTIONAL: Provide random sender
declare -a SENDERNAMEARRAY=('Menolly_McCaffery@pern.org' 'Susan-Asimov@positronic.com' 'Guy.Bradbury@GreenTown.gov' 'ShallahSanderson@Elantrees.org' 'ModoHugo@Notre-Dame.org' 'AlonsaQuixana@LaMancha.gov' 'Charles.dArtagnan@musketeers.gov' 'Robert_Cohen@gisnip.com' 'Janet.J.Pabst@jones.com' 'JohnnyFive@nova.com' 'Ed209@omni.com' 'Dave@hal.com' 'gort@klaatu.org' 'Robby@lm.com' 'Marvin@sirius.com' 'Bob@robinson.edu' 'arnold@cyberdyne.com' 'DataSoong@omicrontheta.com' 'KaffTaylor@toughs.com' 'JaneKowal@austen.edu')

#**********************************************************************************************************************
#You should not have to change anything below this line. 
#FILES
#Set the location of the script and the support files

#Set path http://stackoverflow.com/questions/4774054/reliable-way-for-a-bash-script-to-get-the-full-path-to-itself
FILELOCATION="$( cd "$(dirname "$0")" ;  pwd -P )"

#Where is the script
CODEFILE="$FILELOCATION/gopostal.sh"

#SUBJECT: Data file for the subject.
SUBJECTIN="$FILELOCATION/subjectdata.dat"
#SUBJECTOUT is the completed randomized csv attachment. This file is temporary.
SUBJECTOUT="$FILELOCATION/subjectdata.tmp"

#BODY: Data files required for creating the body. This script is using "Alice in Wonderland" as it is in the public domain. You can replace it with any large text file.
BODYIN="$FILELOCATION/bodydata.dat"
#BODYOUT and BODY are shuffled and truncated output files. These files are temporary.
BODYOUT="$FILELOCATION/bodyshuf.tmp"
BODY="$FILELOCATION/bodytext.tmp"

#CSV: Data files required for creating the csv attachment. You can replace with any large comma delimited files.
CSVIN="$FILELOCATION/csvdata.dat"
CSVHEADER="$FILELOCATION/csvheader.dat"
#CSVSHUF and CSVOUT are shuffled and truncated output files. These files are temporary.
CSVSHUF="$FILELOCATION/csvshuf.tmp"
CSVOUT="$FILELOCATION/csvrand.tmp"
#sendfile.csv is the completed randomized csv attachment. This file is temporary.
CSVATTACHMENT="$FILELOCATION/sendfile.csv"

#HTML: Data file for random html attachment.
HTMLHEADER="$FILELOCATION/htmlheader.dat"
HTMLFOOTER="$FILELOCATION/htmlfooter.dat"
HTMLIN="$FILELOCATION/htmldata.dat"
#html temporary files.
HTMLSHUF="$FILELOCATION/htmlshuf.tmp"
HTMLOUT="$FILELOCATION/htmlout.tmp"
HTMLATTACHMENT="$FILELOCATION/htmlutf8file.html"

#LOG: Logging for developmental troubleshooting
LOGFILE="$FILELOCATION/gopostal.log"

#LOG: Check for maximum size of log file in kb. Default 10240kb (10MB)
file_size_kb=`du -k "$LOGFILE" | cut -f1`
echo Log size = "$file_size_kb" >> $LOGFILE 2>&1

if [[ $file_size_kb -gt $max_log_size_kb ]]
then
	rm $LOGFILE
	echo Removing gopostal.log
	LOGFILE="$FILELOCATION/gopostal.log"
fi

#LOG: when did it start
if [[ "$LOGGING" == YES ]]
then
	#echo "$(date "+%m%d%Y %T"): Beginning"
	echo "$(date "+%m%d%Y %T"): Beginning" >> $LOGFILE 2>&1
fi

#**********************************************************************************************************************
#MAIN
# loop through array http://stackoverflow.com/questions/8880603/loop-through-array-of-strings-in-bash-script
for u in "${USERNAME[@]}"
do
	#LOG: user being sent to
	if [[ "$LOGGING" == YES ]]
	then
		echo "$(date "+%m%d%Y %T"): To user: " "$u@$DOMAIN" >> $LOGFILE 2>&1
	fi
	#Create emails
	for (( i=1; i<=$LOOP; i++ ))
	do
		#Randomize a file so we have non-duplicates in Retain
		n=$RANDOM

		#BODY: Randomize body text
		shuf -n $n $BODYIN > $BODYOUT
		BODYSIZE="$( shuf -i $BODYSIZEMIN-$BODYSIZEMAX -n 1 )"
		#Get single block of text and suppress stderr
		dd if=$BODYOUT of=$BODY ibs=$BODYSIZE count=1 status=noxfer >& /dev/null
		#echo "$BODY"

		#SUBJECT: Shuffle subject line
		#https://stackoverflow.com/questions/9245638/select-random-lines-from-a-file-in-bash
		shuf -n 1 $SUBJECTIN > $SUBJECTOUT
		SUBJECT="$(<$SUBJECTOUT)"
		#echo $SUBJECT

		#SENDERNAME: Select Random sender from sender name array
		#https://stackoverflow.com/questions/2388488/select-a-random-item-from-an-array
		SENDERNAME=${SENDERNAMEARRAY[$RANDOM % ${#SENDERNAMEARRAY[@]} ]}

		if [[ "$ATTACHMENTS" == YES ]]
		then
			#CSV: Randomize csv data
			shuf -n $n $CSVIN > $CSVSHUF
			#Get single block of text and suppress stderr
			dd if=$CSVSHUF of=$CSVOUT ibs=$BODYSIZE count=1 status=noxfer >& /dev/null
			#make csv file with header
			cat $CSVHEADER $CSVOUT > $CSVATTACHMENT
	
			#HTML: Randomize html text
			shuf -n $n $HTMLIN > $HTMLSHUF
			dd if=$HTMLSHUF of=$HTMLOUT ibs=$BODYSIZE count=1 status=noxfer >& /dev/null
			#make html file with header and footer
			cat $HTMLHEADER $HTMLOUT $HTMLFOOTER > $HTMLATTACHMENT 

			#FILE: select a random file from dataset/ directory
			#https://unix.stackexchange.com/questions/131766/why-does-my-shell-script-choke-on-whitespace-or-other-special-characters
			RANDFILE=( "$(find $FILELOCATION/dataset -type f | shuf -n 1)" )
			#echo RANDFILE "${RANDFILE}"

			#CCNAME: Select Random Carbon Copied username from destination username array
			#https://stackoverflow.com/questions/2388488/select-a-random-item-from-an-array
			CCNAME=${USERNAME[$RANDOM % ${#USERNAME[@]} ]}

			#BCCNAME: Select Random Blind Carbon Copied username from destination username array
			#https://stackoverflow.com/questions/2388488/select-a-random-item-from-an-array
			BCCNAME=${USERNAME[$RANDOM % ${#USERNAME[@]} ]}

			#MAIL: send email to user with attachments
			#https://stackoverflow.com/questions/54725/change-the-from-address-in-unix-mail
			(cat $BODY)  | mail -r $SENDERNAME -c $CCNAME -b $BCCNAME -s "$SUBJECT $n $(date)" -a $CSVATTACHMENT -a "$HTMLATTACHMENT" -a "$CODEFILE" -a "${RANDFILE}" "$u"@$DOMAIN
		fi
		
		if [[ "$ATTACHMENTS" == NO ]]
		then
			#MAIL: send email to user without attachments or other extras
			(cat $BODY)  | mail -r $SENDERNAME -s "$SUBJECT $n $(date)" "$u"@$DOMAIN
		fi

		#LOG: each email sent
		if [[ "$LOGGING" == YES ]]
		then
			echo "$(date "+%m%d%Y %T")" "Item#:" "$i" "Item:" "$SUBJECT" "$SENDERNAME" "$CCNAME" "$BCCNAME" "${RANDFILE}" >> $LOGFILE 2>&1;
		fi
	done
done
#LOG: When did it finish
if [[ "$LOGGING" == YES ]]
then
	#echo "$(date "+%m%d%Y %T"): Done";
	echo "$(date "+%m%d%Y %T"): Done" >> $LOGFILE 2>&1;
fi
date
exit $?  
