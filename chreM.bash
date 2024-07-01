#!/bin/bash

if [ "$1" == "" ]; then echo "Melyik masina? [-c|-g|-l]"; echo "Exiting..."; exit; fi

reM="reMarkable"

case $1 in
	-c) 
		echo "192.168.1.227" > $reM 
		;;
	-g)
		echo "192.168.1.136" > $reM
		;;
	-l)
		echo "10.11.99.1" > $reM
		;;
	*)
		echo "Wrong choice, [-c|-g|-l] are the valid choices. Exiting..."
		;;
esac

