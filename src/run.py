from rtec_lexer import RTECLexer
from rtec_parser import RTECParser
from distance_metric import event_description_distance
from sys import argv
import logging

def parse_and_compute_distance(rules_file1, rules_file2, log_file='log.txt'):
	
	# Set logger
	def setup_logger(log_file, level=logging.INFO):
		"""To setup as many loggers as you want"""

		handler = logging.FileHandler(log_file, mode='w') 
		formatter = logging.Formatter('%(message)s')
		handler.setFormatter(formatter)

		logger = logging.getLogger(log_file)
		logger.setLevel(logging.INFO)
		logger.addHandler(handler)

		return logger

	print("Log file: " + log_file)
	logger = setup_logger(log_file)

	# init lexer and parsers for RTEC programs
	rtec_lexer = RTECLexer()
	lex = rtec_lexer.lexer

	rtec_parser1 = RTECParser()
	parser = rtec_parser1.parser
	 
	# Transform the input RTEC programs into tokens, and then
	# parse the tokens based on the grammar of the language of RTEC

	with open(rules_file1) as f:
		parser.parse(f.read())

	event_description1 = rtec_parser1.event_description

	rtec_parser2 = RTECParser()
	parser = rtec_parser2.parser
	with open(rules_file2) as f:
		parser.parse(f.read())

	event_description2 = rtec_parser2.event_description

	optimal_matching, distances, similarity = event_description_distance(event_description1, event_description2, logger)
	print()
	print("Optimal Matching: ")
	print(optimal_matching)
	print()
	print("Rule Distances: ")
	print(distances)
	print()
	print("Similarity: ")
	print(similarity)
	print()

	return optimal_matching, distances, similarity


if __name__=="__main__":
	# Required 
	rules_file1 = argv[1]
	rules_file2 = argv[2]
	# optional 
	log_file = argv[3]
	parse_and_compute_distance(rules_file1, rules_file2, log_file)
