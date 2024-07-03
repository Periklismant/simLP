# Implementation of the distance metric between ground logical atoms (see expression (9) in SPLICE paper)

from event_description import Atom
import numpy as np
from scipy.optimize import linear_sum_assignment

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
		rn 1/(2*len(atom1.args)) * distances_sum


def compute_cost_matrix(rule1, rule2):

	def pad_rule_body(body, n):
		for _ in range(n):
			body.append(Atom("_", []))
	
	def init_cost_dict(body1, body2):
		c_dict = dict()
		for atom1 in body1:
			c_dict[atom1] = dict()
			for atom2 in body2:
				c_dict[atom1][atom2] = 0
		return c_dict

	body1 = rule1.body
	body2 = rule2.body
	if len(body1)==len(body2):
		m = len(body1)
		k = len(body1)
	elif len(body1)>len(body2):
		m = len(body1)
		k = len(body2)
		pad_rule_body(body2, m-k)
	elif len(body2)>len(body1):
		m = len(body2)
		k = len(body1)
		pad_rule_body(body1, m-k)

	print(body1)
	print(body2)
	print(m)
	print(k)
	
	#c_dict = init_cost_dict(body1, body2)

	c_array = np.array([[0.0 for _ in range(m)] for _ in range(m)])

	for i in range(m):
		for j in range(m):
			c_array[i][j] = atom_distance(body1[i], body2[j])

	print(c_array)
	#print(algorithm.find_matching(c_dict, matching_type = 'min', return_type = 'list'))

	row_ind, col_ind = linear_sum_assignment(c_array)
	
	print("Optimal Assignment: ")
	print(col_ind)

	optimal_dist_sum = c_array[row_ind, col_ind].sum()
	print("Sum of distances for optimal assignment: ")
	print(optimal_dist_sum)
	
	cost = 1/m*(m - k + optimal_dist_sum)

	print("Distance between rules: ")
	print(cost)

	similarity = 1 - cost

	print("Similarity: ")
	print(similarity)

	#m = max(len(body1), len(body2))
	#k = min(len(body1), len(body2))

