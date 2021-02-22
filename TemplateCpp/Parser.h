#include "Dataset.h"
#include "Solution.h"
#include <vector>
#include <string>

#pragma once
class Parser
{
public:
	Parser();
	Dataset GetDataFromStream(std::string filename);
	std::vector<Solution> ReadSolutionsFromPreviousRun(std::string filename, Dataset& dataset);
private:
	Solution ReadSolutionFromFile(std::string filepath, Dataset& dataset);
};

