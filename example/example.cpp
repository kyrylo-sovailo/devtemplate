#include "../include/devtemplate/devtemplate.h"
#include <gtest/gtest.h>

TEST(Example, Example)
{
    devtemplate::Devtemplate *d;
    EXPECT_NO_THROW(d = new devtemplate::Devtemplate());
    EXPECT_EQ(d->devtemplate(), 0);
    EXPECT_NO_THROW(delete d);
}

int main(int argc, char **argv)
{
    testing::InitGoogleTest(&argc, argv);
    return RUN_ALL_TESTS();
}