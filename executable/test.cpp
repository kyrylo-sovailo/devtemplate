#include "../include/devtemplate/devtemplate.h"
#ifndef WIN32
    #include <gtest/gtest.h>
#else
    #include <gtest/gtest.h>
#endif

TEST(Test, Test)
{
    devtemplate::Devtemplate *d;
    EXPECT_NO_THROW(d = new devtemplate::Devtemplate());
    EXPECT_EQ(d->calculate(), 42);
    EXPECT_NO_THROW(delete d);
}

#ifdef DEVTEMPLATE_ADVANCED
TEST(Test, AdvancedTest)
{
    devtemplate::Devtemplate *d;
    EXPECT_NO_THROW(d = new devtemplate::Devtemplate());
    EXPECT_EQ(d->calculate_advanced(), 43);
    EXPECT_NO_THROW(delete d);
}
#endif

int main(int argc, char **argv)
{
    testing::InitGoogleTest(&argc, argv);
    return RUN_ALL_TESTS();
}