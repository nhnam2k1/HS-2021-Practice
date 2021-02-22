#pragma region Include The Self Header file
#include "Solver.h"
#include "Timer.h"
#include "Scoring.h"
#include "NeighborOperation.h"
#include "Parser.h"
#pragma endregion

#pragma region Include STL library
#include <algorithm>
#include <vector>
#include <execution>
#include <math.h>
#include <random>
#include <climits>
#include <chrono>
#include <mutex>
#include <atomic>
#include <ctime>
#pragma endregion

// Google OR tools comes here
#include "ortools/sat/cp_model.h"
#include "ortools/sat/model.h"
#include "ortools/sat/sat_parameters.pb.h"
#include "ortools/util/time_limit.h"

// OMP tools
#include <omp.h>
#include <iostream>

using namespace std;
using namespace operations_research;
using namespace operations_research::sat;

Solution solveByAdvancedGA(Dataset& dataset);

struct Possible3Para {
	int NumTeam2people;
	int NumTeam3people;
	int NumTeam4people;
};
vector<Possible3Para> possible3Paras;

void CreatePossible3Parameters(int T2, int T3, int T4, int limitPizza)
{
	CpModelBuilder cpModel;
	mutex mtx;
	const IntVar t2 = cpModel.NewIntVar(Domain(0, T2));
	const IntVar t3 = cpModel.NewIntVar(Domain(0, T3));
	const IntVar t4 = cpModel.NewIntVar(Domain(0, T4));

	// Means that t2 * 2 + t3 * 3 + t4 * 4 == NumPizzas
	cpModel.AddEquality(LinearExpr::ScalProd({ t2, t3, t4 }, { 2, 3, 4 }), limitPizza);
	if (limitPizza > 10) 
	{
		cpModel.AddLessOrEqual(t2, t3); // t2 <= t3
		cpModel.AddLessOrEqual(t3, t4); // t3 <= t4
	}
	
	Model model;  SatParameters parameter;
	parameter.set_max_time_in_seconds(10);
	//parameter.set_num_search_workers(8);
	parameter.set_enumerate_all_solutions(true);
	model.Add(NewSatParameters(parameter));
	
	// Create an atomic Boolean that will be periodically checked by the limit.
	std::atomic<bool> stopped(false);
	model.GetOrCreate<TimeLimit>()->RegisterExternalBooleanAsLimit(&stopped);
	int solutionLimit = 100;

	model.Add(NewFeasibleSolutionObserver([&](const CpSolverResponse& r) {
		Possible3Para newPossible;
		newPossible.NumTeam2people = SolutionIntegerValue(r, t2);
		newPossible.NumTeam3people = SolutionIntegerValue(r, t3);
		newPossible.NumTeam4people = SolutionIntegerValue(r, t4);
		lock_guard<mutex> lck(mtx);
		possible3Paras.push_back(newPossible);
		if (possible3Paras.size() >= solutionLimit) {
			stopped = true;
		}
	}));

	const CpSolverResponse respond = SolveCpModel(cpModel.Build(), &model);
}

Solution Solver::GetTheSolution(Dataset& dataset)
{
#pragma region Creating the possible list of possible number of assigned team
	possible3Paras.clear();
	if (dataset.Num2PeopleTeam * 2 + dataset.Num3PeopleTeam * 3
		+ dataset.Num4PeopleTeam * 4 <= dataset.NumPizzas) {
		Possible3Para only;
		only.NumTeam2people = dataset.Num2PeopleTeam;
		only.NumTeam3people = dataset.Num3PeopleTeam;
		only.NumTeam4people = dataset.Num4PeopleTeam;
		possible3Paras.push_back(only);
	}
	if (dataset.Num2PeopleTeam * 2 + dataset.Num3PeopleTeam * 3
		+ dataset.Num4PeopleTeam * 4 > dataset.NumPizzas)
	{
		CreatePossible3Parameters(dataset.Num2PeopleTeam, dataset.Num3PeopleTeam,
			dataset.Num4PeopleTeam, dataset.NumPizzas);
	}
#pragma endregion

#pragma region Solving by Genetic Algorithm
	Solution solution = solveByAdvancedGA(dataset);
	solution.chosenPizzas.shrink_to_fit();
#pragma endregion

	return solution;
}

