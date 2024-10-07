from event_description import EventDescription


def get_defined_concept_key(atom):
	if atom.predicateName=="initiatedAt":
		return (atom.args[0].args[0].predicateName, "initiatedAt")
	elif atom.predicateName=="terminatedAt":
		return (atom.args[0].args[0].predicateName, "terminatedAt")
	elif atom.predicateName=="holdsFor":
		return (atom.args[0].args[0].predicateName, "holdsFor")
	else:
		return "other"

def partition_event_description(event_description):
	partitioned_event_description = dict()
	for rule in event_description.rules:
		defined_concept_key = get_defined_concept_key(rule.head)
		if defined_concept_key not in partitioned_event_description:
			partitioned_event_description[defined_concept_key] = EventDescription()
		partitioned_event_description[defined_concept_key].add_rule(rule.head, rule.body)
	return partitioned_event_description


