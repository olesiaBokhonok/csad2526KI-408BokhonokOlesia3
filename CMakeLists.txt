# Add this (or adapt) to your project's CMakeLists.txt to build the tests
enable_testing()
find_package(GTest REQUIRED)
add_executable(test_math_operations tests/test_math_operations.cpp)
target_include_directories(test_math_operations PRIVATE ${CMAKE_CURRENT_SOURCE_DIR})
target_link_libraries(test_math_operations GTest::gtest_main)
add_test(NAME MathOperationsTest COMMAND test_math_operations)
