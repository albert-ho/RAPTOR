#!/bin/bash


# Create new repository to store experiment data
# INPUT: Path to folder for data storage
newTrialFolder() {
	local path="$1"
	mkdir $path
	
	mkdir $path/client
	mkdir $path/server
	mkdir $path/logs

	cp nodes/client.txt $path
	cp nodes/server.txt $path
}


# Restart Tor, Privoxy on Clients, and Httpd on Servers
restartNodes() {
	while read client && read server <&3
	do
		ssh -o StrictHostKeyChecking=no princeton_raptor@"$client" "rm -f *.png*; sudo pkill tor; sudo /etc/init.d/privoxy start > privoxy_log.txt; tor/src/or/tor; exit;" &
		#ssh -o StrictHostKeyChecking=no -n princeton_raptor@"$server" "sudo pkill httpd; sudo /etc/init.d/httpd start" &
	done < nodes/client.txt 3< nodes/server.txt
}


# Run the experiment: each client simultaneously downloading file from each server
# INPUT: Time duration of download
runTrial() {
	local time=$1
	while read -r client && read -r server <&3
	do
		ssh -o StrictHostKeyChecking=no princeton_raptor@"$server" "sudo /etc/init.d/httpd start; sudo /usr/sbin/tcpdump -w server -n -U & sleep $time; sudo pkill tcpdump;" &
		ssh -o StrictHostKeyChecking=no princeton_raptor@"$client" "sudo /usr/sbin/tcpdump -w client -n -u & sudo wget http://$server:7015/image.png & sleep $time; sudo pkill tcpdump;" &
	done < nodes/client.txt 3< nodes/server.txt
}


# Transfer traffic .txt files from client and server nodes into local repository
# INPUT: Path to folder for data storage
transferTraffic() {
	local trial_path="$1"
	while read client && read server <&3
	do
		scp -o ConnectTimeout=10 princeton_raptor@"$client":client $trial_path/client/"$client" &
		scp -o ConnectTimeout=10 princeton_raptor@"$server":server $trial_path/server/"$server" &
	done < nodes/client.txt 3< nodes/server.txt
}


# Run all the commands in one go for some number of trials
# INPUT: Path name to trial
allInOne() {
	local trial_path=$1
	local num_nodes=$2
	echo "@@@@@@@@@@@@    NODES @@@@@@@@@@@@@@@@@@"
	python experiment/randomize.py "nodes/client.txt"
	sh setup/usePlugTrans.sh
	restartNodes & sleep 30
	echo "@@@@@@@@@@@@    TRIAL @@@@@@@@@@@@@@@@@@"
	newTrialFolder "$trial_path"
	runTrial 310 & sleep 340
	echo "@@@@@@@@@@@@  CONVERT @@@@@@@@@@@@@@@@@@"
	convertTraffic & sleep 30
	echo "@@@@@@@@@@@@    PARSE @@@@@@@@@@@@@@@@@@"
	parseTraffic $i & sleep 30
	echo "@@@@@@@@@@@@ TRANSFER @@@@@@@@@@@@@@@@@@"
	transferTraffic "$trial_path" & sleep 30
	sleep 120
}

#----------------------------------------
# MAIN
#----------------------------------------
allInOne $1
