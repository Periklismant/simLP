from rtec_lexer import RTECLexer
from rtec_parser import RTECParser
from distance_metric import event_description_distance
from sys import argv

def parse_and_compute_distance(rules_file1, rules_file2):

	# init lexer and parsers for RTEC programs
	rtec_lexer = RTECLexer()

	lex = rtec_lexer.lexer

	rtec_parser1 = RTECParser()
	parser = rtec_parser1.parser
	 
	# Transform the input RTEC programs into tokens, and then
	# parse the tokens based on the grammar of the language of RTEC

	# Parse the first input file
	with open(rules_file1) as f:
		parser.parse(f.read())

	event_description1 = rtec_parser1.event_description

	rtec_parser2 = RTECParser()
	parser = rtec_parser2.parser
	# Parse the second input file
	with open(rules_file2) as f:
		parser.parse(f.read())

	event_description2 = rtec_parser2.event_description

	# Compute the distance between the two event descriptions
	event_description_distance(event_description1, event_description2)


if __name__=="__main__":
	# Required arguments
	rules_file1 = argv[1]
	rules_file2 = argv[2]
	parse_and_compute_distance(rules_file1, rules_file2)
