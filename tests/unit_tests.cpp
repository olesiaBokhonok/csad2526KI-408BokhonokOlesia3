#include <gtest/gtest.h>
#include "../math_operations.h"

TEST(BasicAddition, HandlesPositiveNumbers) {
    EXPECT_EQ(math_ops::add(3, 3), 6);
}

TEST(BasicAddition, HandlesNegativeAndPositive) {
    EXPECT_EQ(math_ops::add(-2, 2), 0);
}

TEST(BasicAddition, HandlesZeros) {
    EXPECT_EQ(math_ops::add(0, 0), 0);
}
