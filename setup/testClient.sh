#!/bin/bash

# NEED TO CHECK THAT NODE HAS PRIVOXY INSTALLED
testClient() {
	local nodeList=$1
	while read line
	do
		cat $line.out > output
	done < nodes/nodeList
}

testClient
