#include <devtemplate/devtemplate.h>
#include <iostream>

int main()
{
    devtemplate::Devtemplate d;
    #ifndef DEVTEMPLATE_ADVANCED
        const bool correct = d.calculate() == 42;
    #else
        const bool correct = d.calculate_advanced() == 43;
    #endif
    std::cout << devtemplate::Devtemplate::version() << (correct ? " is functioning correctly" : " is malfunctioning") << std::endl;
    return correct ? 0 : 1;
}