import sys
from os import walk

sys.path.append("../src")

import run

if __name__=="__main__":
	subfolders = list(walk('.'))[0][1]
	for subfolder in sorted(subfolders):
		matching, distances, similarity = run.parse_and_compute_distance(subfolder + "/generated.prolog", subfolder + "/ground.prolog", subfolder + "/log.txt")
		f = open(subfolder + "/results.csv", 'r')
		flag = 0
		i = 0
		mistakesNo = 0
		for line in f:
			my_line = line.strip()
			if len(line)==1:
				i = 0
				flag += 1
			elif flag==0:
				if int(my_line) != matching[i]:
					mistakesNo += 1
					print("Error in the matching of rule " + str(i))
					print("My matching is: " + str(matching[i]))
					print("Correct matching is: " + my_line)
				i+=1
			elif flag==1:
				if float(my_line) != round(distances[i], 4):
					mistakesNo += 1
					print("Error in the distance of rule " + str(i))
					print("My distance is: " + str(round(distances[i], 4)))
					print("Correct distance is: " + my_line)
				i+=1
			elif flag==2:
				if float(my_line) != round(similarity, 4):
					mistakesNo += 1
					print("Incorrect Similarity")
					print("My similarity is: " + str(round(similarity, 4)))
					print("Correct distance is: " + my_line)
				i+=1
		f.close()
		print("Number of incorrect results: " + str(mistakesNo))
		print()
		print()
		


