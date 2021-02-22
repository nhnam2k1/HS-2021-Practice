#include <string>
#include <sstream>
#include <fstream>
#include <filesystem>
#include <ctime>
#include "Printer.h"
#include "Solution.h"

using namespace std;
namespace fs = std::filesystem;

Printer::Printer()
{
	current_time = time(NULL);
}

void Printer::PrintSolution(Solution& solution, std::string filename)
{
#pragma region The stable code (not touch), using fout for output normal
	stringstream ss;   ss.sync_with_stdio(0);   ss.tie(0);

	ss << "output/"<< current_time << "/";
	string outputFile;       
	ss >> outputFile;

	fs::create_directory(outputFile);
	outputFile = outputFile + filename + ".out";

	ofstream fout(outputFile); 
	fout.sync_with_stdio(false); 
	fout.tie(NULL);
#pragma endregion

	int t2 = solution.NumChosen2People;
	int t3 = solution.NumChosen3People;
	int t4 = solution.NumChosen4People;

	int pre2 = 2 * t2;
	int pre3 = pre2 + 3 * t3;

	fout << t2 + t3 + t4 << "\n";

	for (int i = 0; i < solution.NumChosen2People; i++) 
	{
		fout << 2 << " ";
		for (int j = 2*i; j < 2*(i+1); j++) 
		{
			fout << solution.chosenPizzas[j] << " ";
		}
		fout << "\n";
	}
	for (int i = 0; i < solution.NumChosen3People; i++) 
	{
		fout << 3 << " ";
		for (int j = pre2 + 3*i; j < pre2 + 3*(i+1); j++)
		{
			fout << solution.chosenPizzas[j] << " ";
		}
		fout << "\n";
	}
	for (int i = 0; i < solution.NumChosen4People; i++)
	{
		fout << 4 << " ";
		for (int j = pre3 + 4*i; j < pre3 + 4*(i+1); j++)
		{
			fout << solution.chosenPizzas[j] << " ";
		}
		fout << "\n";
	}
	fout << solution.score;
}
