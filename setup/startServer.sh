#!/bin/bash

startServer() {
	local path="$1"
	while read line
	do
	echo $line
	ssh -o ConnectTimeout=10 -o StrictHostKeyChecking=no -n princeton_raptor@"$line" "sudo pkill httpd; sudo /etc/init.d/httpd start"
	done < $path
}

checkHasImage() {
	local path="$1"
	while read line
	do
	echo "@@@@@@@"
	echo $line
	echo "@@@@@@@"
	ssh -o ConnectTimeout=10 -o StrictHostKeyChecking=no -n princeton_raptor@"$line" "ls /var/www/html/image.png"
	done < $path
}

startServer nodes/server.txt
#checkHasImage nodes/server.txt
