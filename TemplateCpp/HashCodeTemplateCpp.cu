#include <string>
#include <filesystem>

#include "Dataset.h"
#include "Solution.h"
#include "Parser.h"
#include "Printer.h"
#include "Scoring.h"
#include "Solver.h"
#include <vector>
#include <algorithm>
#include <iostream>
using namespace std;
using namespace std::filesystem;

int main() {
    Parser parser;      // A class for reading input file, convert into Dataset format
    Printer printer;    // A class for writing output file from the Solution format
    Scoring scoring;    // A class for calculating the score of the solution based from the dataset and solution
    Solver solver;      // A class for computing the solution from the dataset (the most important one)

    create_directory("input");      create_directory("output");

    for (auto& p : directory_iterator("input")) 
    {
        string inputFilePath = p.path().generic_string();
        string filename = p.path().stem().generic_string();

        Dataset dataset = parser.GetDataFromStream(inputFilePath);
        dataset.filename  = filename;
        Solution solution = solver.GetTheSolution(dataset);
        printer.PrintSolution(solution, filename);
    }
    return 0;
}
// HashCodeTemplateCpp.cpp : This file contains the 'main' function. Program execution begins and ends there.
// The main file should be keep like this for the structure

// Run program: Ctrl + F5 or Debug > Start Without Debugging menu
// Debug program: F5 or Debug > Start Debugging menu

// Tips for Getting Started: 
//   1. Use the Solution Explorer window to add/manage files
//   2. Use the Team Explorer window to connect to source control
//   3. Use the Output window to see build output and other messages
//   4. Use the Error List window to view errors
//   5. Go to Project > Add New Item to create new code files, or Project > Add Existing Item to add existing code files to the project
//   6. In the future, to open this project again, go to File > Open > Project and select the .sln file