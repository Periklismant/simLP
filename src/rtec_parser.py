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

	def p_negative_literal(self, p):
		''' literal : NOT atom '''
		p[0] = Atom(p[1], [p[2]])

	def p_atom(self, p):
		''' atom : predicate_name LPAREN args_list RPAREN '''
		p[0] = Atom(p[1], p[3])

	def p_atom_term(self, p):
		''' atom : term '''
		p[0] = p[1]

	def p_atom_eq(self, p):
		''' atom : atom EQUAL atom '''
		p[0] = Atom(p[2], [p[1], p[3]])

	def p_args_list_singleton_term(self, p):
		''' args_list : term '''
		p[0] = [p[1]]

	def p_args_list_singleton_atom(self, p):
		''' args_list : atom '''
		p[0] = [p[1]]

	def p_args_list_many_term(self, p):
		''' args_list : term COMMA args_list '''
		p[0] = [p[1]] + p[3]

	def p_args_list_many_atom(self, p):
		''' args_list : atom COMMA args_list '''
		p[0] = [p[1]] + p[3]

	def p_term(self, p):
		''' term : LOWCASESTR 
				 | VAR 
				 | NUMBER '''
		p[0] = Atom(p[1], [])

	def p_init_or_term(self,p):
		''' init_or_term : INITIATEDAT 
						 | TERMINATEDAT '''
		p[0] = p[1]

	def p_predicate_name(self, p):
		''' predicate_name : LOWCASESTR
						   | HAPPENSAT
						   | INITIATEDAT
						   | TERMINATEDAT
						   | HOLDSFOR 
						   | HOLDSAT '''
		p[0] = p[1]

	# Error handling
	def p_error(self,p):
		print("Syntax error at token", p.type)
