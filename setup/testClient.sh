#!/bin/bash

# NEED TO CHECK THAT NODE HAS PRIVOXY INSTALLED
testClient() {
	while read client
	do
		echo "@@@@@@@@@@@@@@"
		echo "Testing Client" $client
		echo "@@@@@@@@@@@@@@"
		ssh -o ConnectTimeout=10 -o StrictHostKeyChecking=no -n princeton_raptor@"$client" "cat log.txt; cat privoxy_log.txt;"
	done < nodes/client.txt
}

testClient
