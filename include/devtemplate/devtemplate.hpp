#pragma once

///@if 0 != 0
namespace devtemplate
{
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
}
///@endif