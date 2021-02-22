#include <vector>
#pragma once

class Solution
{
public:
	Solution();
	long long score;
	unsigned short int age;

	int NumChosen2People, NumChosen3People, NumChosen4People;
	std::vector<int> chosenPizzas;

	bool operator < (const Solution other) const;
};

