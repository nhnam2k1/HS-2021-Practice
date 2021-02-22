#include "NeighborOperation.h"
#include "Scoring.h"
#include "Solution.h"
#include "Dataset.h"
#include <vector>
#include <algorithm>
#include <execution>
#include <random>
#include <ctime>

using namespace std;

NeighborOperation::NeighborOperation()
{
	/*randomGenerator = RandomGenerator();*/
}

void InversionMutation(Solution& solution, int left, int right);

void ScrambleMutation(Solution& solution, int left, int right);

Solution makeCrossOver(int crossIndex, Solution& solutionA, Solution& SolutionB);

void NeighborOperation::CrossOver(Solution& solutionA, Solution& solutionB)
{
	Solution offSpring1;   Solution offSpring2;
	random_device rd;
	mt19937_64 genI = mt19937_64(rd());
	uniform_int_distribution<int> uid = uniform_int_distribution<int>(0, solutionA.chosenPizzas.size() - 1);

	int crosspoint = uid(genI);
	offSpring1 = makeCrossOver(crosspoint, solutionA, solutionB);
	offSpring2 = makeCrossOver(crosspoint, solutionB, solutionA);

	solutionA = offSpring1;
	solutionB = offSpring2;
}

Solution NeighborOperation::Mutate(Solution solution)
{
	Scoring scoring;
	Solution newSolution = solution;
	random_device rd;
	mt19937_64 genI = mt19937_64(rd());
	uniform_int_distribution<int> uid(0, newSolution.chosenPizzas.size()-1);
	
	int length = newSolution.chosenPizzas.size(); // permutation of pizzas
	int pre2 = newSolution.NumChosen2People * 2;
	int pre3 = pre2 + newSolution.NumChosen3People * 3;
	int solutionLimit = pre3 + newSolution.NumChosen4People * 4; // look at the pizzas solution
	uniform_int_distribution<int> ued(0, solutionLimit - 1);

	int cnt = 0, limit = length / 100;
	while (cnt < limit)
	{
		int idx1 = uid(genI);  int idx2 = uid(genI);
		if (idx1 > solutionLimit && idx2 > solutionLimit) 
		{
			idx1 = ued(genI);
		}
		swap(newSolution.chosenPizzas[idx1], newSolution.chosenPizzas[idx2]);
		cnt++;
	}

	newSolution.age = 0;
	return newSolution;
	
	/*int next; bool ch = false;
	long long tmpScore;
	Solution bestSolution = solution;  
	bestSolution.score = scoring.CalculateScore(dataset, bestSolution);

	for (int i = 0; i < solutionLimit; i++) 
	{
		if (i < pre2) next = 2;
		else if (i < pre3) next = 3;
		else next = 4;

		for (int j = i+next; j < length; j++) 
		{
			swap(newSolution.chosenPizzas[i], newSolution.chosenPizzas[j]);
			tmpScore = scoring.CalculateScore(dataset, newSolution);
			if (tmpScore > bestSolution.score) 
			{
				bestSolution = newSolution;
				bestSolution.score = tmpScore;
				ch = true;
				break;
			}
		}
		if (ch) break;
	}
	return bestSolution;*/
}

Solution NeighborOperation::RandomGenerate(Dataset& dataset)
{
	Solution newSolution;

	int length = dataset.NumPizzas;

	for (int i = 0; i < length; i++) 
	{
		newSolution.chosenPizzas.push_back(i);
	}

	random_device rd;
	mt19937_64 genI = mt19937_64(rd());
	uniform_int_distribution<int> uid = uniform_int_distribution<int>(1, 10);
	
	int time = uid(genI);

	for (int i = 0; i < time; i++) 
	{
		shuffle(newSolution.chosenPizzas.begin(), 
			newSolution.chosenPizzas.end(), genI);
	}

	newSolution.age = 0;
	return newSolution;
}

// Extension Algorithm will be put here

void InversionMutation(Solution& solution, int left, int right)
{
}

void ScrambleMutation(Solution& solution, int left, int right)
{
}

Solution makeCrossOver(int crossIndex, Solution& solutionA, Solution& SolutionB)
{
	Solution offspring;
	int length = solutionA.chosenPizzas.size();
	vector<bool> check(length, 0);

	for (int i = 0; i <= crossIndex; i++)
	{
		int item = solutionA.chosenPizzas[i];
		check[item] = true;
		offspring.chosenPizzas.push_back(item);
	}

	for (int i = 0; i < length; i++)
	{
		int item = solutionA.chosenPizzas[i];
		if (!check[item]) {
			offspring.chosenPizzas.push_back(item);
			check[item] = true;
		}
	}

	offspring.NumChosen2People = solutionA.NumChosen2People;
	offspring.NumChosen3People = solutionA.NumChosen3People;
	offspring.NumChosen4People = solutionA.NumChosen4People;
	offspring.chosenPizzas.shrink_to_fit();

	offspring.age = 0;
	return offspring;
}