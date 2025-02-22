extends Node

func checkSolution(type, attempted, solution):
	if type == "cellValue":
		for value in attempted.values():
			if solution == value:
				return true
	elif type == "exact":
		if attempted == solution:
			return true
	return false
