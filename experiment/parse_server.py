import re
import sys
import os
from collections import Counter

'''
The goal of this script is as follows:
Assume this script has been downloaded on each PlanetLab Server machine.
For the given machine, this script reads a traffic data file (t-shark log).
This script will parse the traffic data such that what remains is 
the traffic incoming from the PlanetLab entry relay to the Server.
This will be in the format of each line being a packet's (time in seconds, bytes).
To do this, we need to determine which IP address it the Server machine's,
and which IP address is the Tor entry relay's machine.
'''

# CHECK STARTING TIME OF TRAFFIC FILES AND MAKE SURE THEY ARE THE SAME

# DON'T RUN THIS FROM LOCAL MACHINE, ONLY TO BE USED ON REMOTE MACHINES

# Returns the IP address of the node as a string
def get_node_ip():
	f = open('server_ip.txt', 'r')
	ip = f.readline().rstrip('\n')
	f.close()
	return ip


# Returns the IP address for the Tor relay/bridge as a string
def get_tor_ip():
	node_ip = get_node_ip()
	f = open('server.txt', 'r')
	ip_list = []
	for line in f:
		parsed = parse_line(line)
		if parsed == None: continue
		if node_ip == parsed['send_ip']:
			ip_list.append(parsed['recv_ip'])
		elif node_ip == parsed['recv_ip']:
			ip_list.append(parsed['send_ip'])
	f.close()
	tor_ip = Counter(ip_list).most_common(1)[0][0]
	return tor_ip


## Takes a string for a line of traffic data
## Returns a dictionary of parsed information from traffic data
def parse_line(line):
	arr = re.split(' |\n|\t|\x00', line)
	arr = filter(None, arr)
	if len(arr) < 6: return None
	[epoch_time, send_ip, recv_ip, ip_len, ip_hdr_len, tcp_hdr_len] = arr
	byte = int(ip_len) - int(ip_hdr_len) - int(tcp_hdr_len)
	return {"epoch_time": epoch_time, "send_ip": send_ip, "recv_ip": recv_ip, "byte": byte}


# Writes parsed traffic data from server.txt to server_parsed.txt
def write_server_parsed():
	node_ip = get_node_ip()
	tor_ip = get_tor_ip()
	f1 = open('server.txt', 'r')
	f2 = open('server_parsed.txt', 'w+')
	for line in f1:
		parsed = parse_line(line)
		if parsed == None: continue  
		if (node_ip == parsed['send_ip'] and tor_ip == parsed['recv_ip']):
			f2.write('%s\t%s\n' % (parsed['epoch_time'], parsed['byte']))
	f1.close()
	f2.close()


if __name__ == '__main__':
	write_server_parsed()

