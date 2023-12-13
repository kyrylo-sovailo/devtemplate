#include "../include/devtemplate/devtemplate.h"
#include <iostream>

int main(int argc, char **argv)
{
    devtemplate::Devtemplate d;
    bool correct, advanced;
    #ifndef DEVTEMPLATE_ADVANCED
        correct = d.devtemplate() == 42;
        advanced = false;
    #else
        correct = d.devtemplate_advanced() == 43;
        advanced = true;
    #endif
    
    std::cout << (advanced ? "Advanced Devtemplate" : "Devtemplate")
        << " (" << static_cast<int>(8 * sizeof(void*)) << " bit)"
        << (correct ? " is functioning correctly" : " is malfunctioning")
        << std::endl;
    return correct ? 0 : 1;
}