import paramiko

HOST = '46.202.90.197'
PORT = 65002
USERNAME = 'u126213189'
PASSWORD = 'Alenwanapp33510421@'
BACKEND_PATH = '/home/u126213189/domains/vitafit.online/backend'
NODE_PATH = '/opt/alt/alt-nodejs18/root/usr/bin'

def run_command(ssh, command, timeout=300):
    print(f"\n>>> {command}\n")
    stdin, stdout, stderr = ssh.exec_command(command, timeout=timeout)

    output = stdout.read().decode('utf-8', errors='ignore')
    error = stderr.read().decode('utf-8', errors='ignore')

    if output:
        print(output)
    if error:
        print(error)

    return output, error

def main():
    print("Connecting to server...")
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, PORT, USERNAME, PASSWORD)
    print("Connected!\n")

    # Check Node.js version
    run_command(ssh, f'{NODE_PATH}/node -v')

    # Check npm version
    run_command(ssh, f'{NODE_PATH}/npm -v')

    # Install packages
    print("\n" + "="*50)
    print("Installing npm packages... (this may take a few minutes)")
    print("="*50)

    run_command(ssh, f'cd {BACKEND_PATH} && {NODE_PATH}/npm install', timeout=600)

    # Verify installation
    run_command(ssh, f'ls {BACKEND_PATH}/node_modules | head -20')

    print("\n" + "="*50)
    print("Installation completed!")
    print("="*50)

    ssh.close()

if __name__ == '__main__':
    main()
