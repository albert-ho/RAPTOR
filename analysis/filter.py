import sys
import ast

def check_end(vector):
	if sum(vector[190:200]) == 0:
		return False
	return True


def check_end_big(vector):
	if sum(vector[150:200]) == 0:
		return False
	return True


def is_okay(client, server):
	return (check_end(client) and check_end(server)) or (not check_end(client) and not check_end(server)) and (not check_end_big(client) and not check_end_big(server))

def filter(f_data, f_filter):
	'''
	Read data from file f_data and filter out the data for any
	bad client/server vectors, writing the good data to f_filter
	'''
	f = open(f_data, 'r')
	lines = [line for line in f]
	f.close()
	f = open(f_filter, 'w+')
	for line in lines:
		[client, server, match] = line.split(':')
		client = ast.literal_eval(client)
		server = ast.literal_eval(server)
		if is_okay(client, server):
			f.write(line)
	f.close()


if __name__ == '__main__':
	
	path_data = sys.argv[1]		# Name of file from which data is to be read
	path_filter = sys.argv[2]	# Name of file from which filtered data to be written to
	
	filter(path_data, path_filter)
