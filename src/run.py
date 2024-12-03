from rtec_lexer import RTECLexer
from rtec_parser import RTECParser
from distance_metric import event_description_distance
from partitioner import partition_event_description
from sys import argv
import logging

def parse_and_compute_distance(generated_rules_file, ground_rules_file, log_file='log.txt'):
	
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

	logger = setup_logger(log_file)

	# init lexer and parsers for RTEC programs
	rtec_lexer = RTECLexer()
	lex = rtec_lexer.lexer

	rtec_parser1 = RTECParser()
	parser = rtec_parser1.parser
	 
	# Transform the input RTEC programs into tokens, and then
	# parse the tokens based on the grammar of the language of RTEC

	with open(generated_rules_file) as f:
		parser.parse(f.read())

	generated_event_description = rtec_parser1.event_description

	rtec_parser2 = RTECParser()
	parser = rtec_parser2.parser
	with open(ground_rules_file) as f:
		parser.parse(f.read())

	ground_event_description = rtec_parser2.event_description

	# Event Description Preprocessing 
	## We split an input event description into multiple event descriptions, each defining the initiations, the terminations or the intervals of a different FVP.
	gen_ed_partitions = partition_event_description(generated_event_description)
	gen_ed_keys = gen_ed_partitions.keys()

	#for key in gen_ed_keys:
	#	print("Key: " + str(key))
	#	print("Event Description: " + str(gen_ed_partitions[key]))

	ground_ed_partitions = partition_event_description(ground_event_description)
	ground_ed_keys = ground_ed_partitions.keys()

	#for key in ground_ed_keys:
		#print("Key: " + str(key))
		#print("Event Description: " + str(ground_ed_partitions[key]))

	both_eds_keys = sorted(list(set(ground_ed_keys) & set(gen_ed_keys)))

	print()
	print("Partition keys in both event descriptions: ")
	print(both_eds_keys)
	print()
	
	similarities = dict()
	for key in both_eds_keys:
		#print()
		#print("Partition Key: ")
		#print(key)
		#print()
		optimal_matching, distances, similarity = event_description_distance(gen_ed_partitions[key], ground_ed_partitions[key], logger)
		#print()
		#print("Optimal Matching: ")
		#print(optimal_matching)
		#print()
		#print("Rule Distances: ")
		#print(distances)
		#print()
		#print("Similarity: ")
		#print(similarity)
		#print()
		similarities[key]=similarity

	print(similarities)

	gen_ed_only_keys = list(set(gen_ed_keys) - set(ground_ed_keys))
	print()
	print("Partition keys only in generated event description: ")
	print(gen_ed_only_keys)
	print()

	ground_ed_only_keys = list(set(ground_ed_keys) - set(gen_ed_keys))
	print()
	print("Partition keys only in ground event description: ")
	print(ground_ed_only_keys)
	print()
	for key in ground_ed_only_keys:
		similarities[key]=0

	for key in similarities:
		print("Similarity for key: " + str(key) + " is " + str(similarities[key]))

	print("Average Event Description Similarity is: ")
	print(sum(similarities.values())/(len(both_eds_keys)+len(ground_ed_only_keys)))

	return
	#return optimal_matching, distances, similarity


if __name__=="__main__":
	# Required 
	rules_file1 = argv[1]
	rules_file2 = argv[2]
	# optional 
	log_file = argv[3]
	parse_and_compute_distance(rules_file1, rules_file2, log_file)
