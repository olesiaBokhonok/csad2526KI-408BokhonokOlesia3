#include <gtest/gtest.h>
#include "../math_operations.h"

TEST(BasicAddition, HandlesPositiveNumbers) {
    EXPECT_EQ(add(3, 3), 6);
}

TEST(BasicAddition, HandlesNegativeAndPositive) {
    EXPECT_EQ(add(-2, 2), 0);
}

TEST(BasicAddition, HandlesZeros) {
    EXPECT_EQ(add(0, 0), 0);
}
