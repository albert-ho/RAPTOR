import re
import sys
import ast
from operator import itemgetter

from scipy.stats.stats import pearsonr
from scipy.stats import spearmanr
from scipy.spatial.distance import correlation, pdist, squareform

import numpy as np
import math


def parse_line(line):
	[client, server, match] = line.split(':')
	client = ast.literal_eval(client)
	server = ast.literal_eval(server)
	return [client, server]


def correlate(client, server):
	'''
	if np.dot(client, server) == 0:
		return 0
	corr = correlation(client, server)
	if math.isnan(corr):
		corr = 1.0
	print corr
	return corr
	'''
	if np.dot(client, server) == 0:
		return 0
	corr = pearsonr(client, server)[0]
	#if math.isnan(corr):
		#corr = 1.0
	return corr
	

def correlate_data(client_list, server_list, cutoff):
	N = len(client_list)
	true_positive = 0
	false_positive = 0
	for i in range(N):
		for j in range(N):
			if correlate(client_list[i], server_list[j]) > cutoff:
				if i == j: true_positive = true_positive + 1
				else: false_positive = false_positive + 1
	true_positive = true_positive / float(N)
	false_positive = false_positive / float(N*(N-1))
	return [true_positive, false_positive]


def correlate_all_data(path, N):
	f = open(path, 'r')
	parsed_list = [parse_line(line) for line in f]
	client_list = [line[0] for line in parsed_list]
	server_list = [line[1] for line in parsed_list]
	f.close()
	num_trials = len(client_list)/N	
	#for cutoff in [0.9, 0.8, 0.7, 0.6, 0.5, 0.4, 0.3, 0.2, 0.1]:
	for cutoff in [0.5]:
		tp_arr = []
		fp_arr = []
		true_positive_total = 0
		false_positive_total = 0
		for i in range(num_trials):
			[true_positive, false_positive] = correlate_data(client_list[N*i:N*i+N], server_list[N*i:N*i+N], cutoff)
			tp_arr.append(true_positive)
			fp_arr.append(false_positive)
			true_positive_total = true_positive_total + true_positive
			false_positive_total = false_positive_total + false_positive
		true_positive_avg = float(true_positive_total) / num_trials
		false_positive_avg = float(false_positive_total) / num_trials
		f = open('accuracy.txt', 'a+')
		f.write('%s,%s\n' % (true_positive_avg, false_positive_avg))
		f.close()
		print np.std(tp_arr)
		print np.std(fp_arr)
		print num_trials

if __name__ == '__main__':
	np.seterr(all='raise')
	path = sys.argv[1]	
	N = int(sys.argv[2])
	correlate_all_data(path, N)
