#!/bin/bash

testServer() {
	while read line
	do
		echo $line
		ssh -n princeton_raptor@"$line" "hostname -i"
	done < ../nodes/server.txt
}

testServer
