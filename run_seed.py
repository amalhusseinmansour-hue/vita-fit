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

    # Check current .env file
    print("Checking .env file...")
    run_command(ssh, f'cat {BACKEND_PATH}/.env')

    # Run database seed
    print("\n" + "="*50)
    print("Running database seed script...")
    print("="*50)

    run_command(ssh, f'cd {BACKEND_PATH} && {NODE_PATH}/node seeders/seed.js', timeout=120)

    print("\n" + "="*50)
    print("Seed completed!")
    print("="*50)

    ssh.close()

if __name__ == '__main__':
    main()
