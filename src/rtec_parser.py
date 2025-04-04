from rtec_lexer import *
from ply import yacc
#from event_description import Atom
#from propositional_logic import Proposition, Literal, ConjunctionOfLiterals, DNF
#from dependency_graph import DependencyGraph
from event_description import Atom, EventDescription

class RTECParser:
	
	def __init__(self):
		self.parser = yacc.yacc(module=self)
		self.event_description = EventDescription()

	tokens = RTECLexer.tokens
		
	# Grammar 
	def p_event_description(self,p):
		''' event_description : domain_rule 
							  | domain_rule event_description '''
		#p[0] = p[1]
		#p[0] = self.event_description.append(p[1])

	def p_domain_rule(self,p):
		''' domain_rule : atom IMPL\
								 body '''
		self.event_description.add_rule(p[1],p[3])

	def p_singleton_body(self,p):
		''' body : literal DOT '''
		p[0] = [p[1]]

	def p_body(self, p):
		''' body : literal COMMA body '''
		p[0]=[p[1]] + p[3]

	def p_positive_literal(self, p):
		''' literal : atom '''
		p[0] = p[1]

	def p_negative_literal1(self, p):
		''' literal : NOT atom '''
		p[0] = Atom(p[1], [p[2]])

	def p_negative_literal2(self, p):
		''' literal : NOT LPAREN args_list RPAREN '''
		p[0] = Atom(p[1], p[3])

	def p_is_literal(self, p):
		''' literal : atom IS atom '''
		p[0] = Atom(p[2], [p[1], p[3]])

	def p_atom(self, p):
		''' atom : LOWCASESTR LPAREN args_list RPAREN '''
		#print("Atom name: " + p[1])
		#print("Args: " + str(p[3]))
		p[0] = Atom(p[1], p[3])

	def p_atom_comma(self, p):
		''' atom : LPAREN args_list RPAREN '''
		#print("Atom name: " + p[1])
		#print("Args: " + str(p[3]))
		p[0] = Atom("comma", p[2])

	def p_atom_term(self, p):
		''' atom : term '''
		p[0] = p[1]

	def p_atom_list(self, p):
		''' atom : list '''
		p[0] = p[1]

	def p_atom_disj(self, p):
		''' atom : atom DISJ atom '''
		#print("Atom name: " + p[2])
		#print("Args: " + str(p[1]) + " and " + str(p[3]))
		p[0] = Atom(p[2], [p[1], p[3]])

	def p_atom_comp(self, p):
		''' atom : atom comp atom '''
		#print("Atom name: " + p[2])
		#print("Args: " + str(p[1]) + " and " + str(p[3]))
		p[0] = Atom(p[2], [p[1], p[3]])

	def p_arithmetic_expression_op(self, p):
		''' atom : atom arithmetic_operation atom '''
		p[0] = Atom(p[2], [p[1], p[3]])

	def p_arithmetic_expression_minus(self, p):
		''' atom : MINUS atom '''
		p[0] = Atom(p[1], [p[2]])

	def p_arithmetic_expression_paren(self, p):
		''' atom : LPAREN atom RPAREN '''
		p[0] = p[2]


	#def p_args_list_singleton_term(self, p):
	#	''' args_list : term '''
		#print("Args List singleton  term: " + str(p[1]))
	#	p[0] = [p[1]]

	def p_args_list_singleton_atom(self, p):
		''' args_list : literal '''
		#print("Args List singleton atom: " + str(p[1]))
		p[0] = [p[1]]

	#def p_args_list_singleton_list(self, p):
		#''' args_list : list '''
		#print("Args List singleton list: " + str(p[1]))
		#p[0] = [p[1]]

	#def p_args_list_many_term(self, p):
	#	''' args_list : term COMMA args_list '''
		#print("Args List many term: " + str(p[3]))
	#	p[0] = [p[1]] + p[3]

	def p_args_list_many_atom(self, p):
		''' args_list : literal COMMA args_list '''
		#print("Args List many atom: " + str(p[3]))
		p[0] = [p[1]] + p[3]

	#def p_args_list_many_list(self, p):
		#''' args_list : list COMMA args_list '''
		#print("Args List many list: " + str(p[3]))
		#p[0] = [p[1]] + p[3]

	def p_list(self, p):
		''' list : LISTSTART args_list LISTEND '''
		p[0] = Atom("list", p[2])

	def p_list_empty(self, p):
		''' list : LISTSTART LISTEND '''
		p[0] = Atom("list", [])

	def p_term(self, p):
		''' term : LOWCASESTR 
				 | VAR 
				 | NUMBER 
				 | STRING '''
		p[0] = Atom(p[1], [])

	def p_arithmetic_operation(self, p):
		''' arithmetic_operation : PLUS
					             | MINUS
					             | TIMES
					             | DIV '''
		p[0] = p[1]

	def p_comp(self, p):
		''' comp : EQUAL
			     | NEQUAL
				 | EQUAL EQUAL
				 | EQUAL EQUAL EQUAL
			     | NUMERICEQ
			     | NUMERICNEQ
			     | GE
			     | GEQ
			     | LE
			     | LEQ '''
		p[0] = ''.join(p[1:])


	# Error handling
	def p_error(self,p):
		print("Syntax error at token", p.type)
