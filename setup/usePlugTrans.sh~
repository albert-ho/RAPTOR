#!/bin/bash

#-----------------------------
# Purpose: Use the following pluggable transport
#-----------------------------

useNone() {
	while read client
	do
	echo $client
	ssh -o ConnectTimeout=10 -o StrictHostKeyChecking=no princeton_raptor@"$client" "touch dummy; sudo mv dummy /usr/local/etc/tor/torrc; cd ~/" &
	done < nodes/client.txt
}


useObfs3() {
	while read client && read bridge <&3
	do
	echo $client
	ssh -o ConnectTimeout=10 -o StrictHostKeyChecking=no princeton_raptor@"$client" "touch dummy; echo 'UseBridges 1' >> dummy; echo 'Bridge ' $bridge >> dummy; echo 'ClientTransportPlugin obfs3 exec /usr/local/bin/obfsproxy --managed' >> dummy; sudo mv dummy /usr/local/etc/tor/torrc; cd ~/" &
	done < nodes/client.txt 3< bridges/bridgesObfs3.txt
}


useScrambleSuit() {
	while read client && read bridge <&3
	do
	echo $client
	ssh -o ConnectTimeout=10 -o StrictHostKeyChecking=no princeton_raptor@"$client" "touch dummy; echo 'UseBridges 1' >> dummy; echo 'Bridge ' $bridge >> dummy; echo 'ClientTransportPlugin scramblesuit exec /usr/local/bin/obfsproxy --managed' >> dummy; sudo mv dummy /usr/local/etc/tor/torrc; cd ~/" &
	done < nodes/client.txt 3< bridges/bridgesScrambleSuit.txt
}


# https://github.com/Yawning/obfs4
useObfs4() {
	while read client && read bridge <&3
	do
	echo $client
	ssh -o ConnectTimeout=10 -o StrictHostKeyChecking=no princeton_raptor@"$client" "touch dummy; echo 'UseBridges 1' >> dummy; echo 'Bridge ' $bridge >> dummy; echo 'ClientTransportPlugin @@@@FIX THIS PATH@@@@ exec /usr/local/bin/obfsproxy --managed' >> dummy; sudo mv dummy /usr/local/etc/tor/torrc; cd ~/" &
	done < nodes/client.txt 3< bridges/bridgesObfs4.txt
}


#------------------
# MAIN
#------------------
#useNone
useScrambleSuit
