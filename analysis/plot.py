import matplotlib.pyplot as plt
import sys
import re
import ast

# Get time and byte vectors
def plot_all(f_data, num_plots):
	f = open(f_data, 'r')
	lines = [line for line in f]
	for i in range(30):
		[client, server, match] = lines[i].split(':')
		client = ast.literal_eval(client)
		server = ast.literal_eval(server)
		plot(client, server, i)


# Plot client recv traffic vs server send traffic
def plot(client, server, i):
	time = range(1, len(client)+1)
	plt.figure(i)
	plt.hold
	plt.xlabel('Time (sec)')
	plt.ylabel('Bytes/sec')
	plt.title('Bytes/sec vs. Time')
	client_plot, = plt.plot(time, client, 'r')
	server_plot, = plt.plot(time, server, 'b')
	plt.legend([client_plot, server_plot], ['Client Traffic', 'Server Traffic'])
	plt.show()


if __name__ == '__main__':
	
	path = sys.argv[1]
	num_plots = int(sys.argv[2])

	plot_all(path, num_plots)
	
