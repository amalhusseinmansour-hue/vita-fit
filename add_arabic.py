import paramiko

host = "46.202.90.197"
port = 65002
username = "u126213189"
password = "Alenwanapp33510421@"

try:
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(host, port=port, username=username, password=password, timeout=30)

    # Install Arabic language for Filament
    commands = [
        "cd /home/u126213189/domains/vitafit.online/backend && php artisan lang:publish",
        "cd /home/u126213189/domains/vitafit.online/backend && php artisan config:clear",
        "cd /home/u126213189/domains/vitafit.online/backend && php artisan view:clear",
    ]

    for cmd in commands:
        stdin, stdout, stderr = ssh.exec_command(cmd)
        output = stdout.read().decode()
        if output:
            print(output)

    ssh.close()
    print("Done!")

except Exception as e:
    print(f"Error: {e}")
