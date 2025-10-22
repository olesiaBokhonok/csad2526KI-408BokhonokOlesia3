#include <gtest/gtest.h>
#include "math_operations.h"
#include <climits>

using math_ops::add;

TEST(MathOperationsTest, AddBasicCases) {
    EXPECT_EQ(add(0, 0), 0);
    EXPECT_EQ(add(2, 3), 5);
    EXPECT_EQ(add(-1, 1), 0);
    EXPECT_EQ(add(-5, -7), -12);
}

TEST(MathOperationsTest, AddEdgeCases) {
    EXPECT_EQ(add(INT_MAX, 0), INT_MAX);    // INT_MAX + 0
    EXPECT_EQ(add(0, INT_MIN), INT_MIN);    // INT_MIN + 0
}
