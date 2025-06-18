@echo off
SETLOCAL EnableDelayedExpansion

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

:: Generate temporary JSON
echo Generating commit history...
(%git_command%) > temp.json

:: Use PowerShell to process the JSON
powershell -Command ^
  "$commits = Get-Content temp.json -Raw; ^
   $jsonArray = '[' + ($commits -replace ',(\s*)]$', '$1]') + ']'; ^
   $objects = $jsonArray | ConvertFrom-Json; ^
   $objects | ForEach-Object { ^
     if ($_.parents) { ^
       $_.parents = $_.parents -split ' ' | Where-Object { $_ } | ForEach-Object { @{ sha = $_ } } ^
     else { $_.parents = @() } ^
   }; ^
   $objects | ConvertTo-Json -Depth 10 | Out-File '!output_file!' -Encoding utf8"

:: Clean up
del temp.json

echo Done! Commit history saved to !output_file!
pause
