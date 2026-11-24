@echo off
setlocal EnableExtensions
title Maple Host Release Lab - Publish to GitHub
cd /d "%~dp0"
set "REPO=maple-host-release-lab"
set "DESC=Mainframe change and release lab: COBOL, JCL, PAT testing, Db2 reconciliation and ServiceNow change management on IBM Z Xplore"

echo ================================================================
echo   MAPLE HOST RELEASE LAB - ONE-CLICK PUBLISH TO GITHUB
echo   Folder: %CD%
echo ================================================================
echo.

if not exist "LAB-GUIDE.md" (
  echo [X] This file must sit inside the unzipped maple-host-release-lab folder.
  goto :fail
)

rem ---------------------------------------------------------------- 1. Git
echo [1/7] Checking Git...
where git >nul 2>nul
if errorlevel 1 (
  echo       Git not found - installing it with winget...
  winget install --id Git.Git -e --source winget --accept-package-agreements --accept-source-agreements
  set "PATH=%PATH%;C:\Program Files\Git\cmd"
)
where git >nul 2>nul
if errorlevel 1 (
  echo [X] Git is still not available. Close this window, open it again and rerun.
  goto :fail
)
echo       OK

rem ------------------------------------------------------- 2. GitHub CLI
echo [2/7] Checking GitHub CLI (gh)...
where gh >nul 2>nul
if errorlevel 1 (
  echo       GitHub CLI not found - installing it with winget...
  winget install --id GitHub.cli -e --source winget --accept-package-agreements --accept-source-agreements
  set "PATH=%PATH%;C:\Program Files\GitHub CLI"
)
where gh >nul 2>nul
if errorlevel 1 (
  echo [X] GitHub CLI is still not available. Close this window, open it again and rerun.
  goto :fail
)
echo       OK

rem ------------------------------------------------------------ 3. Sign in
echo [3/7] Checking GitHub sign-in...
gh auth status >nul 2>nul
if errorlevel 1 (
  echo       A browser window will open. Sign in to GitHub and enter the code shown here.
  gh auth login --hostname github.com --git-protocol https --web
  if errorlevel 1 goto :fail
)
gh auth setup-git >nul 2>nul
for /f "delims=" %%u in ('gh api user --jq .login') do set "OWNER=%%u"
for /f "delims=" %%i in ('gh api user --jq .id') do set "GHID=%%i"
if not defined OWNER (
  echo [X] Could not read your GitHub username.
  goto :fail
)
echo       Signed in as %OWNER%

rem -------------------------------------------------------- 4. Identity
echo [4/7] Checking your Git name and email...
git config --global user.name >nul 2>nul
if errorlevel 1 git config --global user.name "Jamie Rowe"
git config --global user.email >nul 2>nul
if errorlevel 1 git config --global user.email "%GHID%+%OWNER%@users.noreply.github.com"
for /f "delims=" %%n in ('git config --global user.name') do echo       Name:  %%n
for /f "delims=" %%e in ('git config --global user.email') do echo       Email: %%e

rem -------------------------------------------------- 5. Local repository
echo [5/7] Preparing the local repository...
if not exist ".git" (
  git init -b main
  if errorlevel 1 goto :fail
)
git add -A
git update-index --chmod=+x scripts/local-build.sh >nul 2>nul
git diff --cached --quiet
if errorlevel 1 (
  git commit -q -m "Maple Host Release Lab: lab kit (COBOL v1.1, JCL, data, change and control docs)"
  if errorlevel 1 goto :fail
  echo       Changes committed
) else (
  echo       Nothing new to commit
)

rem ------------------------------------------------------- 6. GitHub repo
echo [6/7] Publishing to github.com/%OWNER%/%REPO% ...
gh repo view "%OWNER%/%REPO%" >nul 2>nul
if errorlevel 1 (
  gh repo create "%OWNER%/%REPO%" --public --source . --remote origin --push --description "%DESC%"
  if errorlevel 1 goto :fail
) else (
  echo       Repo already exists on GitHub - pushing your latest commits.
  git remote get-url origin >nul 2>nul
  if errorlevel 1 git remote add origin "https://github.com/%OWNER%/%REPO%.git"
  git push -u origin main
  if errorlevel 1 goto :fail
)

rem ------------------------------------------------------------- 7. Done
echo [7/7] Opening your repo and the build check in the browser...
start "" "https://github.com/%OWNER%/%REPO%"
start "" "https://github.com/%OWNER%/%REPO%/actions"
echo.
echo ================================================================
echo   DONE: https://github.com/%OWNER%/%REPO%
echo   The "cobol-build" check on the Actions tab should turn green
echo   within a few minutes. Run this file again any time to push
echo   new evidence and changes.
echo ================================================================
echo.
pause
exit /b 0

:fail
echo.
echo ================================================================
echo   Something went wrong - nothing above was undone, so it is
echo   safe to fix the problem and double-click this file again.
echo   Copy the red/last lines above if you need help.
echo ================================================================
pause
exit /b 1
