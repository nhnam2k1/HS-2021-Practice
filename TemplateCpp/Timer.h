#include <chrono>
#include <ctime>

#pragma once
class Timer
{
public:
	Timer();
	void SetTheTimer(int seconds);
	bool CheckTimerFinish();
private:
	double seconds;
	std::chrono::time_point<std::chrono::system_clock> start, end;
	std::chrono::duration<double> elapsed_seconds;
};

