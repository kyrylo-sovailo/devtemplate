#include "../include/devtemplate/devtemplate.h"

std::string devtemplate::Devtemplate::version()
{
    #ifdef DEVTEMPLATE_ADVANCED
        std::string text = "Advanced Devtemplate";
    #else
        std::string text = "Devtemplate";
    #endif
    
    text += " " + std::to_string(major()) + "." + std::to_string(minor()) + "." + std::to_string(patch());
    
    text += " (" + std::to_string(size() * 8) + " bit, " + (debug() ? "debug" : "release") + ")";
    
    return text;
}
        
int devtemplate::Devtemplate::major()
{
    return DEVTEMPLATE_MAJOR;
}

int devtemplate::Devtemplate::minor()
{
    return DEVTEMPLATE_MINOR;
}

int devtemplate::Devtemplate::patch()
{
    return DEVTEMPLATE_PATCH;
}

int devtemplate::Devtemplate::size()
{
    return sizeof(void*);
}
        
bool devtemplate::Devtemplate::debug()
{
    #ifdef NDEBUG
        return false;
    #else
        return true;
    #endif
}
        
int devtemplate::Devtemplate::calculate()
{
    return 42;
}

#ifdef DEVTEMPLATE_ADVANCED
    int devtemplate::Devtemplate::calculate_advanced()
    {
        return 43;
    }
#endif