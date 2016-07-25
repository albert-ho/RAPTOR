# Python Script
# merge_logs.py

import sys
import os

# MUST RUN ON OPERATING SYSTEM THAT USES FORWARD SLASHES '\' FOR FILES
# (e.g. not Windows)

if __name__ == "__main__":
	
	log_path = sys.argv[1]
	node_path = sys.argv[2]
	
	outputs = open("{}/MERGED.out".format(log_path), "w+")
	errors = open("{}/MERGED.err".format(log_path), "w+")
	statuses = open("{}/MERGED.status".format(log_path), "w+")
	nodes = open(node_path, "r")
	
	for node in nodes.readlines():
		node = node.rstrip()
		if os.path.isfile("{}/{}.out".format(log_path, node)):
			
			outputs.writelines("\n@@@@@@@@@@ {} @@@@@@@@@@\n".format(node))
			node_out = open("{}/{}.out".format(log_path, node), "r")
			outputs.writelines(node_out.readlines())
			node_out.close()
			
			errors.writelines("\n@@@@@@@@@@ {} @@@@@@@@@@\n".format(node))
			node_err = open("{}/{}.err".format(log_path, node), "r")
			errors.writelines(node_err.readlines())
			node_err.close()
			
			statuses.writelines("\n@@@@@@@@@@ {} @@@@@@@@@@\n".format(node))
			node_status = open("{}/{}.status".format(log_path, node), "r")
			statuses.writelines(node_status.readlines())
			node_status.close()
		
	nodes.close()
	outputs.close()
	errors.close()
	statuses.close()
	
	
