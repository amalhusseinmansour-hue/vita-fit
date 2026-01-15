@echo off
echo Adding firewall rule for port 5000...
netsh advfirewall firewall add rule name="Gym Backend Server" dir=in action=allow protocol=TCP localport=5000
echo Done!
pause
