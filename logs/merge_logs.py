# Python Script
# merge_logs.py

import sys
import os

# Input a name to the merged_output_log
# Input the name of the file for node_script
# Input the name of the folder where node output files are located
# Create the new merged_output_log in current directory
# Read a line in node_script
# Add @@@ planetlab node @@@ to merged_output_log
# Read planetlab node's output file
# Write all of the content into merged_output_log
# Close planetlab node's output file
# Move onto next line in node_script for next node

# Create a main class
if __name__ == "__main__":
	merged_file = sys.argv[1]
	nodes_list = sys.argv[2]
	log_folder = sys.argv[3]
	
