from rtec_lexer import RTECLexer
from rtec_parser import RTECParser
from sys import argv

def parse_rules(rules_file):

	# init lexer and parser for RTEC programs.
	rtec_lexer = RTECLexer()
	rtec_parser = RTECParser()

	# Transform the input RTEC program into tokens.
	lex = rtec_lexer.lexer
	 
	# Parse the program based on the grammar of the language of RTEC
	parser = rtec_parser.parser
	f = open(rules_file)
	parser.parse(f.read())
	f.close()

	print(str(rtec_parser.event_description))

if __name__=="__main__":
	# Required arguments.
	rules_file = argv[1]
	parse_rules(rules_file)
