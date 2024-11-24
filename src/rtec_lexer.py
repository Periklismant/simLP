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
		'NOT',
		'LISTSTART',
		'LISTEND',
		'LOWCASESTR',
		'STRING',
		'NUMBER',
		'EQUAL',
		'NEQUAL',
		'NUMERICEQ',
		'NUMERICNEQ',
		'GE',
		'GEQ',
		'LE',
		'LEQ',
		'IS',
		'PLUS',
		'MINUS',
		'TIMES',
		'DIV',
		'DISJ'
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
	#t_NOT = r'\\\+|not'
	t_LISTSTART = r'\['
	t_LISTEND = r'\]'
	t_LOWCASESTR = r'(?!\b(?:is|not)\b)([a-z][a-zA-Z0-9_]*)'
	t_STRING = r'"([^"\n]|(\\"))*"|\'([^"\n]|(\\"))*\''
	t_NUMBER = r'[+-]?[0-9]+([.][0-9]+)?'

	t_EQUAL = r'\='
	t_NEQUAL = r'\\\='
	t_NUMERICEQ = r'\=\:\='
	t_NUMERICNEQ = r'\=\\\='

	t_LE = r'<'
	t_LEQ = r'\=<'
	t_GE = r'>'
	t_GEQ = r'>\='

	t_IS = r'is '
	
	t_PLUS = r'\+'
	t_MINUS = r'\-'
	t_TIMES = r'\*'
	t_DIV = r'\/'

	t_DISJ = r';'

	t_ignore_NL = r'\n'
	t_ignore_LINECOMMENT = r'%.*\n'
	t_ignore_MULTILINECOMMENT= r'/\*[\s\S]*\*/'

	#t_OPER = r'(\=)|(\=\\\=)'

	def t_NOT(self, t):
		r'\\\+|not\ '
		t.value = '-'
		return t
	
	# Ignored characters (whitespace)
	t_ignore = ' \t'

	# Error handling function
	def t_error(self, t):
		print("Illegal character '%s'" % t.value[0])
		t.lexer.skip(1)
