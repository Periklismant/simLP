import ply.lex as lex


class RTECLexer():

	def __init__(self):
		#print('Constructing lexer for RTEC programs.')
		self.lexer=lex.lex(module=self)

	#def __del__(self):
		#print('Lexer destructor called.')
	
	# TODO: Include Event Calculus predicates, start/end auxiliary events, interval operations, others?
	tokens = (
		'LPAREN',
		'RPAREN',
		'COMMA',
		'VAR',
		'DOT',
		'IMPL',
		#'LINECOMMENT',
		#'MULTILINECOMMENT',
		'EQUAL',
		'NOT',
		'LISTSTART',
		'LISTEND',
		#'NL',
		#'INITIATEDAT',
		#'TERMINATEDAT',
		#'HAPPENSAT',
		#'HOLDSAT',
		#'HOLDSFOR',
		#'UNIONALL',
		#'INTERSECTALL',
		#'COMPLEMENTALL',
		#'GROUNDING',
		#'INDEX',
		#'ENTITYDOMAIN',
		'LOWCASESTR',
		#'FLUENT',
		#'EVENT',
		'NUMBER'
	)
	# Regex patterns for tokens
	#t_INITIATEDAT = r'initiatedAt'
	#t_TERMINATEDAT = r'terminatedAt'
	#t_HAPPENSAT = r'happensAt'
	#t_HOLDSAT = r'holdsAt'
	#t_HOLDSFOR = r'holdsFor'
	#t_UNIONALL = r'union_all'
	#t_INTERSECTALL = r'intersect_all'
	#t_COMPLEMENTALL = r'relative_complement_all'
	#t_GROUNDING = r'grounding'
	#t_INDEX = r'index'
	#t_EVENT = r'event'
	#t_FLUENT = r'fluent'
	#t_ENTITYDOMAIN = r'entity_domain'
	t_LPAREN = r'\('
	t_RPAREN = r'\)'
	t_COMMA = r','
	t_VAR = r'[A-Z_][a-zA-Z0-9_]*'
	t_DOT = r'\.'
	t_IMPL = r'\:\-'
	t_ignore_LINECOMMENT = r'%.*\n'
	t_ignore_MULTILINECOMMENT= r'/\*[\s\S]*\*/'
	t_EQUAL = r'\='
	#t_NOT = r'\\\+|not'
	t_LISTSTART = r'\['
	t_LISTEND = r'\]'
	t_ignore_NL = r'\n'
	t_LOWCASESTR = r'([a-z][a-zA-Z0-9_]*)'
	t_NUMBER = r'[+-]?[0-9]+([.][0-9]+)?'

	def t_NOT(self, t):
		r'\\\+|not'
		t.value = '-'
		return t
	
	# Ignored characters (whitespace)
	t_ignore = ' \t'

	# Error handling function
	def t_error(self, t):
		print("Illegal character '%s'" % t.value[0])
		t.lexer.skip(1)
