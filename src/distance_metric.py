# Extension of a distance metric between ground logical atoms (see expression (9) in SPLICE paper)
# in order to measure the distance between logical programs.

from event_description import Atom, Rule
import numpy as np
from scipy.optimize import linear_sum_assignment
from copy import deepcopy
import logging

def atomIsVar(atom):
	return atom.predicateName[0].isupper() or atom.predicateName[0]=="_"

def var_is_singleton(var, var_routes):
	return var[0]=="_" or len(var_routes[var])==1

def var_distance(var1, var2, var_routes1, var_routes2):
	if var_is_singleton(var1, var_routes1) and var_is_singleton(var2, var_routes2):
		return 0
	elif var_is_singleton(var1, var_routes1) or var_is_singleton(var2, var_routes2):
		return 1
	# Case: Both variables appear in the same atoms wrt nesting.
	elif sorted(var_routes1[var1])==sorted(var_routes2[var2]):
		return 0
	else:
		return 1

def atomIsConst(atom):
	return (atom.predicateName[0].islower() or atom.predicateName[0]=="&" or atom.predicateName.isnumeric()) and len(atom.args)==0 

def const_distance(const1, const2):
	return 0 if const1 == const2 else 1

def atomIsComp(atom):
	return len(atom.args)>0

def comp_atom_distance(atom1, atom2, var_routes1, var_routes2, logger):
	''' We use the distance metric proposed by Nienhuys-Cheng (1997). '''
	if atom1.predicateName == atom2.predicateName and len(atom1.args) == len(atom2.args):
		distances_sum=0
		for i in range(len(atom1.args)):
			my_distance = atom_distance(atom1.args[i], atom2.args[i], var_routes1, var_routes2, logger) 
			#logger.info("Distance between " + str(atom1) + " and " + str(atom2) + " is: " + str(my_distance))
			distances_sum += my_distance
		return 1/(2*len(atom1.args)) * distances_sum
	else:
		return 1

def atom_distance(atom1, atom2, var_routes1, var_routes2, logger):
	if atomIsVar(atom1) and atomIsVar(atom2):
		return var_distance(atom1.predicateName, atom2.predicateName, var_routes1, var_routes2)
	elif atomIsConst(atom1) and atomIsConst(atom2): 
		return const_distance(atom1.predicateName, atom2.predicateName)
	elif atomIsComp(atom1) and atomIsComp(atom2):
		return comp_atom_distance(atom1, atom2, var_routes1, var_routes2, logger)
	else:
		return 1

def pad_lists(list1, list2, pad_item):
	def pad_list(mylist, n):
		for _ in range(n):
			mylist.append(pad_item)
	if len(list1)>len(list2):
		pad_list(list2, len(list1)-len(list2))
	elif len(list2)>len(list1):
		pad_list(list1, len(list2)-len(list1))

def get_lists_size_and_pad(list1, list2, pad_item):
	def pad_list(mylist, n):
		for _ in range(n):
			mylist.append(pad_item)

	if len(list1)==len(list2):
		m = len(list1)
		k = len(list1)
	elif len(list1)>len(list2):
		m = len(list1)
		k = len(list2)
		pad_list(list2, m-k)
	elif len(list2)>len(list1):
		m = len(list2)
		k = len(list1)
		pad_list(list1, m-k)

	return m, k

def compute_var_routes(rule):
	var_routes = dict()
	
	def find_var_routes_in_atom(atom, route):
		#print("Atom: " + str(atom))
		##print("Route: " + str(route))
		#print("Var Routes: " + str(var_routes))
		#print()
		# For free variables, we do nothing.
		if atom.predicateName[0].isupper(): 
			if atom.predicateName in var_routes:
				var_routes[atom.predicateName].append(route)
			else:
				var_routes[atom.predicateName] = [route]
		else:
			for arg_index in range(0, len(atom.args)):
				find_var_routes_in_atom(atom.args[arg_index], route + [(atom.predicateName, arg_index)])

	find_var_routes_in_atom(rule.head, list())
	#print()
	for atom in rule.body:
		find_var_routes_in_atom(atom, list())
		#print()
	return var_routes


