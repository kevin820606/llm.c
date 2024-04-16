
param (
  [string]$target = "all"
)

# Default compiler set up
if (-not $compiler)
{
  $compiler = "clang"
}

# Compiler flags
$cflags = @("-O3", "-Ofast", "-Wno-unused-result", "-fopenmp", "-DOMP")
$cuflags = @("-O3", "--use_fast_math", "-lcublas", "-lcublasLt", "-Xcompiler", "/wd4819")

# File names setup
$exe_suffix = ".exe"
$src_suffix = ".c"
$gpu_src_suffix = ".cu"

# Helper function to build projects
function Build-Project
{
  param (
    [string]$outputFile,
    [string]$sourceFile,
    [string[]]$flags,
    [string]$compiler = $compiler
  )
  & $compiler -o $outputFile $sourceFile @flags
}

# Mapping targets to their corresponding build actions
switch ($target)
{
  "all"
  {
    Build-Project ".\train_gpt2$exe_suffix" ".\train_gpt2$src_suffix" $cflags
    Build-Project ".\test_gpt2$exe_suffix" ".\test_gpt2$src_suffix" $cflags
    Build-Project ".\train_gpt2cu$exe_suffix" ".\train_gpt2$gpu_src_suffix" $cuflags "nvcc"
    Build-Project ".\test_gpt2cu$exe_suffix" ".\test_gpt2$gpu_src_suffix" $cuflags "nvcc"
  }
  "train_gpt2"
  {
    Build-Project ".\train_gpt2$exe_suffix" ".\train_gpt2$src_suffix" $cflags
  }
  "test_gpt2"
  {
    Build-Project ".\test_gpt2$exe_suffix" ".\test_gpt2$src_suffix" $cflags
  }
  "train_gpt2_cu"
  {
    Build-Project ".\train_gpt2cu$exe_suffix" ".\train_gpt2$gpu_src_suffix" $cuflags "nvcc"
  }
  "test_gpt2_cu"
  {
    Build-Project ".\test_gpt2cu$exe_suffix" ".\test_gpt2$gpu_src_suffix" $cuflags "nvcc"
  }
  "help"
  {
    Write-Host "Usage: `n`-target [all|train_gpt2|test_gpt2|train_gpt2_cu|test_gpt2_cu]`n`Specify the target to build. Defaults to 'all'."
  }
  default
  {
    Write-Host "Unknown target. Use 'help' for command usage."
  }
}

