@echo off
SETLOCAL EnableDelayedExpansion

:: Check if jq is installed
where jq >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo jq is not installed. Download from https://stedolan.github.io/jq/
    echo Please install jq and add it to your PATH.
    pause
    exit /b 1
)

:: Check if git is installed
where git >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo Git is not installed. Download from https://git-scm.com/
    pause
    exit /b 1
)

:: Get output file name or use default
set /p output_file="Enter output filename (default: commits.json): "
if "!output_file!"=="" set output_file=commits.json

:: Get number of commits or use all
set /p commit_count="Enter number of commits to export (default: all): "
if "!commit_count!"=="" (
    set git_command=git log --pretty=format:"%%n{^
  \"sha\": \"%%H\",^
  \"commit\": {^
    \"author\": {^
      \"name\": \"%%aN\",^
      \"email\": \"%%aE\",^
      \"date\": \"%%aI\"^
    },^
    \"committer\": {^
      \"name\": \"%%cN\",^
      \"email\": \"%%cE\",^
      \"date\": \"%%cI\"^
    },^
    \"message\": \"%%s\",^
    \"tree\": {^
      \"sha\": \"%%T\"^
    }^
  },^
  \"parents\": \"%%P\"^
},"
) else (
    set git_command=git log -n !commit_count! --pretty=format:"%%n{^
  \"sha\": \"%%H\",^
  \"commit\": {^
    \"author\": {^
      \"name\": \"%%aN\",^
      \"email\": \"%%aE\",^
      \"date\": \"%%aI\"^
    },^
    \"committer\": {^
      \"name\": \"%%cN\",^
      \"email\": \"%%cE\",^
      \"date\": \"%%cI\"^
    },^
    \"message\": \"%%s\",^
    \"tree\": {^
      \"sha\": \"%%T\"^
    }^
  },^
  \"parents\": \"%%P\"^
},"
)

:: Execute command and process output
echo Generating commit history...
(%git_command%) > temp.json

:: Make valid JSON array and process parents
echo [ > temp_array.json
type temp.json >> temp_array.json
echo ] >> temp_array.json

:: Fix trailing comma if it exists
powershell -Command "(Get-Content temp_array.json -Raw) -replace ',]', ']' | Set-Content temp_array.json"

:: Process with jq
jq "map(.parents |= (split(\" \") | map(select(. != \"\") | {sha: .})))" temp_array.json > "%output_file%"

:: Clean up
del temp.json
del temp_array.json

echo Done! Commit history saved to %output_file%
pause
