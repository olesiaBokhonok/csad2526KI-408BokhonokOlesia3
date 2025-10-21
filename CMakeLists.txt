cmake_minimum_required(VERSION 3.16)

# Replace "MyProject" with your project's name
project(MyProject
  VERSION 0.1.0
  DESCRIPTION "A short description of MyProject"
  LANGUAGES C CXX
)

# -------------------------
# General configuration
# -------------------------
# Build type if not specified by the user (Release/Debug/RelWithDebInfo)
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

include(GNUInstallDirs) # sets CMAKE_INSTALL_* dirs

# -------------------------
# Compiler warnings / flags
# -------------------------
if(MSVC)
  # Enable warning level 4 for MSVC
  add_compile_options(/W4)
else()
  # Enable common warnings for GCC/Clang
  add_compile_options(-Wall -Wextra -Wpedantic)

  # Optionally treat warnings as errors
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
  else()
    message(WARNING "Sanitizers requested but current compiler may not support them.")
  endif()
endif()

if(ENABLE_COVERAGE)
  if(CMAKE_BUILD_TYPE STREQUAL "Debug" AND CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang")
    add_compile_options(--coverage -O0)
    add_link_options(--coverage)
  else()
    message(WARNING "Coverage enabled but it typically only works with Debug builds and gcc/clang.")
  endif()
endif()

# -------------------------
# Source and targets
# -------------------------
# NOTE: Replace the example sources below with your real source files.
# Recommended layout:
#  - include/ (public headers)
#  - src/ (library sources)
#  - app/ (binaries)
#  - tests/ (tests)

# Library target example
add_library(${PROJECT_NAME}_lib
  # src/example.cpp
)
# Public include dir for consumers
target_include_directories(${PROJECT_NAME}_lib
  PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
    $<INSTALL_INTERFACE:include>
)

target_compile_features(${PROJECT_NAME}_lib PUBLIC cxx_std_17)

# Executable example (comment out if not needed)
# add_executable(${PROJECT_NAME}_exe app/main.cpp)
# target_link_libraries(${PROJECT_NAME}_exe PRIVATE ${PROJECT_NAME}_lib)

# -------------------------
# Installation
# -------------------------
# Install targets (adjust target names to your project)
install(TARGETS ${PROJECT_NAME}_lib
  EXPORT ${PROJECT_NAME}Targets
  ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
  LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
  RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

install(DIRECTORY include/ DESTINATION ${CMAKE_INSTALL_INCLUDEDIR})

# Export the package for use with find_package
install(EXPORT ${PROJECT_NAME}Targets
  FILE ${PROJECT_NAME}Targets.cmake
  NAMESPACE ${PROJECT_NAME}::
  DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/${PROJECT_NAME}
)

# Generate a basic package config file
include(CMakePackageConfigHelpers)
write_basic_package_version_file(
  ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}ConfigVersion.cmake
  VERSION ${PROJECT_VERSION}
  COMPATIBILITY AnyNewerVersion
)

install(FILES
  "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}Config.cmake"
  "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}ConfigVersion.cmake"
  DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/${PROJECT_NAME}
)

# -------------------------
# Testing (GoogleTest via FetchContent)
# -------------------------
if(BUILD_TESTING)
  enable_testing()
  include(FetchContent)

  # Fetch GoogleTest if not present
  FetchContent_Declare(
    googletest
    GIT_REPOSITORY https://github.com/google/googletest.git
    GIT_TAG        v1.13.0
  )
  FetchContent_MakeAvailable(googletest)

  # Example test target (replace with real test sources)
  add_executable(${PROJECT_NAME}_tests
    # tests/test_example.cpp
  )
  target_link_libraries(${PROJECT_NAME}_tests PRIVATE gtest_main ${PROJECT_NAME}_lib)
  add_test(NAME ${PROJECT_NAME}_unit_tests COMMAND ${PROJECT_NAME}_tests)
endif()

# -------------------------
# Packaging (CPack)
# -------------------------
include(InstallRequiredSystemLibraries)
set(CPACK_PACKAGE_NAME ${PROJECT_NAME})
set(CPACK_PACKAGE_VENDOR "Your Name or Company")
set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "${PROJECT_DESCRIPTION}")
set(CPACK_PACKAGE_VERSION_MAJOR ${PROJECT_VERSION_MAJOR})
set(CPACK_PACKAGE_VERSION_MINOR ${PROJECT_VERSION_MINOR})
set(CPACK_PACKAGE_VERSION_PATCH ${PROJECT_VERSION_PATCH})
include(CPack)

# -------------------------
# Helper targets / utilities
# -------------------------
# `make format` target (requires clang-format)
find_program(CLANG_FORMAT NAMES clang-format clang-format-12 clang-format-11)
if(CLANG_FORMAT)
  file(GLOB_RECURSE ALL_CXX_SOURCE_FILES CONFIGURE_DEPENDS
    "${CMAKE_SOURCE_DIR}/src/*.cpp" "${CMAKE_SOURCE_DIR}/include/*.h" "${CMAKE_SOURCE_DIR}/include/*.hpp" "${CMAKE_SOURCE_DIR}/app/*.cpp" "${CMAKE_SOURCE_DIR}/tests/*.cpp"
  )
  add_custom_target(format
    COMMAND ${CLANG_FORMAT} -i ${ALL_CXX_SOURCE_FILES}
    WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
    COMMENT "Formatting source files with clang-format"
  )
endif()

# End of CMakeLists.txt
