import matplotlib.pyplot as plt
import sys


if __name__ == '__main__':

	tor_tp = [0.16, 0.26, 0.4, 0.5, 0.62, 0.74, 0.86, 0.86, 0.94]
	tor_fp = [0.000408163265306, 0.00244897959184, 0.00408163265306, 0.00938775510204, 0.0187755102041, 0.0314285714286, 0.054693877551, 0.114285714286, 0.262448979592]

	ss_tp = [0.124615384615, 0.299230769231, 0.436923076923, 0.554615384615, 0.663076923077, 0.760769230769, 0.828461538462, 0.885384615385, 0.927692307692]
	ss_fp = [0.0, 7.84929356358e-05, 0.000266875981162, 0.00119309262166, 0.00350078492936, 0.00894819466248, 0.0260753532182, 0.0872527472527, 0.262025117739]
	
	plt.figure()
	plt.hold
	plt.xlabel('False Positive Rate')
	plt.ylabel('True Positive Rate')
	plt.title('ROC Curve for Tor and ScrambleSuit Traffic')
	tor_plot, = plt.plot(tor_fp, tor_tp, 'g')
	scramblesuit_plot, = plt.plot(ss_fp, ss_tp, 'm')
	plt.legend([tor_plot, scramblesuit_plot], ['Normal Tor', 'ScrambleSuit'], loc='lower right')
	plt.show()
