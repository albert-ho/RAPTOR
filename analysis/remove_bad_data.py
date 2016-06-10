import sys
import os

def remove_client_raw(pair, N):
	path = 'Experiment/data_raw/client/'
	client = 'client%s.txt' % pair
	os.remove(path + client)
	for i in range (pair+1, N+1):
		client_old = 'client%s.txt' % i
		client_new = 'client%s.txt' % (i-1)
		os.rename(path + client_old, path + client_new)

def remove_server_raw(pair, N):
	path = 'Experiment/data_raw/server/'
	server = 'server%s.txt' % pair
	os.remove(path + server)
	for i in range (pair+1, N+1):
		server_old = 'server%s.txt' % i
		server_new = 'server%s.txt' % (i-1)
		os.rename(path + server_old, path + server_new)
	

def remove_pair(pair, N):
	remove_client_raw(pair, N)
	remove_server_raw(pair, N)

# "assignment" = 1
# "current" = 1
# Check number of bytes in both client and server files for "current"
# If >= 10,000 bytes:
# 	assign client-server pair the "assignment" index
#	parse client-server pair "current" -> "assignment" index in parsed files
#	increment "assignment", increment "current"
# If < 10,000 bytes:
# 	increment "current"



if __name__ == '__main__':
	pair = int(sys.argv[1])
	N = int(sys.argv[2])
	remove_pair(pair, N)
