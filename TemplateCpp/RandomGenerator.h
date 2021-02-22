#include <random>

#pragma once
class RandomGenerator
{
public:
	RandomGenerator();
	int RandomInt(int limit);
	double RandomPercentage();
private:
	std::mt19937_64 genI, genD;
	std::uniform_int_distribution<int> uid;
	std::uniform_real_distribution<double> urd;
};