Solution solveByAdvancedGA(Dataset& dataset)
{	
#pragma region Initialize Class And Setting
	mutex mtx;  cerr.sync_with_stdio(0);  cerr.tie(NULL);
	const int	POPULATION_SIZE = 200;
	const int	GENERATION = 10000;

#pragma region Initialize Class (Not touch)
	mt19937_64 rng;
	uniform_int_distribution<int> uid;
	uniform_real_distribution<double> urd(0.05, 0.1);
	uniform_real_distribution<double> changeRate(0.0, 1.0);

	Scoring scoring;  Parser parser;
	NeighborOperation neighborOperation;
	Timer timer;      int seconds;
#pragma endregion

#pragma endregion

#pragma region Declare a collection of populations And first solution score
	vector<Solution> population;
	Solution bestSolution;
	bestSolution.score = LLONG_MIN;
#pragma endregion

#pragma region Set the timer for the GA
	int length = dataset.NumPizzas;

	if (length <= 10)
	{
		seconds = 10;
	}
	else if (length <= 500)
	{
		seconds = 60;
	}
	else seconds = 420;
	seconds = 60;
#pragma endregion

#pragma region Read the previous best solution from previous run
	population = parser.ReadSolutionsFromPreviousRun(dataset.filename, dataset);
#pragma endregion
	
#pragma region Initialize the population for genetic algorithm
	uid = uniform_int_distribution<int>(0, possible3Paras.size() - 1);

	while (population.size() < POPULATION_SIZE) 
	{
		Solution solution = neighborOperation.RandomGenerate(dataset);
		random_device rd;  rng = mt19937_64(rd()); int id = uid(rng);
		solution.NumChosen2People = possible3Paras[id].NumTeam2people;
		solution.NumChosen3People = possible3Paras[id].NumTeam3people;
		solution.NumChosen4People = possible3Paras[id].NumTeam4people;
		population.push_back(solution);
	}
#pragma endregion

#pragma region Calculate the score of the initialize population
	for_each(execution::par, population.begin(), population.end(), [&dataset](Solution& solution) {
		Scoring scoring;
		Solution temp = solution;
		solution.score = scoring.CalculateScore(dataset, temp);
	});
#pragma endregion

#pragma region Initialize the timer and limit if cannot find better solution for a long period
	int NotFindBetterSolution = 0;
	const int LIMIT_TIME_NOT_FIND_BETTER_SOLUTION = GENERATION >> 1;
	timer.SetTheTimer(seconds);
#pragma endregion

	for (int generation = 0; generation < GENERATION; generation++)
	{
#pragma region update best solution, check the time if exceeded (not touch)
		int size = population.size();
		bool findBetterSolution = false;

		for (int i = 0; i < size; i++) {
			if (population[i].score > bestSolution.score) 
			{
				bestSolution = population[i];
				findBetterSolution = true;
				NotFindBetterSolution = 0;
			}
		}
		if (!findBetterSolution) {
			NotFindBetterSolution++;
			if (NotFindBetterSolution > LIMIT_TIME_NOT_FIND_BETTER_SOLUTION) { break; }
		}
		if (timer.CheckTimerFinish()) { break; }
		if (NotFindBetterSolution > 50) { break; }
#pragma endregion

#pragma region Prepare for Wheel Selection
		long long sum = 0;
		vector<double> wheelP;

		for (int i = 0; i < size; i++) 
		{
			sum = sum + population[i].score;
			wheelP.push_back(0);
		}
		for (int i = 0; i < size; i++) 
		{
			double p = (double)population[i].score / sum;
			wheelP[i] = p;
		}
		for (int i = 1; i < size; i++) wheelP[i] += wheelP[i - 1];
#pragma endregion

#pragma region Add 10% best from parent to new generation
		vector<Solution> newGeneration;       newGeneration.clear();
		//newGeneration.push_back(bestSolution);

		//int s = POPULATION_SIZE / 10;  // Choose 10% elite parents
		//for (int i = 0; i < s; i++)
		//{
		//	newGeneration.push_back(population[i]);
		//}
#pragma endregion

#pragma region Crossover some parents of current population, create new generation population
		int s = POPULATION_SIZE * 0.4;    // 80% will be choose based on the offspring
		uid = uniform_int_distribution<int>(0, population.size() >> 1);
		uniform_real_distribution<double> uwheel(0.0, wheelP[wheelP.size() - 1]);

		#pragma omp parallel for
		for (int i = 0; i < s; i++)
		{
			random_device rd;   rng = mt19937_64(rd());
			int p1 = lower_bound(wheelP.begin(), wheelP.end(), uwheel(rng)) - wheelP.begin();
			int p2 = lower_bound(wheelP.begin(), wheelP.end(), uwheel(rng)) - wheelP.begin();

			Solution s1 = population[p1];
			Solution s2 = population[p2];
			neighborOperation.CrossOver(s1, s2);

			lock_guard<mutex> lck(mtx);
			newGeneration.push_back(s1);
			newGeneration.push_back(s2);
		}
#pragma endregion

#pragma region Mutation some parts of new population
		random_device rd;
		rng = mt19937_64(rd()); // 0.5% to 1% will mutate offspring
		double percentage = urd(rng);
		int currentNewPopulation = newGeneration.size();
		int MumberOfMutation = currentNewPopulation * percentage;
		uid = uniform_int_distribution<int>(0, currentNewPopulation - 1);
		cerr << NotFindBetterSolution << "\n";

		//#pragma omp parallel for
		for (int i = 0; i < MumberOfMutation; i++)
		{
			random_device rd;
			rng = mt19937_64(rd());  
			int id = uid(rng);

			Solution temporary = newGeneration[id];

			if (NotFindBetterSolution >= 5)
			{
				int limit = min(NotFindBetterSolution / 5, 10);
				for (int j = 0; j < limit; j++)
				{
					shuffle(temporary.chosenPizzas.begin(),
							temporary.chosenPizzas.end(), rng);
				}
			}
			else
			{
				temporary = neighborOperation.Mutate(temporary);
			}

			double rate = changeRate(rng);
			if (rate >= 0.5)
			{
				uniform_int_distribution<int> f(0, possible3Paras.size() - 1);
				random_device rd;  rng = mt19937_64(rd());  int id = f(rng);
				temporary.NumChosen2People = possible3Paras[id].NumTeam2people;
				temporary.NumChosen3People = possible3Paras[id].NumTeam3people;
				temporary.NumChosen4People = possible3Paras[id].NumTeam4people;
			}

			//lock_guard<mutex> lck(mtx);
			newGeneration[id] = temporary;
		}
#pragma endregion
		if (NotFindBetterSolution > 10) {
			for (int i = 0; i < NotFindBetterSolution / 10; i++) {
				random_device rd;
				rng = mt19937_64(rd());
				shuffle(newGeneration[i].chosenPizzas.begin(),
					newGeneration[i].chosenPizzas.end(), rng);
			}
		}
#pragma region Generating random population for diversity
		s = POPULATION_SIZE / 10;    // 10% from Random solution
		uid = uniform_int_distribution<int>(0, possible3Paras.size() - 1);

		#pragma omp parallel for
		for (int i = 0; i < s; i++)
		{
			random_device rd;
			rng = mt19937_64(rd());   int id = uid(rng);
			Solution newOffspring = neighborOperation.RandomGenerate(dataset);

			newOffspring.NumChosen2People = possible3Paras[id].NumTeam2people;
			newOffspring.NumChosen3People = possible3Paras[id].NumTeam3people;
			newOffspring.NumChosen4People = possible3Paras[id].NumTeam4people;

			lock_guard<mutex> lck(mtx);
			newGeneration.push_back(newOffspring);
		}
#pragma endregion

#pragma region Get the score of new generation population
		for_each(execution::par, newGeneration.begin(), newGeneration.end(), [&dataset](Solution& solution)
			{
				Scoring scoring;         Solution temp = solution;
				solution.score = scoring.CalculateScore(dataset, temp);
			});
#pragma endregion

#pragma region Write the Debug info
		cerr << generation << " " << population[0].score << " " << bestSolution.score << "\n";
#pragma endregion

		population = newGeneration;
	}
#pragma region Return the best solution that have find so far (not touch)
	for (int i = 0; i < population.size(); i++) {
		if (population[i].score > bestSolution.score)
		{
			bestSolution = population[i];
		}
	}
	return bestSolution;
#pragma endregion
}

/// <summary>
/// This is the main implementation for the Google Hash Code Problem
/// Calculating from the dataset, and transfer into solution using all 
/// </summary>

// Skip this part below
Solver::Solver()
{
}
