# Implementation of the distance metric between ground logical atoms (see expression (9) in SPLICE paper)

from event_description import Atom, Rule
import numpy as np
from scipy.optimize import linear_sum_assignment
from copy import deepcopy

def atom_distance(atom1, atom2):
	if atom1 == atom2:
		return 0
	elif atom1.predicateName == "_" or atom2.predicateName == "_":
		return 0
	elif atom1.predicateName != atom2.predicateName or len(atom1.args) != len(atom2.args):
		return 1
	else:
		distances_sum=0
		for i in range(len(atom1.args)):
			distances_sum += atom_distance(atom1.args[i], atom2.args[i])
		return 1/(2*len(atom1.args)) * distances_sum

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

def rule_distance(rule1, rule2):

	head1 = rule1.head
	head2 = rule2.head
	
	head_distance = atom_distance(head1, head2)
	print("Distance between rule heads: ")
	print(head_distance)

	body1 = deepcopy(rule1.body)
	body2 = deepcopy(rule2.body)

	m, k = get_lists_size_and_pad(body1, body2, Atom("_", []))

	print(body1)
	print(body2)
	print(m)
	print(k)
	
	#c_dict = init_cost_dict(body1, body2)

	c_array = np.array([[0.0 for _ in range(m)] for _ in range(m)])

	for i in range(m):
		for j in range(m):
			c_array[i][j] = atom_distance(body1[i], body2[j])

	print("Body atom distances: ")
	print(c_array)
	#print(algorithm.find_matching(c_dict, matching_type = 'min', return_type = 'list'))

	row_ind, col_ind = linear_sum_assignment(c_array)
	print("Optimal Body Condition Assignment: ")
	print(col_ind)

	optimal_dist_sum = c_array[row_ind, col_ind].sum()
	print("Sum of distances for optimal body condition assignment: ")
	print(optimal_dist_sum)
	
	body_distance = 1/m*(m - k + optimal_dist_sum)
	print("Distance between rule bodies: ")
	print(body_distance)

	# We penalise head incongruity as much as the incongruity of a pair of body literals
	rule_distance = 1/(m+1)*(head_distance + m*body_distance)
	print("Distance between rules: ")
	print(rule_distance)

	#rule_similarity = 1 - rule_distance
	#print("Similarity of rules: ")
	#print(rule_similarity)

	return rule_distance

def event_description_distance(event_description1, event_description2):

	rules1 = event_description1.rules
	rules2 = event_description2.rules

	m, k = get_lists_size_and_pad(rules1, rules2, Rule(Atom("_dummy_rule", []), []))

	print("Event Description 1: ")
	print(event_description1)
	print()
	print("Event Description 2: ")
	print(event_description2)

	c_array = np.array([[0.0 for _ in range(m)] for _ in range(m)])

	for i in range(m):
		for j in range(m):
			print("\nComparing rules:\n " + str(rules1[i]) + " and\n" + str(rules2[j]))
			c_array[i][j] = rule_distance(rules1[i], rules2[j])

	print("Rule distances: ")
	print(c_array)

	row_ind, col_ind = linear_sum_assignment(c_array)
	print("Optimal Rule Assignment: ")
	print(col_ind)

	optimal_dist_sum = c_array[row_ind, col_ind].sum()
	print("Sum of distances for optimal rule assignment: ")
	print(optimal_dist_sum)
	
	event_description_distance = 1/m*(optimal_dist_sum)
	print("Distance between event descriptions: ")
	print(event_description_distance)

	event_description_similarity = 1 - event_description_distance
	print("Event Description Similarity: ")
	print(event_description_similarity)

	return event_description_similarity


