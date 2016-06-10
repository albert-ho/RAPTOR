# Store machines from client.txt into dictionary	
with open('nodes/client.txt', 'r') as f:
	list = f.read().split('\n')
clients = {}
for item in list:
	if clients.has_key(item):
		print item + " is already in client list"
	clients[item] = None	
	
# Store machines from client.txt into dictionary	
with open('nodes/server.txt', 'r') as f:
	list = f.read().split('\n')
servers = {}
for item in list:
	if servers.has_key(item):
		print item + " is already in server list"
	servers[item] = None	
	
# Store machines from server.txt into dictionary
count = 0
for node in servers:
	count = count + 1
	if clients.has_key(node):
		print node + "is being used as both client and server on line " + str(count)
