#include "Solution.h"
#include "Dataset.h"
#include "RandomGenerator.h"
#include <vector>

#pragma once
class NeighborOperation
{
public:
	NeighborOperation();
	void CrossOver(Solution& solutionA, Solution& solutionB);
	Solution Mutate(Solution solution);
	Solution RandomGenerate(Dataset& dataset);
private:
};

