#include "../include/devtemplate/devtemplate.h"
#include <iostream>

int main(int argc, char **argv)
{
    devtemplate::Devtemplate d;
    bool correct = d.devtemplate() == 42;
    std::cout << (correct ? "Devtemplate is functioning correctly" : "Devtemplate is malfunctioning") << std::endl;
    return correct ? 0 : 1;
}