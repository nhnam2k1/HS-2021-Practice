#include "Dataset.h"
#include <vector>
#include <string>

Dataset::Dataset()
{
	Num2PeopleTeam = 0;
	Num3PeopleTeam = 0;
	Num4PeopleTeam = 0;
	NumPizzas = 0;
	pizzas = std::vector<Pizza>();
	filename = "";
}
