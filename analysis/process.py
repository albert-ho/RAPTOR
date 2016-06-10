import re
import sys
import math
import itertools
import os
import ast
import time as test_time

# Data seems to clump within 1/100th of a second of each other


# Parses in line into (time, byte) format
def parse_line(line):
	[time, byte, space] = re.split(' |\n|\t', line)
	return [float(time), int(byte)]


# Returns [time, byte_sum]
def handle_group(time, group):
	group_list = list(group)
	byte_sum = 0
	for packet in group_list:
		byte_sum = byte_sum + packet[1]
	return [time, byte_sum]


# Aggregate packet bunches by time partition	
def aggregate_by_partition(parsed_list, start, end, partition):
	byte_vector = []
	time = start
	i = 0
	while time < end:
		byte_group = 0
		while i < len(parsed_list) and parsed_list[i][0] < time + partition:
			byte_group = byte_group + parsed_list[i][1]
			i = i + 1
		byte_vector.append(byte_group)
		time = time + partition
	return byte_vector


# Uses bytes per time partition
def process_list(parsed_list, start, end, partition):
	parsed_list = [line for line in parsed_list if (start <= line[0] and line[0] <= end)]
	byte_vector = aggregate_by_partition(parsed_list, start, end, partition)
	return byte_vector
	
	
# Write traffic to data.txt
def write_to_data_file(start, end, partition, path, i):
	f_c_parsed = open('%s/data_parsed/client_recv/client%s.txt' % (path, i), 'r')
	f_s_parsed = open('%s/data_parsed/server_send/server%s.txt' % (path, i), 'r')
	
	c_parsed_list = [parse_line(line) for line in f_c_parsed]
	s_parsed_list = [parse_line(line) for line in f_s_parsed]
	
	c_byte_vector = process_list(c_parsed_list, start, end, partition)
	s_byte_vector = process_list(s_parsed_list, start, end, partition)
	
	f_data = open('data.txt', 'a')
	f_data.write('%s:%s:1\n' % (c_byte_vector, s_byte_vector))
	f_data.close()
	
	f_c_parsed.close()
	f_s_parsed.close()
	


if __name__ == '__main__':
	
	start = float(sys.argv[1])		# Start time for correlation (seconds)
	end = float(sys.argv[2])		# End time for correlation (seconds)
	partition = float(sys.argv[3])		# Aggregate amount of data being transfered within partitions of time (seconds)
	path = sys.argv[4]			# Path to directory where data is stored


	for i in range(61, 64):
		path_trial = path + ('/Trial%s' % i)
		client_len = len([name for name in os.listdir(path_trial + '/data_parsed/client_recv')])
		server_len = len([name for name in os.listdir(path_trial + '/data_parsed/server_send')])
		N = min(client_len, server_len)
		for j in range(1, N):
			write_to_data_file(start, end, partition, path_trial, j)
