#pragma once

namespace devtemplate
{
#ifndef DEVTEMPLATE_TYPE_INTERFACE

    ///Class example
    class DEVTEMPLATE_EXPORT Devtemplate
    {
    public:
        ///Returns result of devtemplate calculations
        int devtemplate();
        
        #ifdef DEVTEMPLATE_ADVANCED
            ///Returns result of advanced devtemplate calculations
            int devtemplate_advanced();
        #endif
    };

#else

    ///Class example
    class Devtemplate
    {
    public:
        ///Returns result of devtemplate calculations
        int devtemplate()
        {
            return 42;
        }

        #ifdef DEVTEMPLATE_ADVANCED
            ///Returns result of advanced devtemplate calculations
            int devtemplate_advanced()
            {
                return 43;
            }
        #endif
    };

#endif
}