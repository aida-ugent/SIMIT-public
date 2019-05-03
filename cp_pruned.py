import numpy as np
from ortools.constraint_solver import pywrapcp

import sys


def optimal_candidates(MM, candi_count,l,fix_ins,indices_size):


	# print('here')
	# Creates the solver.
	solver = pywrapcp.Solver("submatrix_maxsum")


	fix_row = MM[fix_ins,fix_ins+l:]
	Len = len(fix_row)

	# print(Len)

	# fix_row[fix_row == 0] = float("-infinity")

	indices = fix_row.argsort()[-indices_size+1:]
	indices += fix_ins + l

	# print(len(indices))
	indices = np.append(indices, fix_ins)


	indices = sorted(indices)

    # updateing the indices_size in case of the size for the actual available indices is less than indices_size
	indices_size = len(indices)
	# print(indices)
	# print(indices_size)
	M = [];

	for i in range(indices_size):
		for j in range(indices_size):
			M.append(MM[indices[i]][indices[j]]);

    # Change all the entries in the matrix to be integers
	# M = np.around(M)
	# print(len(M))
	M = np.around(M, decimals=3)
	# print(len(M))
	M = 1000*M
	M = M.tolist()
	M = map(int, M)

    # Creates the variables

	candi_indices = [solver.IntVar(0, indices_size-1, "%ith candidate" % i) for i in range(candi_count)]

	# candidates = []
	# for i in range(candi_count):
	# 	candidates.append(candi_indices[i].IndexOf(indices))
	candidates = [candi_indices[i].IndexOf(indices) for i in range(candi_count)]
	# candidates = [solver.IntVar([indices], "%ith candidate" % i) for i in range(candi_count)]

    # Creates the constraints
	# solver.Add(solver.AllDifferent(candidates))
	solver.Add(candidates[0] == fix_ins)
	solver.Add(solver.Sum([candidates[i+1] - candidates[i] >= l for i in range(candi_count - 1)]) == candi_count-1)

	# solver.Add(solver.Sum([candidates[0]==fix_ins-1])==1)

    # Set the objective

	candi_values = []
	subtract_term = 0

	for j in range(candi_count):
		for k in range(j, candi_count):
			ind = (candi_indices[j])*indices_size + candi_indices[k]
			candi_values.append(ind.IndexOf(M))
		# print(j)

	num = len(candi_values)


	obj_var = solver.Sum([candi_values[i] for i in range(num)]);
	# obj_var = solver.IntVar(min(M)*num,max(M)*num,'obj_var')

	# solver.Add(obj_var == solver.Sum([candi_values[i] for i in range(num)]))



	objective_monitor = solver.Maximize(obj_var, 1)
	# print('4')
    # Create the decision builder
	db = solver.Phase(candi_indices,solver.CHOOSE_FIRST_UNBOUND, solver.ASSIGN_RANDOM_VALUE)
	# print('5')

    # Create a solution collector
	collector = solver.LastSolutionCollector()

	collector.Add(candi_indices)
	collector.AddObjective(obj_var)

	solver.Solve(db,[objective_monitor, collector])
	# print('here')
	sum = 0
	inss =[]

	if collector.SolutionCount() > 0:
		# print('hahah')
		opt_sol = collector.SolutionCount() - 1
		# print('there')
		# print("maxsum:", collector.ObjectiveValue(opt_sol))
		# print()
		sum = collector.ObjectiveValue(opt_sol)
		for i in range(candi_count):

			index = collector.Value(opt_sol,candi_indices[i])
			# print(index)
			# print('candidates', [indices[index]])

			inss.append(indices[index])

	# np.savetxt('results.csv', results, delimiter = ',')
	# print('here')

	return sum, inss

# H = -10*np.ones((10,10))
# H[6,9] = -3
# H[9,6] = -3
# H[2,5] = -4
# H[5,2] = -4
# np.fill_diagonal(H, 1)


# inss = optimal_candidates(H,4,2)
# print(inss)


# optimal_candidates('/Users/junningdeng/Desktop/si-shapelets 2/','M.csv',4,2)
def main(argv):
	MM = np.genfromtxt(argv[1], delimiter = ',')
	num = len(MM[0])
	# print(num)
	maxsum = float("-infinity")
	inss_up = []

	for i in range(num - 3*int(argv[3])):

		[sum,inss] = optimal_candidates(MM,int(argv[2]),int(argv[3]),i,int(argv[4]))

		if sum > maxsum:
			maxsum = sum
			inss_up = inss

			# print(i)

	np.savetxt('inss.csv', inss_up, delimiter = ',')
if __name__ == '__main__':
	main(sys.argv)
