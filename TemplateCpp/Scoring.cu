#pragma region Include Self Header file
#include "Solution.h"
#include "Dataset.h"
#include "Scoring.h"
#include "Pizza.h"
#pragma endregion

#pragma region Include STL library
#include <unordered_set>
#include <vector>
#pragma endregion

using namespace std;

Scoring::Scoring()
{
}

long long Scoring::CalculateScore(Dataset& dataset, Solution& solution)
{
	long long scoreT2, scoreT3, scoreT4;

	int t2 = solution.NumChosen2People;
	int t3 = solution.NumChosen3People;
	int t4 = solution.NumChosen4People;

	int pre2 = 2 * t2;
	int pre3 = pre2 + 3 * t3;

	scoreT2 = 0;
	scoreT3 = 0;
	scoreT4 = 0;

	unordered_set<int> list;
	list.max_load_factor(0.25);
	list.reserve(1024);

	for (int i = 0; i < t2; i++) 
	{
		for (int j = 2*i; j < 2*(i+1); j++) 
		{
			Pizza pizza = dataset.pizzas[solution.chosenPizzas[j]];
			
			for (auto it = pizza.ingridients.begin(); it != pizza.ingridients.end(); it++) 
			{
				list.insert(*it);
			}
		}
		scoreT2 = scoreT2 + list.size() * list.size();
		list.clear();
	}

	for (int i = 0; i < t3; i++) 
	{
		for(int j = pre2 + 3*i; j < pre2 + 3*(i+1); j++)
		{
			Pizza pizza = dataset.pizzas[solution.chosenPizzas[j]];

			for (auto it = pizza.ingridients.begin(); it != pizza.ingridients.end(); it++)
			{
				list.insert(*it);
			}
		}
		scoreT3 = scoreT3 + list.size() * list.size();
		list.clear();
	}

	for (int i = 0; i < t4; i++) 
	{
		for(int j = pre3 + 4*i; j < pre3 + 4*(i+1); j++)
		{
			Pizza pizza = dataset.pizzas[solution.chosenPizzas[j]];

			for (auto it = pizza.ingridients.begin(); it != pizza.ingridients.end(); it++)
			{
				list.insert(*it);
			}
		}
		scoreT4 = scoreT4 + list.size() * list.size();
		list.clear();
	}

	long long score = scoreT2 + scoreT3 + scoreT4;
	return score;
}

long long CalculatePizza2Team(vector<Pizza>& pizzas, int l, int r)
{
	long long score = 0;
	return 0;
}

long long CalculatePizza3Team(vector<Pizza>& pizzas, int l, int r)
{
	long long score = 0;
	return 0;
}

long long CalculatePizza4Team(vector<Pizza>& pizzas, int l, int r)
{
	long long score = 0;
	return 0;
}