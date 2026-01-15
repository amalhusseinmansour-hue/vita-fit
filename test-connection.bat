@echo off
echo ========================================
echo Testing Network Connection
echo ========================================
echo.
echo Your PC IP: 192.168.1.9
echo Phone IP: 192.168.1.5
echo.
echo Testing if phone can reach PC...
adb shell "ping -c 2 192.168.1.9"
echo.
echo ========================================
echo If ping failed, there is network isolation.
echo Please check your router settings or use USB tethering.
echo ========================================
pause
