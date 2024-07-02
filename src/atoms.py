class Atom:
	def __init__(self, predicateName, args):
		self.predicateName = predicateName
		self.args= args

	def __repr__(self):
		return f'{self.predicateName}/{self.args}'

class Body:
	def __init__(self, atoms):
		self.atoms = atoms

	def __repr__(self):
		return ',\n\t'.join(self.atoms)

class Rule:
	def __init__(self, head, body):
		self.head = Atom(head)
		self.body = Body(body)

	def __repr__(self):
		return '{self.head} :- \n\t{self.body}'

class EventDescription:
	def __init__(self):
		self.rules = []
	
	#def __init__(self, rules):
		#self.rules = rules

	def add_rule(self, head, body):
		self.rules.append(Rule(head, body))

	def __repr__(self):
		return '\n'.join(self.rules)
