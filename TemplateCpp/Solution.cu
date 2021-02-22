#include "Solution.h"

Solution::Solution()
{
    NumChosen2People = 0;
    NumChosen3People = 0;
    NumChosen4People = 0;
    chosenPizzas = std::vector<int>();
    age = 0;
}

bool Solution::operator < (const Solution other) const
{
    return score > other.score;
}
