cmake_minimum_required(VERSION 3.16)

project(MyProject
  VERSION 0.1.0
  DESCRIPTION "A short description of MyProject"
  LANGUAGES C CXX
)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

option(BUILD_TESTING "Enable building tests" ON)

# -------------------------
# Source and targets
# -------------------------
add_library(${PROJECT_NAME}_lib math_operations.cpp)
target_include_directories(${PROJECT_NAME}_lib PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})

add_executable(${PROJECT_NAME}_exe main.cpp)
target_link_libraries(${PROJECT_NAME}_exe PRIVATE ${PROJECT_NAME}_lib)

# -------------------------
# Testing (GoogleTest)
# -------------------------
if(BUILD_TESTING)
  enable_testing()
  include(FetchContent)

  FetchContent_Declare(
    googletest
    GIT_REPOSITORY https://github.com/google/googletest.git
    GIT_TAG main  # актуальна версія без помилки
  )
  FetchContent_MakeAvailable(googletest)

  add_executable(${PROJECT_NAME}_tests tests/unit_tests.cpp)
  target_link_libraries(${PROJECT_NAME}_tests PRIVATE gtest_main ${PROJECT_NAME}_lib)

  add_test(NAME ${PROJECT_NAME}_unit_tests COMMAND ${PROJECT_NAME}_tests)
endif()
