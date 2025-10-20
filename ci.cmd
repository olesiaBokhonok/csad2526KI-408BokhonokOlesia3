param(
  [string]$BuildType = "Release",
  [int]$Jobs = $env:NUMBER_OF_PROCESSORS
)

# Cross-Windows CI build script using CMake and CTest (PowerShell)
# Usage (PowerShell): ./scripts/ci-build.ps1 -BuildType Release

$ErrorActionPreference = 'Stop'
$BuildDir = "build"

# 1) Configure
cmake -S . -B $BuildDir -DCMAKE_BUILD_TYPE=$BuildType

# 2) Build (Visual Studio generators honor --config; use /m for parallel MSBuild)
cmake --build $BuildDir --config $BuildType -- /m:$Jobs

# 3) Test
ctest --test-dir $BuildDir --output-on-failure -C $BuildType -j $Jobs
