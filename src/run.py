from rtec_lexer import RTECLexer
from rtec_parser import RTECParser
from sys import argv

def parse_and_compute_distance(rules_file1, rules_file2):

	# init lexer and parser for RTEC programs.
	rtec_lexer = RTECLexer()
	rtec_parser1 = RTECParser()
	rtec_parser2 = RTECParser()

	# Transform the input RTEC program into tokens.
	lex = rtec_lexer.lexer
	 
	# Parse the program based on the grammar of the language of RTEC
	parser = rtec_parser1.parser
	with open(rules_file1) as f:
		parser.parse(f.read())
	
	event_description1 = rtec_parser1.event_description

	parser = rtec_parser2.parser
	with open(rules_file2) as f:
		parser.parse(f.read())
	
	event_description2 = rtec_parser2.event_description

	print("Event Description 1: ")
	print(event_description1)
	print()
	print("Event Description 2: ")
	print(event_description2)

if __name__=="__main__":
	# Required arguments.
	rules_file1 = argv[1]
	rules_file2 = argv[2]
	parse_and_compute_distance(rules_file1, rules_file2)
