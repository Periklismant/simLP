class Atom:
	def __init__(self, predicateName, args):
		self.predicateName = predicateName
		self.args= args

	def __repr__(self):
		if len(self.args)>0:
			return f'{self.predicateName}(' + ','.join(map(str,self.args)) + ')'
		else:
			return f'{self.predicateName}'

	def __eq__(self, other):
		if not isinstance(other, Atom):
			return False
		return self.predicateName == other.predicateName and self.args == other.args

	def __hash__(self):
		return hash(self.predicateName + str(self.args))

class Rule:
	def __init__(self, head, body):
		self.head = head
		self.body = body

	def __repr__(self):
		return f'{self.head} :- \n\t' + ',\n\t'.join(map(str,self.body)) + '.\n'

class EventDescription:
	def __init__(self):
		self.rules = []
	
	def add_rule(self, head, body):
		self.rules.append(Rule(head, body))

	def __repr__(self):
		return '\n'.join(map(str,self.rules))
