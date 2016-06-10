#!/bin/bash


# Create new repository to store experiment data
# INPUT: Path to folder for data storage
newTrial() {
	local path="$1"
	mkdir $path
	
	mkdir $path/ip_addresses
	mkdir $path/ip_addresses/client_ip
	mkdir $path/ip_addresses/server_ip
	
	mkdir $path/data_raw
	mkdir $path/data_raw/client
	mkdir $path/data_raw/server
	
	mkdir $path/data_parsed
	mkdir $path/data_parsed/client_recv
	mkdir $path/data_parsed/server_send
}


# Run the experiment: each client simultaneously downloading file from each server
# INPUT: Time duration of download
runTrial() {
	local time=$1
	while read -r client && read -r server <&3
	do
		ssh -o StrictHostKeyChecking=no princeton_raptor@"$server" "sudo /etc/init.d/httpd start; sudo /usr/sbin/tcpdump -w server -n -U & sleep $time; sudo pkill tcpdump;" &
		ssh -o StrictHostKeyChecking=no princeton_raptor@"$client" "sudo /usr/sbin/tcpdump -w client -n -u & sudo wget --output-file=wget_log.txt http://$server:7015/world.topo.bathy.200407.3x21600x21600.A2.png & sleep $time; sudo pkill tcpdump; rm -f *.png*;" &
	done < nodes/client.txt 3< nodes/server.txt
}


convertTraffic() {
	while read client && read server <&3
	do
		ssh -o StrictHostKeyChecking=no -n princeton_raptor@"$client" "/usr/local/bin/tshark -T fields -e frame.time_epoch -e ip.src -e ip.dst -e ip.len -e ip.hdr_len -e tcp.hdr_len -nr client -V > client.txt" &
		ssh -o StrictHostKeyChecking=no -n princeton_raptor@"$server" "/usr/local/bin/tshark -T fields -e frame.time_epoch -e ip.src -e ip.dst -e ip.len -e ip.hdr_len -e tcp.hdr_len -nr server -V > server.txt" &
	done < nodes/client.txt 3< nodes/server.txt
}


# Transfer traffic .txt files from client and server nodes into local repository
# INPUT: Path to folder for data storage
transferTraffic() {
	local path="$1"
	local i=0
	while read client && read server <&3
	do
		i=$((i+1))
		scp -o ConnectTimeout=10 princeton_raptor@"$client":client.txt $path/data_raw/client/client"$i".txt &
		scp -o ConnectTimeout=10 princeton_raptor@"$server":server.txt $path/data_raw/server/server"$i".txt &
	done < nodes/client.txt 3< nodes/server.txt
}


restartNodes() {
	while read client && read server <&3
	do
		ssh -o StrictHostKeyChecking=no princeton_raptor@"$client" "sudo pkill tor; sudo /etc/init.d/privoxy start > privoxy_log.txt; tor/src/or/tor > log.txt;" &
		#ssh -o StrictHostKeyChecking=no -n princeton_raptor@"$server" "sudo pkill httpd; sudo /etc/init.d/httpd start" &
	done < nodes/client.txt 3< nodes/server.txt
}


parseTraffic() {
	while read client && read server <&3
	do
		ssh -o StrictHostKeyChecking=no princeton_raptor@"$client" "python parse_client.py;" &
		ssh -o StrictHostKeyChecking=no princeton_raptor@"$server" "python parse_server.py;" &
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
		python simulation/randomize.py "nodes/client.txt"
		sh setup/usePlugTrans.sh
		restartNodes & sleep 20 # DON'T NEED TO RESTART????????????
		echo "@@@@@@@@@@@@ TRIAL @@@@@@@@@@@@@@@@@@"
		newTrial "Data/Trial$i"
		runTrial 210 & sleep 230
		echo "@@@@@@@@@@@@ CONVERT @@@@@@@@@@@@@@@@@@"
		convertTraffic & sleep 25
		echo "@@@@@@@@@@@@ TRANSFER @@@@@@@@@@@@@@@@@@"
		transferTraffic "Data/Trial$i" & sleep 30
		#checkWget "Data/Trial$i" # POSSIBLY REMOVE?????
		echo "@@@@@@@@@@@@ PYTHON @@@@@@@@@@@@@@@@@@"
		runPython $i &
	done
}


# Transfer wget_log.txt files from client nodes into local repository
# https://www.gnu.org/software/wget/manual/html_node/Logging-and-Input-File-Options.html
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


#----------------------------------------
# MAIN
#----------------------------------------
#allInOne $1 $2
#convertTraffic
parseTraffic
