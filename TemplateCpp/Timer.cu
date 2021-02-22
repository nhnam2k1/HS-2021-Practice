#include "Timer.h"
#include <chrono>
#include <ctime>

Timer::Timer()
{
	this->start = std::chrono::system_clock::now();
}

void Timer::SetTheTimer(int seconds)
{
	this->seconds = (double)seconds;
	this->start = std::chrono::system_clock::now();
}

bool Timer::CheckTimerFinish()
{
	this->end = end = std::chrono::system_clock::now();
	this->elapsed_seconds = end - start;

	if (elapsed_seconds.count() > seconds) 
	{
		return true;
	}
	return false;
}
