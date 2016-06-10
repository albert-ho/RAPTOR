import sys
import random

def randomize(f_string):
	f = open(f_string, 'r')
	lines = [line for line in f if line is not '\n']
	f.close()
	random.shuffle(lines)
	f = open(f_string, 'w+')
	for line in lines:	
		f.write(line)
	f.close()

if __name__ == '__main__':
	path = sys.argv[1]
	#path = nodes/client.txt
	randomize(path)
