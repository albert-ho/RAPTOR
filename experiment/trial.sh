#!/bin/bash


# Create new repository to store experiment data
# INPUT: Path to folder for data storage
newTrial() {
	local path="$1"
	mkdir $path
	
	#mkdir $path/ip_addresses
	#mkdir $path/ip_addresses/client_ip
	#mkdir $path/ip_addresses/server_ip
	
	mkdir $path/raw
	mkdir $path/raw/client
	mkdir $path/raw/server
	
	mkdir $path/parsed
	mkdir $path/parsed/client_recv
	mkdir $path/parsed/server_send

	cp nodes/client.txt $path
	cp nodes/server.txt $path
}


# Restart Tor, Privoxy on Clients, and Httpd on Servers
restartNodes() {
	while read client && read server <&3
	do
		ssh -o StrictHostKeyChecking=no princeton_raptor@"$client" "sudo pkill tor; sudo /etc/init.d/privoxy start > privoxy_log.txt; tor/src/or/tor > log.txt; exit;" &
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
		ssh -o StrictHostKeyChecking=no princeton_raptor@"$client" "sudo /usr/sbin/tcpdump -w client -n -u & sudo wget --output-file=wget_log.txt http://$server:7015/image.png & sleep $time; sudo pkill tcpdump; rm -f *.png*;" &
	done < nodes/client.txt 3< nodes/server.txt
}


# Convert Tshark files into text files with traffic logs
convertTraffic() {
	while read client && read server <&3
	do
		ssh -o StrictHostKeyChecking=no -n princeton_raptor@"$client" "/usr/local/bin/tshark -T fields -e frame.time_epoch -e ip.src -e ip.dst -e ip.len -e ip.hdr_len -e tcp.hdr_len -nr client -V > client.txt" &
		ssh -o StrictHostKeyChecking=no -n princeton_raptor@"$server" "/usr/local/bin/tshark -T fields -e frame.time_epoch -e ip.src -e ip.dst -e ip.len -e ip.hdr_len -e tcp.hdr_len -nr server -V > server.txt" &
	done < nodes/client.txt 3< nodes/server.txt
}

# Parse traffic logs for relevant fields and information
parseTraffic() {
	while read client && read server <&3
	do
		ssh -o StrictHostKeyChecking=no princeton_raptor@"$client" "python parse_client.py;" &
		ssh -o StrictHostKeyChecking=no princeton_raptor@"$server" "python parse_server.py;" &
	done < nodes/client.txt 3< nodes/server.txt
}


# Transfer traffic .txt files from client and server nodes into local repository
# INPUT: Path to folder for data storage
transferTraffic() {
	local data_path="$1"
	local i=0
	while read client && read server <&3
	do
		i=$((i+1))
		scp -o ConnectTimeout=10 princeton_raptor@"$client":client $data_path/raw/client/client_raw"$i" &
		scp -o ConnectTimeout=10 princeton_raptor@"$server":server $data_path/raw/server/server_raw"$i" &
		scp -o ConnectTimeout=10 princeton_raptor@"$client":client_parsed.txt $data_path/parsed/client_recv/client_parsed"$i".txt &
		scp -o ConnectTimeout=10 princeton_raptor@"$server":server_parsed.txt $data_path/parsed/server_send/server_parsed"$i".txt &
	done < nodes/client.txt 3< nodes/server.txt
}


# Transfer wget_log.txt files from client nodes into local repository
# INPUT: Path to folder for data storage
checkWget() {
	local path="$1"
	mkdir $path/wget_logs
	local i=0
	while read client && read server <&3
	do
		i=$((i+1))
		scp -o ConnectTimeout=10 princeton_raptor@"$client":wget_log.txt $path/wget_logs/client"$i".txt &
	done < nodes/client.txt 3< nodes/server.txt
}

# Run all the commands in one go for some number of trials
# INPUT: Index of starting trial, Index of ending trial
allInOne() {
	local startTrial=$1
	local endTrial=$2
	for i in `seq $startTrial $endTrial`;
	do
		echo "@@@@@@@@@@@@ NODES @@@@@@@@@@@@@@@@@@"
		python experiment/randomize.py "nodes/client.txt"
		sh setup/usePlugTrans.sh
		restartNodes & sleep 30
		echo "@@@@@@@@@@@@ TRIAL @@@@@@@@@@@@@@@@@@"
		newTrial "data/trial$i"
		runTrial 310 & sleep 340
		echo "@@@@@@@@@@@@ CONVERT @@@@@@@@@@@@@@@@@@"
		convertTraffic & sleep 30
		echo "@@@@@@@@@@@@ PARSE @@@@@@@@@@@@@@@@@@"
		parseTraffic $i & sleep 30
		echo "@@@@@@@@@@@@ TRANSFER @@@@@@@@@@@@@@@@@@"
		transferTraffic "data/trial$i" & sleep 30
		sleep 120

		#checkWget "Data/Trial$i" # POSSIBLY REMOVE?????
	done
}

#----------------------------------------
# MAIN
#----------------------------------------
allInOne $1 $2
#convertTraffic
#parseTraffic
#transferTraffic "data/trial1"