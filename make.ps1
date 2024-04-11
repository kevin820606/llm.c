param (
  [string]$target = "all"
)

if (-not $compiler)
{
  $compiler = "clang"
}
# Splitting the flags into an array of individual flags
$cflags = @("-O3", "-Ofast", "-Wno-unused-result", "-fopenmp", "-DOMP")

# File names
$train_exe = ".\train_gpt2.exe"
$test_exe = ".\test_gpt2.exe"
$train_src = ".\train_gpt2.c"
$test_src = ".\test_gpt2.c"

function Build-Train
{
  # Using the splatting feature to pass each flag as a separate argument
  & $compiler -o $train_exe $train_src @cflags
}

function Build-Test
{
  # Using the splatting feature to pass each flag as a separate argument
  & $compiler -o $test_exe $test_src @cflags
}

switch ($target)
{
  "all"
  {
    Build-Train
    Build-Test
  }
  "train_gpt2"
  {
    Build-Train
  }
  "test_gpt2"
  {
    Build-Test
  }
}
