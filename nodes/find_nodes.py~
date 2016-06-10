import xmlrpclib
import time

# Store machines from client.txt into dictionary	
with open('nodes/client.txt', 'r+') as f:
	list = f.read().split('\n')
clients = {}
for item in list:
	clients[item] = None	
	
# Store machines from server.txt into dictionary
with open('nodes/server.txt', 'r+') as f:
	list = f.read().split('\n')
servers = {}
for item in list:
	servers[item] = None
	
# Store machines from badNodes.txt into dictionary
with open('nodes/badNodes.txt', 'r+') as f:
	list = f.read().split('\n')
badNodes = {}
for item in list:
	badNodes[item] = None

# Getting the planetlab server??
api_server = xmlrpclib.ServerProxy('https://www.planet-lab.org/PLCAPI/')

# only add nodes active in the past day
length = 30*24*60*60
now = time.time()

# login credentials
auth = {}
auth['AuthMethod'] = "password"
auth['Username'] = "adho@princeton.edu"
auth['AuthString'] = "raptorplanet297"

#Checks if we are authorized
authorized = api_server.AuthCheck(auth)
if authorized:
    print 'We are authorized!'
else:
    print 'Authentication Error'

# Finds all active nodes to the slice
all_nodes = api_server.GetNodes(auth,{'run_level':'boot','boot_state':'boot'})

f = open('nodes/node.txt','r+')
f.truncate()

for entry in all_nodes:
    if (entry['last_contact']):
        diff = now - entry['last_contact']
        node = entry['hostname']
		# make sure client.txt and server.txt do not already have the node
        if (diff < length and not clients.has_key(node) and not servers.has_key(node) and not badNodes.has_key(node)):
	#if (diff < length and not clients.has_key(node) and not servers.has_key(node)):
            f.write(node + '\n')

f.close()

print 'Done!'

