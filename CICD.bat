@echo off
set /p Desc=Enter message:
cd .\
git add .
git commit -m "%Desc%"
git push
pause