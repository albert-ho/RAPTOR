#!/bin/bash

# -n used for parallel actions to redirect output in each ssh session to stdin
# add & at end of line outside of quotes for parallel
# CTRL-C interrupts foreground process and for some (fortunate) reason, does not kill tor/privoxy

startClient() {
	while read line
	do
		echo "Starting Client" $line
		ssh -o ConnectTimeout=10 -o StrictHostKeyChecking=no princeton_raptor@"$line" "sudo pkill tor; sudo /etc/init.d/privoxy start > privoxy_log.txt; tor/src/or/tor > log.txt;" &
	done < scripts_txt/client.txt
}

startClient
