#!/bin/bash

# Run commands for synchronizing nodes and check the nodes' clock times
checkSync()
{
	local path="$1"
	sync_time=$(($(date +%s) + 15));
	vxargs -y -a nodes/both.txt -o $path/logs/log0/ -P 70 -t 30 ssh -o StrictHostKeyChecking=no princeton_raptor@{} "remote_time=\$(date +%s); sleep_time=\$(($sync_time - \$remote_time)); echo \$sleep_time"
}

# Create the new folder and sub-folders for the trial running.
newTrial() 
{
	local path="$1";
	local bridge="$2";
	
	mkdir $path;
	mkdir $path/client;
	mkdir $path/server;
	mkdir $path/logs;
	
	cp nodes/client.txt $path;
	cp nodes/server.txt $path;
	cp bridges/$bridge.txt $path;
}

# Have server nodes start httpd & (kill old processes)
startServers() 
{
	local path="$1";
	vxargs -y -a nodes/server.txt -o $path/logs/log1/ -P 30 -t 10 ssh princeton_raptor@{} "sudo /etc/init.d/httpd restart &"
}

# Have client nodes change their torrc files for the appropriate pluggable transport (using while loop)
usePlugTrans() 
{
	sh experiment/usePlugTrans.sh
}

# Have client nodes start Tor and privoxy & (kill old processes), also clean up old image files
startClients() 
{
	local path="$1"
	vxargs -y -a nodes/client.txt -o $path/logs/log2/ -P 30 -t 30 ssh -o StrictHostKeyChecking=no princeton_raptor@{} "rm -f *.png*; sudo pkill tor; sudo /etc/init.d/privoxy start; tor/src/or/tor &" 
}

# Have client nodes save file with name of corresponding server for experiment (using while loop)
pairClientsToServers()
{
	while read client && read server <&3
	do
		ssh -o StrictHostKeyChecking=no princeton_raptor@"$client" "touch server.txt; echo $server >> server.txt" &
	done < nodes/client.txt 3< nodes/server.txt
}

# Have client nodes perform wget request in sync using server files on them
performWget()
{
	local path="$1"
	sync_time=$(($(date +%s) + 15));
	vxargs -y -a nodes/client.txt -o $path/logs/log3/ -P 30 -t 10 ssh -o StrictHostKeyChecking=no princeton_raptor@{} "remote_time=\$(date +%s); sleep_time=\$(($sync_time - \$remote_time)); sleep \$sleep_time; 
	server=$(head -1 server.txt); sudo wget --output-file=wget.txt http://$server:7015/image.png"
}

# Have client and server nodes both start tcpdump in sync
# Addition: If the node is a client, perform wget request
syncTcpdump()
{
	local path="$1"
	local time="$2"

	sync_time=$(($(date +%s) + 15));
	vxargs -y -a nodes/both.txt -o $path/logslog4/ -P 60 -t 100 ssh -o StrictHostKeyChecking=no princeton_raptor@{} "remote_time=\$(date +%s); sleep_time=\$(($sync_time - \$remote_time)); sleep \$sleep_time; 
	sudo /usr/sbin/tcpdump -w capture -n -U & sleep $time; sudo pkill tcpdump & if [ -f server.txt ]; then sudo wget --output-file=wget.txt http://$server:7015/image.png; fi;"
}

# Have client nodes export capture files into /client/ subfolder
exportClientFiles()
{
	local path="$1"
	vxargs -y -a nodes/client.txt -o $path/logs/log5/ -P 30 -t 30 scp -o StrictHostKeyChecking=no princeton_raptor@{}:capture $path/client/{}
}

# Have server nodes export capture files into /server/ subfolder
exportServerFiles()
{
	local path="$1"
	vxargs -y -a nodes/server.txt -o $path/logs/log6/ -P 30 -t 30 scp -o StrictHostKeyChecking=no princeton_raptor@{}:capture $path/server/{}
}

main()
{
	checkSync "trial1"
	#newTrial "trial1" "none"
	#startServers "trial1"
	#usePlugTrans
	#startClients "trial1"
	#pairClientsToServers
	#performWget "trial1"
	#syncTcpdump "trial1" 100
	#exportClientFiles "trial1"
	#exportServerFiles "trial1"
}

main
