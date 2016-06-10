import re
import sys
import os
from collections import Counter


# Takes: A file string with an IP address
# Returns: The IP address
def get_node_ip(f_ip):
    f = open(f_ip, 'r')
    ip = [line.rstrip('\n') for line in f][0]
    f.close()
    return ip


# Takes: A file string for the traffic and the string for the node's IP address
# Returns: String for the Tor relay/bridge IP address
def get_tor_ip(f_string, node_ip):
	f = open(f_string)
	ip_list = []
	for line in f:
		parsed = parse.parse_line(line)
		if parsed == None: continue
		if node_ip == parsed['send_ip']:
			ip_list.append(parsed['recv_ip'])
		elif node_ip == parsed['recv_ip']:
			ip_list.append(parsed['send_ip'])
	f.close()
	tor_ip = Counter(ip_list).most_common(1)[0][0]
	return tor_ip


# Takes: String as hours:minutes:seconds
# Returns: Float as time in seconds
def time_to_sec(time):
	time = time.split(":")
	time = 3600 * int(time[0]) + 60 * int(time[1]) + float(time[2])
	return time


## Takes: String for a line of traffic data
## Returns: Dictionary of parsed information from traffic data
def parse_line(line):
    arr = re.split(' |\n|\t|\x00', line)
    arr = filter(None, arr)
    if len(arr) <= 5: return None
    time = time_to_sec(arr[3])
    send_ip = arr[5]
    recv_ip = arr[6]
    seq = arr[7]
    ack = arr[8]
    return {"time": time, "send_ip": send_ip, "recv_ip": recv_ip, "seq": seq, "ack": ack}


# Takes: Strings for node IP, tor IP, sender IP, and receiver IP 
# Returns: True if node IP is sender and tor IP is receiver
def check_node_to_tor(node_ip, tor_ip, send_ip, recv_ip):
    return ((node_ip == send_ip) and (tor_ip == recv_ip))


# Takes: Strings for node IP, tor IP, sender IP, and receiver IP
# Returns: True if tor IP is sender and node IP is receiver
def check_tor_to_node(node_ip, tor_ip, send_ip, recv_ip):
	return ((tor_ip == send_ip) and (node_ip == recv_ip))
	

# Takes: Strings for file f1, file f2, node IP, tor IP, and the function for checking direction
# Does: Writes parsed lines from f1 to f2 of form (time, seq, ack)
def write_parsed_file(f_raw, f_parsed, node_ip, tor_ip, check_direction):
    f1 = open(f_raw, 'r')
    f2 = open(f_parsed, 'w+')
    prev_seq = 0
    prev_ack = 0
    first = True
    for line in f1:
        parsed = parse_line(line)
        if parsed == None: return
        if (first and (tor_ip == parsed["send_ip"] or tor_ip == parsed["recv_ip"])):
			start_time = parsed["time"]
			first = False        
        if (check_direction(node_ip, tor_ip, parsed["send_ip"], parsed["recv_ip"])):
            time = parsed["time"] - start_time
            data_seq = int(parsed["seq"]) - prev_seq
            data_ack = int(parsed["ack"]) - prev_ack
            forward_line = str(time) + '\t' + str(data_seq) + '\t' + str(data_ack) + '\n'
            f2.write(forward_line)
            prev_seq = int(parsed["seq"])
            prev_ack = int(parsed["ack"])
    f1.close()
    f2.close()
		

# Takes: List of server IPs, List of Tor exit IPs, Number of nodes
# Does: Takes traffic lines from /data/ file and parses them for (time, seq, ack) 
def write_client_recv(path, i):
	f_raw = '%s/data_raw/client/client%s.txt' % (path, i)
	f_parsed = '%s/data_parsed/client_recv/client%s.txt' % (path, i)
	f_node_ip = '%s/ip_addresses/client%s.txt' % (path, i)
	client_ip = get_node_ip(f_node_ip)
	entry_ip = get_tor_ip(f_raw, client_ip)
	write_parsed_file(f_raw, f_parsed, client_ip, entry_ip, check_tor_to_node)


# Takes: List of server IPs, List of Tor exit IPs, Number of nodes
# Does: Takes traffic lines from /data/ file and parses them for (time, seq, ack) 
# Writes this to /data_par/
def write_server_send(path, i):
	f_raw = '%s/data_raw/server/server%s.txt' % (path, i)
	f_parsed = '%s/data_parsed/server_send/server%s.txt' % (path, i)
	f_node_ip = '%s/ip_addresses/server%s.txt' % (path, i)
	server_ip = get_node_ip(f_node_ip)
	exit_ip = get_tor_ip(f_raw, server_ip)
	write_parsed_file(f_raw, f_parsed, server_ip, exit_ip, check_node_to_tor)


if __name__ == '__main__':
    
    # Path to Experiment
    path = sys.argv[1]
    
    # Index for Client/Server
    
    '''
    # Number of nodes
    N = int(sys.argv[2])
	
	for i in range(1, N+1):
		#write_client_send(path, i)
		write_client_recv(path, i)    
		write_server_send(path, i)
		#write_server_recv(path, i)
	'''
