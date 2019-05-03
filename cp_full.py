import numpy as np
from ortools.constraint_solver import pywrapcp

import sys


def optimal_candidates(name,candi_count,l):



	M = np.genfromtxt(name, delimiter = ',')

	print('here')
	# Creates the solver.
	solver = pywrapcp.Solver("submatix_maxsum")


	Len = len(M[0])

    # Change all the entries in the matrix to be integers
	M = M.flatten()
	# M = np.around(M)
	M = np.around(M, decimals=3)
	M = 1000*M
	M = M.tolist()
	M = map(int, M)


    # Creates the variables
	candidates = [solver.IntVar(0, Len - 1, "%ith candidate" % i) for i in range(candi_count)]


    # Creates the constraints
	solver.Add(solver.AllDifferent(candidates))
	solver.Add(solver.Sum([candidates[i+1] - candidates[i] >= l for i in range(candi_count - 1)]) == candi_count-1)


    # Set the objective

	candi_values = []


	for j in range(candi_count):
		for k in range(j, candi_count):
			ind = (candidates[j])*Len + candidates[k]
			candi_values.append(ind.IndexOf(M))

	num = len(candi_values)

	obj_var = solver.IntVar(min(M)*num,max(M)*num,'obj_var')
	solver.Add(obj_var == solver.Sum([candi_values[i] for i in range(num)]))
	objective_monitor = solver.Maximize(obj_var, 1)

    # Create the decision builder
	db = solver.Phase(candidates,solver.CHOOSE_FIRST_UNBOUND, solver.ASSIGN_RANDOM_VALUE)


    # Create a solution collector
	collector = solver.LastSolutionCollector()

	collector.Add(candidates)
	collector.AddObjective(obj_var)
	solver.Solve(db,[objective_monitor, collector])
	print('here')
	inss = []

	if collector.SolutionCount() > 0:
		opt_sol = collector.SolutionCount() - 1
		print("maxsum:", collector.ObjectiveValue(opt_sol))
		print()

		for i in range(candi_count):
			print('candidates', [collector.Value(opt_sol,candidates[i])])

			inss.append(collector.Value(opt_sol,candidates[i]))

	np.savetxt('inss.csv', inss, delimiter = ',')
	print('here')

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
	optimal_candidates(argv[1],int(argv[2]),int(argv[3]))

if __name__ == '__main__':
	main(sys.argv)
