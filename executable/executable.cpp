#include "../include/devtemplate/devtemplate.h"
#include <iostream>

int main(int argc, char **argv)
{
    devtemplate::Devtemplate d;
    #ifndef DEVTEMPLATE_ADVANCED
        bool correct = d.devtemplate() == 42;
        std::cout << (correct ? "Devtemplate is functioning correctly" : "Devtemplate is malfunctioning") << std::endl;
    #else
        bool correct = d.devtemplate_advanced() == 43;
        std::cout << (correct ? "Advanced Devtemplate is functioning correctly" : "Advanced Devtemplate is malfunctioning") << std::endl;
    #endif
    return correct ? 0 : 1;
}