import paramiko
import os
from stat import S_ISDIR

# Server credentials
HOST = '46.202.90.197'
PORT = 65002
USERNAME = 'u126213189'
PASSWORD = 'Alenwanapp33510421@'

# Paths
LOCAL_BACKEND = r'C:\Users\HP\Desktop\gym\backend'
REMOTE_PATH = '/home/u126213189/domains/vitafit.online/backend'

# Folders and files to upload (excluding node_modules)
EXCLUDE = ['node_modules', '.git', '__pycache__']

def upload_directory(sftp, local_path, remote_path):
    """Recursively upload a directory"""
    for item in os.listdir(local_path):
        if item in EXCLUDE:
            continue

        local_item = os.path.join(local_path, item)
        remote_item = remote_path + '/' + item

        if os.path.isdir(local_item):
            try:
                sftp.mkdir(remote_item)
                print(f"Created directory: {remote_item}")
            except IOError:
                pass  # Directory might already exist
            upload_directory(sftp, local_item, remote_item)
        else:
            print(f"Uploading: {item}")
            sftp.put(local_item, remote_item)

def main():
    print("Connecting to server...")

    # Create SSH client
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())

    try:
        ssh.connect(HOST, PORT, USERNAME, PASSWORD)
        print("Connected successfully!")

        # Create SFTP client
        sftp = ssh.open_sftp()

        # Create backend directory if not exists
        try:
            sftp.mkdir(REMOTE_PATH)
            print(f"Created directory: {REMOTE_PATH}")
        except IOError:
            print(f"Directory exists: {REMOTE_PATH}")

        # Upload files
        print("\nUploading backend files...")
        upload_directory(sftp, LOCAL_BACKEND, REMOTE_PATH)

        print("\n✅ Upload completed successfully!")

        # List uploaded files
        print("\nFiles on server:")
        stdin, stdout, stderr = ssh.exec_command(f'ls -la {REMOTE_PATH}')
        print(stdout.read().decode())

        sftp.close()
        ssh.close()

    except Exception as e:
        print(f"❌ Error: {e}")
        return 1

    return 0

if __name__ == '__main__':
    exit(main())