def rule_distance(rule1, rule2, logger):

	var_routes1 = compute_var_routes(rule1)
	#logger.info("Var routes for the first rule: ")
	#logger.info(var_routes1)
	#logger.info("")

	var_routes2 = compute_var_routes(rule2)
	#logger.info("Var routes for the second rule: ")
	#logger.info(var_routes2)
	#logger.info("")

	head1 = rule1.head
	head2 = rule2.head
	
	head_distance = atom_distance(head1, head2, var_routes1, var_routes2, logger)
	#logger.info("Distance between rule heads: ")
	#logger.info(head_distance)

	body1 = deepcopy(rule1.body)
	body2 = deepcopy(rule2.body)

	m, k = get_lists_size_and_pad(body1, body2, Atom("&", []))

	#print(body1)
	#print(body2)
	#print(m)
	#print(k)
	
	#c_dict = init_cost_dict(body1, body2)

	c_array = np.array([[0.0 for _ in range(m)] for _ in range(m)])

	for i in range(m):
		for j in range(m):
			c_array[i][j] = atom_distance(body1[i], body2[j], var_routes1, var_routes2, logger)

	#logger.info("Body atom distances: ")
	#logger.info(c_array)

	row_ind, col_ind = linear_sum_assignment(c_array)
	#logger.info("Optimal Body Condition Assignment: ")
	#logger.info(col_ind)

	optimal_dist_sum = c_array[row_ind, col_ind].sum()
	#logger.info("Sum of distances for optimal body condition assignment: ")
	#logger.info(optimal_dist_sum)
	
	# We penalise the absence of a condition in the distance function. Therefore, we do not add (m-k) in the distance, like in the Michelioudakis paper.
	body_distance = optimal_dist_sum/m # 1/m*(m - k + optimal_dist_sum)
	#logger.info("Distance between rule bodies: ")
	#logger.info(body_distance)

	# We penalise head incongruity as much as the incongruity of a pair of body literals
	rule_distance = 1/(m+1)*(head_distance + m*body_distance)
	#logger.info("Distance between rules: ")
	#logger.info(rule_distance)

	rule_similarity = 1 - rule_distance
	#logger.info("Similarity of rules: ")
	#logger.info(rule_similarity)

	return rule_distance

def event_description_distance(event_description1, event_description2, logger):

	rules1 = event_description1.rules
	rules2 = event_description2.rules

	m, k = get_lists_size_and_pad(rules1, rules2, Rule(Atom("_dummy_rule", []), []))

	print("Generated Event Description: ")
	print(event_description1)
	print()
	print("Ground Event Description: ")
	print(event_description2)
	print()

	logger.info("Generated Event Description: ")
	logger.info(event_description1)
	logger.info("")
	logger.info("Ground Event Description: ")
	logger.info(event_description2)
	logger.info("")

	c_array = np.array([[0.0 for _ in range(m)] for _ in range(m)])

	for i in range(m):
		for j in range(m):
			#logger.info("\nComparing rules:\n " + str(rules1[i]) + " and\n" + str(rules2[j]))
			c_array[i][j] = rule_distance(rules1[i], rules2[j], logger)

	logger.info("Rule distances: ")
	logger.info(c_array)
	logger.info("\n")

	row_ind, col_ind = linear_sum_assignment(c_array)
	logger.info("Optimal Rule Assignment: ")
	logger.info(col_ind)
	logger.info("\n")

	for i in range(len(col_ind)):
		logger.info("We matched rule:")
		logger.info(event_description1.rules[i])
		logger.info("which has the distance array: " + str(c_array[i]) + "\n") 
		logger.info("with the following rule: ")
		logger.info(event_description2.rules[col_ind[i]])
		logger.info("Their distance is: " + str(c_array[i, col_ind[i]]) + "\n")
		logger.info("\n")

	optimal_dist_sum = c_array[row_ind, col_ind].sum()
	logger.info("Sum of distances for optimal rule assignment: ")
	logger.info(optimal_dist_sum)
	
	event_description_distance = 1/m*(optimal_dist_sum)
	logger.info("Distance between event descriptions: ")
	logger.info(event_description_distance)

	event_description_similarity = 1 - event_description_distance
	logger.info("Event Description Similarity: ")
	logger.info(event_description_similarity)
	logger.info("")

	return col_ind, c_array[row_ind, col_ind], event_description_similarity


