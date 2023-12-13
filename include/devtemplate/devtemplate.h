#pragma once

#include <string>

#define DEV_STRING2(s) #s
#define DEV_STRING(s) DEV_STRING2(s)

namespace devtemplate
{
#ifndef DEVTEMPLATE_TYPE_INTERFACE

    ///Class example
    class DEVTEMPLATE_EXPORT Devtemplate
    {
    public:
        ///Returns information about Devtemplate version
        static std::string version();
        
        ///Returns major version
        static int major();
        
        ///Returns minor version
        static int minor();
        
        ///Returns patch version
        static int patch();
        
        ///Returns pointer size
        static int size();
        
        ///Returns if debug version
        static bool debug();
        
        ///Returns result of Devtemplate calculations
        int calculate();
        
        #ifdef DEVTEMPLATE_ADVANCED
            ///Returns result of advanced Devtemplate calculations
            int calculate_advanced();
        #endif
    };

#else

    ///Class example
    class Devtemplate
    {
    public:
        ///Returns information about Devtemplate version
        static std::string version()
        {
            #ifdef DEVTEMPLATE_ADVANCED
                std::string text = "Advanced Devtemplate";
            #else
                std::string text = "Devtemplate";
            #endif
            
            text += " " + std::to_string(major()) + "." + std::to_string(minor()) + "." + std::to_string(patch());
            
            test += " (" + std::to_string(size() * 8) + " bit, " + (debug() ? "debug" : "release") + ")";
            
            return text;
        }
        
        ///Returns major version
        static int major() { return DEVTEMPLATE_MAJOR; }
        
        ///Returns minor version
        static int minor() { return DEVTEMPLATE_MINOR; }
        
        ///Returns patch version
        static int patch() { return DEVTEMPLATE_PATCH; }
        
        ///Returns pointer size
        static int size() { return sizeof(void*); }
        
        ///Returns if debug version
        static bool debug()
        {
            #ifdef NDEBUG
                return false;
            #else
                return true;
            #endif
        }
        
        ///Returns result of Devtemplate calculations
        int calculate() { return 42; }

        #ifdef DEVTEMPLATE_ADVANCED
            ///Returns result of advanced Devtemplate calculations
            int calculate_advanced() { return 43; }
        #endif
    };

#endif
}