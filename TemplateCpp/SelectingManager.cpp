#include "SelectingManager.h"
#include <random>
#include <algorithm>

using namespace std;

SelectingManager::SelectingManager()
{
}

void SelectingManager::UpdateRouletteWheel(std::vector<Solution>& population)
{
}

void SelectingManager::GetTheRandomizedParents(std::vector<Solution>& population, Solution& parentA, Solution& ParentB)
{
}

std::vector<Solution> SelectingManager::SurvivorSelection(std::vector<Solution>& parents, 
														  std::vector<Solution>& offsprings, 
														  int desiredPopulationSize)
{
	return std::vector<Solution>();
}
