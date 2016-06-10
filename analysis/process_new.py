if __name__ == '__main__':
	for i in range(1, 110):
		client_len = len([name for name in os.listdir(path + '/data_parsed/client_recv')])
		server_len = len([name for name in os.listdir(path + '/data_parsed/server_send')])	
		for j in range(1, N):
			write
