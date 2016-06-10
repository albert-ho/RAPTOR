import os
import sys
	
def checkClients(N):
	path = 'Experiment/data_raw/client/'
	for i in range (1, N+1):
		client = 'client%s.txt' % i
		print client + '\t' + str(os.path.getsize(path + client))
		
def checkServers(N):
	path = 'Experiment/data_raw/server/'
	for i in range (1, N+1):
		server = 'server%s.txt' % i
		print server + '\t' + str(os.path.getsize(path + server))
		
if __name__ == '__main__':
	N = int(sys.argv[1])
	checkClients(N)
	checkServers(N)
