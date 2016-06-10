import sys

def check_redundant(f_str):	
	with open(f_str, 'r') as f:
		f_list = f.read().split('\n')
	stuff = {}
	count = 0
	for item in f_list:
		count = count + 1
		if stuff.has_key(item):
			print item + " is already in list in " + str(count)
		stuff[item] = None
		
if __name__ == '__main__':
	path = sys.argv[1]
	check_redundant(path)
