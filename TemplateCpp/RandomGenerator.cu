#include "RandomGenerator.h"
#include <random>

using namespace std;

RandomGenerator::RandomGenerator()
{

}

int RandomGenerator::RandomInt(int limit)
{
	random_device rd;
	genI = mt19937_64(rd());
	uid = uniform_int_distribution<int>(1, limit);
	int number = uid(genI);
	return number;
}

double RandomGenerator::RandomPercentage()
{
	random_device rd;
	genD = mt19937_64(rd());
	urd = uniform_real_distribution<double>(0.0, 1.0);
	double number = urd(genD);
	return number;
}
