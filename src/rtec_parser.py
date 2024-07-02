from rtec_lexer import *
from ply import yacc
#from event_description import Atom
#from propositional_logic import Proposition, Literal, ConjunctionOfLiterals, DNF
#from dependency_graph import DependencyGraph
from atoms import Atom, EventDescription

class RTECParser:
	
	def __init__(self):
		print('init parser')
		self.parser = yacc.yacc(module=self)
		print('init ed')
		self.event_description = EventDescription()

	tokens = RTECLexer.tokens
		
	# Grammar 
	def p_event_description(self,p):
		''' event_description : domain_rule 
							  | domain_rule event_description '''
		print('parsing ed')
		#p[0] = p[1]
		#p[0] = self.event_description.append(p[1])

	def p_domain_rule(self,p):
		''' domain_rule : simple_fluent_rule
						| statically_determined_fluent_rule '''
		print('parsing domain rule')
		#p[0] = p[1]
						#| event_rule 

	def p_simple_fluent_rule(self,p):
		''' simple_fluent_rule : init_or_term_atom IMPL\
								 body '''
		print('parsing simple fluent rule')
		self.event_description.add_rule(p[1],p[3])


	def p_statically_determined_fluent_rule(self, p):
		''' statically_determined_fluent_rule : holdsFor_atom  IMPL\
												body '''
		self.event_description.add_rule(p[1],p[3])
 
	def p_holdsFor_atom(self, p):
		''' holdsFor_atom : HOLDSFOR LPAREN fluent_value_pair COMMA interval_list_var RPAREN '''
		p[0] = Atom(p[1], [p[3], p[5]])

	def p_init_or_term_atom(self, p):
		''' init_or_term_atom : init_or_term LPAREN fluent_value_pair COMMA time_var RPAREN '''
		p[0] = Atom(p[1], [p[3], p[5]])

	def p_fluent_value_pair(self, p):
		''' fluent_value_pair : atom EQUAL atom '''
		p[0] = Atom(p[2], [p[1], p[3]])

	def p_time_var(self,p):
		''' time_var : VAR '''
		p[0] = Atom(p[0], [])

	def p_interval_list_var(self,p):
		''' interval_list_var : VAR '''

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
		print("Atom: ")
		print("\tPredicate Name: " + str(p[1]))
		print("\tArgs: " + str(p[3]))
		p[0] = Atom(p[1], p[3])

	def p_atom(self, p):
		''' atom : term '''
		p[0] = p[1]

	def p_atom_eq(self, p):
		''' atom : atom EQUAL atom '''
		print(str(p[1]) + "=" + str(p[3]))
		p[0] = Atom(p[2], [p[1], p[3]])

	def p_args_list_singleton_term(self, p):
		''' args_list : term '''
		print("singleton term " + str(p[1]))
		p[0] = [p[1]]

	def p_args_list_singleton_atom(self, p):
		''' args_list : atom '''
		print("singleton atom " + str(p[1]))
		p[0] = [p[1]]

	def p_args_list_many(self, p):
		''' args_list : term COMMA args_list '''
		print("many term " + str(p[1]))
		p[0] = [p[1]] + p[3]

	def p_args_list_many(self, p):
		''' args_list : atom COMMA args_list '''
		print("many atom " + str(p[1]))
		p[0] = [p[1]] + p[3]

	def p_term(self, p):
		''' term : LOWCASESTR 
				 | VAR 
				 | NUMBER '''
		print(p[1])
		p[0] = Atom(p[1], [])

	def p_init_or_term(self,p):
		''' init_or_term : INITIATEDAT 
						 | TERMINATEDAT '''

		print(p[1])
		p[0] = p[1]

	def p_predicate_name(self, p):
		''' predicate_name : LOWCASESTR
						   | HAPPENSAT
						   | INITIATEDAT
						   | TERMINATEDAT
						   | HOLDSFOR 
						   | HOLDSAT '''
		print(p[1])
		p[0] = p[1]

	# Error handling
	def p_error(self,p):
		print("Syntax error at token", p.type)
		yacc.errok()
