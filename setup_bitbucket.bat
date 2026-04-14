@echo off
echo ========================================
echo   BITBUCKET REPOSITORY SETUP
echo ========================================
echo.

echo Current repository status:
git status --short
echo.

echo Available remotes:
git remote -v
echo.

echo ========================================
echo   SETUP INSTRUCTIONS
echo ========================================
echo.
echo 1. Create repository at: https://bitbucket.org
echo 2. Copy your repository URL
echo 3. Run these commands:
echo.
echo    git remote add origin YOUR_BITBUCKET_URL
echo    git push -u origin main
echo.
echo Example:
echo    git remote add origin https://bitbucket.org/username/construction-management-system.git
echo    git push -u origin main
echo.
echo ========================================
echo   READY TO PUSH TO BITBUCKET!
echo ========================================

pause