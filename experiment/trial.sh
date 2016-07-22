#!/bin/bash

main() {
	
	# Create the new folder and sub-folders for the trial running.
	local path="$1";
	local bridge="$2";
	
	mkdir $path;
	mkdir $path/client;
	mkdir $path/server;
	mkdir $path/logs;
	
	cp nodes/client.txt $path;
	cp nodes/server.txt $path;
	cp bridges/$bridge.txt $path;

	# Have server nodes start httpd & (kill old processes)
	vxargs -y -a nodes/server.txt -o $path/logs/log1/ -P 30 -t 10 ssh princeton_raptor@{} "sudo pkill httpd; sudo /etc/init.d/httpd start &"

	# Have client nodes change their torrc files for the appropriate pluggable transport (using while loop)
	sh usePlugTrans.sh

	# Have client nodes start Tor and privoxy & (kill old processes), also clean up old image files
	vxargs -y -a nodes/client.txt -o $path/logs/log2/ -P 30 -t 10 ssh princeton_raptor@{} "rm -f *.png*; sudo pkill privoxy; sudo pkill tor; sudo /etc/init.d/privoxy start; tor/src/or/tor &" 

	# Have client nodes save file with name of corresponding server for experiment (using while loop)
	while read client && read server <&3
	do
		ssh -o StrictHostKeyChecking=no princeton_raptor@"$client" "touch server.txt; echo $server >> server.txt" &
	done < nodes/client.txt 3< nodes/server.txt

	# Have client nodes perform wget request in sync using server files on them
	sync_time=$(($(date +%s) + 30));
	vxargs -y -a nodes/client.txt -o log3/ -P 30 -t 600 ssh princeton_raptor@{} 
	"remote_time=\$(date +%s); sleep_time=\$(($sync_time - \$remote_time)); sleep \$sleep_time; 
	server=$(head -1 server.txt); sudo wget http://$server:7015/image.png &"

	# Have client and server nodes both start tcpdump in sync
	sync_time=$(($(date +%s) + 30));
	vxargs -y -a nodes/both.txt -o log4/ -P 60 -t 600 ssh princeton_raptor@{} 
	"remote_time=\$(date +%s); sleep_time=\$(($sync_time - \$remote_time)); sleep \$sleep_time; 
	sudo /usr/sbin/tcpdump -w capture -n -U & sleep $time; sudo pkill tcpdump;"

	# Have client nodes export capture files into /client/ subfolder
	vxargs -y -a nodes/client.txt -o log5/ -P 30 -t 60 scp princeton_raptor@{}:capture $trial_path/client/{}

	# Have server nodes export capture files into /server/ subfolder
	vxargs -y -a nodes/server.txt -o log6/ -P 30 -t 60 scp princeton_raptor@{}:capture $trial_path/server/{}
}
