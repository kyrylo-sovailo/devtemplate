#include "../include/devtemplate/devtemplate.h"

int devtemplate::Devtemplate::devtemplate()
{
    return 42;
}

#ifdef DEVTEMPLATE_ADVANCED
    int devtemplate::Devtemplate::devtemplate_advanced()
    {
        return 43;
    }
#endif