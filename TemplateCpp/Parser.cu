#pragma region Include Self Header file
#include "Dataset.h"
#include "Parser.h"
#include "Pizza.h"
#pragma endregion

#pragma region Include The STL library
#include <fstream>
#include <sstream>
#include <string>
#include <unordered_map>
#include <filesystem>
#include <algorithm>
#include <random>
#include <ctime>
#pragma endregion

namespace fs = std::filesystem;
using namespace std;

Parser::Parser()
{
}

Dataset Parser::GetDataFromStream(std::string filename)
{
#pragma region The stable code (not touch), fin
	ifstream fin(filename);      fin.sync_with_stdio(false);    fin.tie(NULL);
#pragma endregion

	unordered_map<string, int> keeptrack;
	Dataset dataset = Dataset();

	int numPizzas, t2, t3, t4;

	fin >> numPizzas;
	fin >> t2 >> t3 >> t4;

	dataset.NumPizzas = numPizzas;
	dataset.Num2PeopleTeam = t2;
	dataset.Num3PeopleTeam = t3;
	dataset.Num4PeopleTeam = t4;

	for (int i = 0; i < numPizzas; i++) 
	{
		int ing; string name;

		fin >> ing; Pizza pizza;
		pizza.ingridients.clear();

		while (ing--) 
		{
			fin >> name;
			if (keeptrack.find(name) == keeptrack.end()) 
			{
				int id = (int)keeptrack.size();
				keeptrack[name] = id;
			}
			pizza.ingridients.push_back(keeptrack[name]);
		}
		pizza.ingridients.shrink_to_fit();
		dataset.pizzas.push_back(pizza);
	}
	dataset.pizzas.shrink_to_fit();
	return dataset;
}

std::vector<Solution> Parser::ReadSolutionsFromPreviousRun(std::string filename, Dataset& dataset)
{
	stringstream ss; ss.sync_with_stdio(0); ss.tie(0);
	vector<Solution> solutions;
	std::string file, outputFolder = "output";
	
	ss << filename << ".out"; ss >> file;

	for (auto& p : fs::directory_iterator(outputFolder))
	{
		string path = p.path().generic_string();
		path += "/" + file;
		fs::path check = fs::path(path);

		if (fs::exists(check)) 
		{
			Solution solution = ReadSolutionFromFile(path, dataset);
			solutions.push_back(solution);
		}
	}
	solutions.shrink_to_fit();
	return solutions;
}

Solution Parser::ReadSolutionFromFile(std::string filepath, Dataset& dataset)
{
#pragma region Initialize the reading file
	ifstream fin(filepath);    fin.sync_with_stdio(0);    fin.tie(0);
	Solution solution;
#pragma endregion

	int numberTeam, t2, t3, t4;
	int numPizzas = dataset.NumPizzas;
	vector<bool> mark(numPizzas, false);

	t2 = 0; t3 = 0; t4 = 0;

	fin >> numberTeam;

	for (int i = 0; i < numberTeam; i++) 
	{
		int number, chosenPizza;

		fin >> number;

		if (number == 2) t2++;
		else if (number == 3) t3++;
		else t4++;

		for(int j = 0; j < number; j++) {
			fin >> chosenPizza;
			mark[chosenPizza] = true;
			solution.chosenPizzas.push_back(chosenPizza);
		}
	}

	if (solution.chosenPizzas.size() < dataset.NumPizzas) 
	{
		vector<int> tmp;

		for(int i = 0; i < numPizzas; i++) {
			if (mark[i] == false) 
			{
				tmp.push_back(i);
			}
		}
		random_device rd;
		mt19937_64 rng = mt19937_64(rd());
		for (int i = 0; i < 10; i++)  {
			shuffle(tmp.begin(), tmp.end(), rng);
		}

		for (auto it = tmp.begin(); it != tmp.end(); it++) {
			solution.chosenPizzas.push_back(*it);
		}
	}

	solution.chosenPizzas.shrink_to_fit();
	solution.NumChosen2People = t2;
	solution.NumChosen3People = t3;
	solution.NumChosen4People = t4;
	solution.age = 0;
	return solution;
}

