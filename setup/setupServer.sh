#!/bin/bash

#-----------------------------
# Purpose: Set up web server on planetlab nodes
#-----------------------------


# Initial stuff for setup
# Might need to use option "No Strict Host Key Checking" for all machines
initialSetup() {
	while read line
	do
	echo $line
	ssh -o StrictHostKeyChecking=no princeton_raptor@"$line" "sudo yum -y --nogpgcheck install gcc; sudo yum -y install libevent-devel; sudo yum -y --nogpgcheck install openssl-devel; sudo yum -y --nogpgcheck install make; sudo yum -y --nogpgcheck install git; cd ~/;" &
	done < nodes/server.txt
}


# Store IP address of each server node into server_ip.txt
storeIP() {
	while read line
	do
		echo $line
		ssh -n princeton_raptor@"$line" "hostname -i > server_ip.txt;" &
	done < nodes/server.txt
}


# Update Python to 2.7.11
updatePython() {
	while read line
	do
	echo $line
	ssh -o StrictHostKeyChecking=no princeton_raptor@"$line" "sudo yum -y --nogpgcheck install bzip2-devel; wget --no-check-certificate https://www.python.org/ftp/python/2.7.11/Python-2.7.11.tgz; tar -xzf Python-2.7.11.tgz; cd Python-2.7.11; ./configure; make; sudo make install; wget --no-check-certificate http://curl.haxx.se/ca/cacert.pem; mv cacert.pem ca-bundle.crt; sudo mv ca-bundle.crt /etc/pki/tls/certs; wget --no-check-certificate https://bootstrap.pypa.io/ez_setup.py; sudo /usr/local/bin/python ez_setup.py --insecure; cd ~/;" &
	done < nodes/server.txt
}


# Set Up Web Server
installHttpd()
{
	local path="$1"
	while read server
	do	
	ssh -n princeton_raptor@$server "sudo yum -y --nogpgcheck install httpd; sudo sed 's/^Listen 80$/Listen 7015/' /etc/httpd/conf/httpd.conf > httpd.conf; sudo mv httpd.conf /etc/httpd/conf/httpd.conf; cd ~/;" &
	done < $path
}


# Store image file onto server
storeImage() {
	local path="$1"
	while read server
	do
	ssh -n princeton_raptor@$server "cd /var/www/html; sudo touch index.html; sudo wget http://eoimages.gsfc.nasa.gov/images/imagerecords/73000/73751/world.topo.bathy.200407.3x21600x21600.A2.png; sudo mv world.topo.bathy.200407.3x21600x21600.A2.png image.png; cd ~/;" &
	done < $path
}


# Install WireShark
# Use nogpgcheck to avoid some key value error in python on PlanetLab
installWireShark() {
	while read line
	do
	echo $line
	ssh -o StrictHostKeyChecking=no princeton_raptor@"$line" "sudo yum -y remove wireshark; sudo yum -y --nogpgcheck install bison byacc flex libpcap-devel gtk2-devel; sudo wget --no-check-certificate https://www.wireshark.org/download/src/all-versions/wireshark-1.4.1.tar.bz2; tar -xvjf wireshark-1.4.1.tar.bz2; cd wireshark-1.4.1; ./configure; make; sudo make install; cd ~/;" &
	done < nodes/server.txt
}


# Download the parse_server.py script onto each server machine
getParseScript() {
	while read line
	do
	echo $line
	scp simulation/parse_server.py princeton_raptor@"$line":~ &
	done < nodes/server.txt
}


#-----------------------------
# MAIN
#-----------------------------
#initialSetup
#storeIP
#updatePython
#installHttpd
#storeImage nodes/server.txt
#installWireShark
#getParseScript
