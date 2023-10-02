#pragma once

namespace devtemplate
{
    ///Class example
    class Devtemplate
    {
    public:
        ///Returns result of devtemplate calculations
        int devtemplate();
        
        #ifdef DEVTEMPLATE_ADVANCED
            ///Returns result of advanced devtemplate calculations
            int devtemplate_advanced();
        #endif
    };
}

/** @mainpage Template repository for CMake/C++
This is a template repository
*/