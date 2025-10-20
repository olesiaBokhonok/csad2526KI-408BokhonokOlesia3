#!/usr/bin/env bash
# Cross-Unix CI build script using CMake and CTest (Linux, macOS)
# Usage: ./scripts/ci-build.sh [Release|Debug]
set -euo pipefail

BUILD_DIR=build
BUILD_TYPE=${1:-Release}

# determine parallel jobs (nproc on Linux, sysctl on macOS, fallback to 2)
JOBS=${JOBS:-$(nproc 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || echo 2)}

# 1) Create build directory and configure
cmake -S . -B "${BUILD_DIR}" -DCMAKE_BUILD_TYPE="${BUILD_TYPE}"

# 2) Build the project
cmake --build "${BUILD_DIR}" --config "${BUILD_TYPE}" -- -j "${JOBS}"

# 3) Run tests with CTest
ctest --test-dir "${BUILD_DIR}" --output-on-failure -C "${BUILD_TYPE}" -j "${JOBS}"
