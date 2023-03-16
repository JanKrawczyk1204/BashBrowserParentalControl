#!/bin/bash
# Author           : Jan Krawczyk
# Created On       : 20.05.2022r.
# Last Modified By : Jan Krawczyk ( s188793@student.pg.edu.pl )
# Last Modified On : 29.05.2022r.
# Version          : 1.0
#
# Description      :
# This program allows user to see the history of browsing 
# websides in mozzilla firefox and subbmit forbiden pages that cannot be
# browsed
#
# Licensed under GPL (see /usr/share/common-licenses/GPL for more details
# or contact # the Free Software Foundation for a copy)

helpf()
{
	echo "Before running program open firefox"
	echo "Input list of forbiden wesides"
	echo "Press q when you are done"
	echo "When you finish browsing simply close firefox to end program"
}
versionf()
{
	echo "version 1.0"
}
while getopts hv OPT; do
	case $OPT in
		h) helpf;;
		v) versionf;;
	esac
done
TEMP1="/tmp/temp1.$$"
TEMP2="/tmp/temp2.$$"

echo "Enter websides you want to block and then press q"
QUIT=1
while : 
do
	read POLECENIE
	if [ "$POLECENIE" = "q" ]; then
		break
	else
		echo $POLECENIE >> $TEMP1
	fi

done
echo "Websides blocked by you:"
cat< $TEMP1 
while :
do
	check=`ps -e | grep "firefox"`
	if [ -z "$check" ]
	then
		break
	fi
	VAL=`lz4jsoncat ~/.mozilla/firefox/*.default-release/sessionstore-backups/recovery.jsonlz4 | jq -r ".windows[0].tabs | sort_by(.lastAccessed)[-1] | .entries[.index-1] | .url " | cut -d'/' -f3` 
	echo $VAL >> $TEMP2
	while IFS= read -r line
	do
		if [ "$line" = "$VAL" ]; then
			zenity --warning \
			--text="You are not supposed to be here"
			pkill firefox
			break
		fi
	done < "$TEMP1"
	sleep 1
done 
cat< $TEMP2 | uniq -c | sort -nr
rm $TEMP1
rm $TEMP2
