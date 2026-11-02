from event_description import EventDescription


def get_defined_concept_key(atom):
	# Rules and facts on an FVP, e.g. initiatedAt(F=V, T) or fi(F=V, F=V2, D), are keyed by the fluent of F=V and the head predicate.
	if atom.predicateName in ["initiatedAt", "terminatedAt", "holdsFor", "fi", "p", "initially"] and len(atom.args)>0:
		fvp = atom.args[0]
		if fvp.predicateName=="=" and len(fvp.args)==2:
			return (fvp.args[0].predicateName, atom.predicateName)
	return ("other", "other")

def partition_event_description(event_description):
	partitioned_event_description = dict()
	for rule in event_description.rules:
		defined_concept_key = get_defined_concept_key(rule.head)
		if defined_concept_key not in partitioned_event_description:
			partitioned_event_description[defined_concept_key] = EventDescription()
		partitioned_event_description[defined_concept_key].add_rule(rule.head, rule.body)
	return partitioned_event_description


