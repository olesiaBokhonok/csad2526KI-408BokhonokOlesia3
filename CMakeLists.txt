cmake_minimum_required(VERSION 3.16)

project(MyProject
  VERSION 0.1.0
  DESCRIPTION "A short description of MyProject"
  LANGUAGES C CXX
)

# -------------------------
# General configuration
# -------------------------
if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
  set(CMAKE_BUILD_TYPE Release CACHE STRING "Choose the type of build." FORCE)
endif()

# C/C++ standards
set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_C_EXTENSIONS OFF)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# Common options
option(BUILD_SHARED_LIBS "Build libraries as shared libraries" OFF)
option(BUILD_TESTING "Enable building tests" ON)
option(ENABLE_SANITIZERS "Enable Address/Undefined sanitizers (Debug builds only)" OFF)
option(ENABLE_COVERAGE "Enable coverage flags (gcc/clang, only for Debug)" OFF)

include(GNUInstallDirs)

# -------------------------
# Compiler warnings / flags
# -------------------------
if(MSVC)
  add_compile_options(/W4)
else()
  add_compile_options(-Wall -Wextra -Wpedantic)
  option(WARNINGS_AS_ERRORS "Treat compiler warnings as errors" OFF)
  if(WARNINGS_AS_ERRORS)
    add_compile_options(-Werror)
  endif()
endif()

# -------------------------
# Optional sanitizers & coverage
# -------------------------
if(ENABLE_SANITIZERS)
  if(CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang")
    add_compile_options(-fsanitize=address,undefined -fno-omit-frame-pointer)
    add_link_options(-fsanitize=address,undefined)
  endif()
endif()

if(ENABLE_COVERAGE)
  if(CMAKE_BUILD_TYPE STREQUAL "Debug" AND CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang")
    add_compile_options(--coverage -O0)
    add_link_options(--coverage)
  endif()
endif()

# -------------------------
# Source and targets
# -------------------------
add_library(${PROJECT_NAME}_lib
  math_operations.cpp
)

target_include_directories(${PROJECT_NAME}_lib
  PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}
)

target_compile_features(${PROJECT_NAME}_lib PUBLIC cxx_std_17)

add_executable(${PROJECT_NAME}_exe main.cpp)
target_link_libraries(${PROJECT_NAME}_exe PRIVATE ${PROJECT_NAME}_lib)

# -------------------------
# Installation (optional)
# -------------------------
install(TARGETS ${PROJECT_NAME}_lib ${PROJECT_NAME}_exe
  RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
  LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
  ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
)

# -------------------------
# Testing (GoogleTest via FetchContent)
# -------------------------
if(BUILD_TESTING)
  enable_testing()
  include(FetchContent)

  FetchContent_Declare(
    googletest
    GIT_REPOSITORY https://github.com/google/googletest.git
    GIT_TAG main  # замість release-1.13.0, щоб уникнути помилки
  )
  FetchContent_MakeAvailable(googletest)

  add_executable(${PROJECT_NAME}_tests tests/test_math_operations.cpp)
  target_link_libraries(${PROJECT_NAME}_tests PRIVATE gtest_main ${PROJECT_NAME}_lib)

  add_test(NAME ${PROJECT_NAME}_unit_tests COMMAND ${PROJECT_NAME}_tests)
endif()
