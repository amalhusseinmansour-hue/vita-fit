import paramiko

# Connection details
host = "46.202.90.197"
port = 65002
username = "u126213189"
password = "Alenwanapp33510421@"

try:
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(host, port=port, username=username, password=password, timeout=30)

    # Delete the upload helper file
    stdin, stdout, stderr = ssh.exec_command("rm -f /home/u126213189/domains/vitafit.online/backend/public/upload_helper.php")
    stdout.read()
    print("Deleted upload_helper.php for security")

    ssh.close()
except Exception as e:
    print(f"Error: {e}")
