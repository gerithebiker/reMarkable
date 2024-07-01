#!/bin/bash

pngList="myfile"
pointerFile="pointer"
currentPointer=0
ipfile="reMarkable"

ls ScreenSavers/*.png > $pngList

if [ ! -f $pointerFile ]; then
	echo 1 > $pointerFile
	myPointer=1
else
	myPointer=$(cat $pointerFile)
fi

if [ $myPointer -gt $(wc -l myfile | awk '{print $1}') ]; then
	echo "Looks like you deleted some files, resetting the pointer"
	echo 1 > $pointerFile
	myPointer=1
	echo $myPointer
fi

if [ ! -f $ipfile ]; then
	printf "I need the IP address of your reMarkable: "
	read rMip
	echo $rMip > $ipfile
else
	rMip=$(cat $ipfile)
fi
# sed '/192.168.1.136/d' -i known
while read -r pic;do
	currentPointer=$(($currentPointer+1))
	if [ $currentPointer -eq $myPointer ]; then
		echo "Uploading $pic, pointer is: $currentPointer"
		scp  $pic root@$rMip:/usr/share/remarkable/suspended.png 2>/tmp/connErr
		hiba=$?
		myErr=`cat /tmp/connErr | grep "WARNING: REMOTE HOST IDENTIFICATION HAS CHANGED!" | wc -l`
                rm /tmp/connErr
                echo "$hiba --- $myErr"
		if [ $hiba -eq 0 ]; then
			if (( $currentPointer == $(wc -l myfile | awk '{print $1}') )); then
				echo 1 > $pointerFile
			else
				echo $(($currentPointer+1)) > $pointerFile
			fi
		else
			case $hiba in
				1)
					if [ $myErr -eq 1 ]; then 
                                            mv -f ~/.ssh/known_hosts ~/.ssh/known_hosts.old
                                            cat ~/.ssh/known_hosts.old | grep -v $rMip > ~/.ssh/known_hosts
                                            scp  $pic root@$rMip:/usr/share/remarkable/suspended.png
                                            echo "\nThe ssh key to reMarkable has changed, I hope the fix worked..."
                                        else
					    echo "I was unable to connect to reMarkable, is it on?"
                                        fi
					;;
				127)
					echo "Looks like scp is not installed, could you pls check?"
					;;
				*)
					echo "I am sorry, there was an issue I am not aware of, pls troubleshoot!!!"
					;;
			esac
		fi
	fi
done < ./$pngList

