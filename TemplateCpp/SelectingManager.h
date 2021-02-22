#include "Solution.h"
#include <vector>

#pragma once
class SelectingManager
{
public:
	SelectingManager();
	
	void UpdateRouletteWheel(std::vector<Solution>& population);
	
	void GetTheRandomizedParents(std::vector<Solution>& population, 
								 Solution& parentA, Solution& ParentB);

	std::vector<Solution> SurvivorSelection(std::vector<Solution>& parents, 
											std::vector<Solution>& offsprings, 
											int desiredPopulationSize);
private:
	std::vector<double> pWheel;
};

