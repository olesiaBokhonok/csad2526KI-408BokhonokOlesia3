#include <gtest/gtest.h>
#include "math_operations.h"
#include <limits>

TEST(AdditionTest, AddsPositiveNumbers) {
    EXPECT_EQ(add(2, 3), 5);
    EXPECT_EQ(add(100, 200), 300);
}

TEST(AdditionTest, AddsNegativeNumbers) {
    EXPECT_EQ(add(-2, -3), -5);
    EXPECT_EQ(add(-100, -200), -300);
}

TEST(AdditionTest, AddsPositiveAndNegative) {
    EXPECT_EQ(add(5, -3), 2);
    EXPECT_EQ(add(-7, 4), -3);
}

TEST(AdditionTest, ZeroIsIdentity) {
    EXPECT_EQ(add(0, 7), 7);
    EXPECT_EQ(add(7, 0), 7);
    EXPECT_EQ(add(0, 0), 0);
}

TEST(AdditionTest, CommutativeProperty) {
    EXPECT_EQ(add(123, 456), add(456, 123));
    EXPECT_EQ(add(-50, 20), add(20, -50));
}

TEST(AdditionTest, LargeValuesWithinRange) {
    // Avoid signed overflow (undefined behavior). Use values that stay within range.
    int a = std::numeric_limits<int>::max() - 1;
    int b = 1;
    EXPECT_EQ(add(a, b), std::numeric_limits<int>::max());
}

TEST(AdditionTest, OppositeValuesCancel) {
    int a = std::numeric_limits<int>::max();
    EXPECT_EQ(add(a, -a), 0);
    EXPECT_EQ(add(-a, a), 0);
}

TEST(AdditionTest, MinAndZero) {
    EXPECT_EQ(add(std::numeric_limits<int>::min(), 0), std::numeric_limits<int>::min());
    EXPECT_EQ(add(0, std::numeric_limits<int>::min()), std::numeric_limits<int>::min());
}
