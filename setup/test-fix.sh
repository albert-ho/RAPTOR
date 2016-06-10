#!/bin/bash

testServer() {
	while read line
	do
		echo $line
		ssh -n princeton_raptor@"$line" "ls /var/www/html/image.png;"
	done < ../nodes/server.txt
}

testServer
