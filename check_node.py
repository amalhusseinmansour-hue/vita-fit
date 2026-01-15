import paramiko

HOST = '46.202.90.197'
PORT = 65002
USERNAME = 'u126213189'
PASSWORD = 'Alenwanapp33510421@'

def run_command(ssh, command):
    print(f"Running: {command}")
    stdin, stdout, stderr = ssh.exec_command(command, timeout=60)
    output = stdout.read().decode('utf-8', errors='ignore')
    error = stderr.read().decode('utf-8', errors='ignore')
    if output:
        print(output)
    if error and 'not found' not in error:
        print(f"stderr: {error}")
    return output

def main():
    print("Connecting...")
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, PORT, USERNAME, PASSWORD)
    print("Connected!\n")

    # Try to find Node.js
    commands = [
        'which node',
        'which nodejs',
        'find /usr -name "node" 2>/dev/null | head -5',
        'find /opt -name "node" 2>/dev/null | head -5',
        'ls -la /usr/local/bin/ | grep node',
        'ls -la ~/bin/ 2>/dev/null | grep node',
        '/usr/bin/node -v 2>/dev/null',
        '/usr/local/bin/node -v 2>/dev/null',
        'cat /etc/os-release',
        'echo $PATH',
    ]

    for cmd in commands:
        run_command(ssh, cmd)
        print("-" * 40)

    ssh.close()

if __name__ == '__main__':
    main()
