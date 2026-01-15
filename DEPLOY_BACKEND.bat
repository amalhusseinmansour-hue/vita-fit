@echo off
echo ============================================
echo    VitaFit Backend Deployment Script
echo ============================================
echo.

REM Configuration
set SERVER=82.25.83.217
set PORT=65002
set USER=u126213189
set REMOTE_PATH=/home/u126213189/domains/vitafit.online/backend

echo Step 1: Upload backend files...
echo Please enter your SSH password when prompted.
echo.

REM Use scp to upload the zip file
scp -P %PORT% "C:\Users\HP\Desktop\gym\backend-deploy.zip" %USER%@%SERVER%:%REMOTE_PATH%/../

echo.
echo Step 2: Extract and setup on server...
echo Please enter your SSH password again when prompted.
echo.

REM SSH commands to extract and setup
ssh -p %PORT% %USER%@%SERVER% "cd ~/domains/vitafit.online && unzip -o backend-deploy.zip -d backend && rm backend-deploy.zip && cd backend && npm install && npm install -g pm2 && pm2 stop vitafit-api 2>/dev/null; pm2 start server.js --name vitafit-api && pm2 save"

echo.
echo ============================================
echo    Deployment Complete!
echo ============================================
echo.
echo IMPORTANT: Before running this script, make sure you:
echo 1. Have updated backend/.env.production with your MongoDB Atlas credentials
echo 2. Renamed it to .env on the server after upload
echo.
echo Your API should now be running at:
echo https://vitafit.online/api
echo.
pause
