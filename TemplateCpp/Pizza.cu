#include "Pizza.h"
#include <algorithm>
#include <execution>

void Pizza::sort()
{
	std::sort(std::execution::par, ingridients.begin(), ingridients.end());
}
