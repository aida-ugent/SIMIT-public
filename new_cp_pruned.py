import numpy as np
from ortools.sat.python import cp_model
import sys

class CP:
	def get_candidates(self, MM, candi_count, l, fix_ins, indices_size):
		fix_row = MM[fix_ins,fix_ins+l:]
		Len = len(fix_row)

		indices = fix_row.argsort()[-indices_size+1:]
		indices += fix_ins + l
		indices = np.append(indices, fix_ins)
		indices = sorted(indices)
		# indices = list(map(np.int64,indices))

	    # updateing the indices_size in case of the size for the actual available indices is less than indices_size
		indices_size = len(indices)
		M = [];
		for i in range(indices_size):
			for j in range(indices_size):
				M.append(MM[indices[i]][indices[j]]);

	    # Change all the entries in the matrix to be integers
		M = np.around(M, decimals=3)
		M = 1000*M
		M = M.tolist()
		M = map(int, M)
		return M, indices

	def find_submatix_with_maxsum(self, M, indices, candi_count,l,indices_size):
		# Creates the model.
		model = cp_model.CpModel()

	    # Creates the variables
		candi_indices = [model.NewIntVar(0, indices_size-1, "%ith candidate_index" % i) for i in range(candi_count)]
		# candidates = []
		# for i in range(candi_count):
		# 	model.AddElement(i, candidates,indices[candi_indices[i]])
		# CpModel.AddElement(self, index, variables, target)
		candidates = [candi_indices[i].IndexOf(indices) for i in range(candi_count)]
		# candidates = [indices[candi_indices[i]] for i in range(candi_count)]

	    # Creates the constraints
		model.Add(candidates[0] == fix_ins)
		model.Add(model.Sum([candidates[i+1] - candidates[i] >= l for i in range(candi_count - 1)]) == candi_count-1)

	    # Set the objective
		candi_values = []
		subtract_term = 0
		for j in range(candi_count):
			for k in range(j, candi_count):
				ind = (candi_indices[j])*indices_size + candi_indices[k]
				candi_values.append(ind.IndexOf(M))
		num = len(candi_values)
		obj_var = model.Sum([candi_values[i] for i in range(num)]);

		model.Maximize(obj_var)
		solver = cp_model.CpSolver()
		status = solver.Solve(model)

		# Collect the results
		inss = []
		if status == cp_model.OPTIMAL:
			sum = solver.ObjectiveValue()
			inss_indices = solver.Value(candi_indices)
			for i in range(candi_count):
				inss.append(indices[inss_indices[i]])
		return sum, inss
	# H = -10*np.ones((10,10))
	# H[6,9] = -3
	# H[9,6] = -3
	# H[2,5] = -4
	# H[5,2] = -4
	# np.fill_diagonal(H, 1)
	# inss = optimal_candidates(H,4,2)
	# print(inss)

def main(argv):
	MM = np.genfromtxt(argv[1], delimiter = ',')
	num = len(MM[0])
	# print(num)
	maxsum = float("-infinity")
	inss_up = []
	cp = CP()

	for i in range(num - 3*int(argv[3])):
		[M,indices] = cp.get_candidates(MM, int(argv[2]),int(argv[3]),i,int(argv[4]))
		[sum,inss] = cp.find_submatix_with_maxsum(M,indices,int(argv[2]),int(argv[3]),int(argv[4]))
		if sum > maxsum:
			maxsum = sum
			inss_up = inss
	np.savetxt('inss.csv', inss_up, delimiter = ',')
if __name__ == '__main__':
	main(sys.argv)
