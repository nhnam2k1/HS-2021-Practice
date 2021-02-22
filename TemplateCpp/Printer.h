#include "Solution.h"
#include <ctime>

#pragma once
class Printer
{
public:
	Printer();
	void PrintSolution(Solution& solution, std::string filename);
private:
	time_t current_time;
};

