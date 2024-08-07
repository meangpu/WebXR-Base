@echo off
setlocal enabledelayedexpansion

REM Configuration
set BRANCH_NAME=main
set SCRIPT_NAME=%~nx0

echo Step 1: Preparing the repository
cd /d "%~dp0"

echo Step 2: Acquiring GitHub repository URL
for /f "tokens=*" %%a in ('git config --get remote.origin.url 2^>nul') do set REPO_URL=%%a
if "%REPO_URL%"=="" (
    echo Error: Could not acquire GitHub repository URL.
    echo Please ensure this is a Git repository and has a remote named 'origin'.
    echo Verify by running 'git remote -v' in the repository directory.
    exit /b 1
)
echo Repository URL: %REPO_URL%

echo Step 3: Backing up important files
if not exist temp_backup mkdir temp_backup
copy %SCRIPT_NAME% temp_backup\ > nul

echo Step 4: Resetting the repository
if exist .git (
    attrib -r -h -s .git /s /d
    rmdir /s /q .git
)

echo Step 5: Initializing a new repository
git init -b main

echo Step 6: Copying new build files
REM Add your copy commands here

echo Step 7: Restoring backed-up files
xcopy /y temp_backup\* . > nul
rmdir /s /q temp_backup

echo Step 8: Committing changes
git add -A
git commit -m "Reset build %date%" || (
    echo No changes to commit. Exiting.
    exit /b 0
)

echo Step 9: Pushing to GitHub
git remote add origin %REPO_URL%
git push -f origin %BRANCH_NAME%

echo Process completed. Repository has been reset and updated.