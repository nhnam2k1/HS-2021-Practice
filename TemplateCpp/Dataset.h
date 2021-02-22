#include <vector>
#include <string>
#include "Pizza.h"

#pragma once
class Dataset
{
public:
	Dataset();
	int NumPizzas, Num2PeopleTeam, Num3PeopleTeam, Num4PeopleTeam;
	std::string filename;
	std::vector<Pizza> pizzas;
};

