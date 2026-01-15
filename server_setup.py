import paramiko

HOST = '46.202.90.197'
PORT = 65002
USERNAME = 'u126213189'
PASSWORD = 'Alenwanapp33510421@'
BACKEND_PATH = '/home/u126213189/domains/vitafit.online/backend'

def run_command(ssh, command, description=""):
    print(f"\n{'='*50}")
    print(f"Running: {description or command}")
    print('='*50)

    stdin, stdout, stderr = ssh.exec_command(command, timeout=300)

    # Print output
    output = stdout.read().decode('utf-8', errors='ignore')
    error = stderr.read().decode('utf-8', errors='ignore')

    if output:
        print(output)
    if error:
        print(f"Errors/Warnings: {error}")

    return output, error

def main():
    print("Connecting to server...")

    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())

    try:
        ssh.connect(HOST, PORT, USERNAME, PASSWORD)
        print("Connected!")

        # Check Node.js version
        run_command(ssh, 'node -v', 'Checking Node.js version')

        # Check npm version
        run_command(ssh, 'npm -v', 'Checking npm version')

        # List files
        run_command(ssh, f'ls -la {BACKEND_PATH}', 'Listing backend files')

        # Install npm packages
        run_command(ssh, f'cd {BACKEND_PATH} && npm install', 'Installing npm packages')

        # Verify installation
        run_command(ssh, f'ls -la {BACKEND_PATH}/node_modules | head -20', 'Checking node_modules')

        print("\n" + "="*50)
        print("Setup completed!")
        print("="*50)

        ssh.close()

    except Exception as e:
        print(f"Error: {e}")
        return 1

    return 0

if __name__ == '__main__':
    exit(main())
