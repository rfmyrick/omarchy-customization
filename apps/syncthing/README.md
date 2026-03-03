# Syncthing

Syncthing is a continuous file synchronization program that synchronizes files between two or more computers in real time.

## Installation

The installation script will:
- Install the `syncthing` package from official repositories
- Enable the user service to start on boot
- Start the service immediately
- Configure firewall rules (if firewall is detected)

## Post-Installation Setup

### 1. Access the Web UI

Open your browser and navigate to:
```
http://localhost:8384
```

### 2. Initial Configuration

1. **Set a GUI Username and Password** (recommended)
   - Go to Settings → GUI
   - Set username and password
   - Save

2. **Note Your Device ID**
   - Found in the web UI header
   - Looks like: `ABC123-DEF456-GHI789-JKL012-MNO345-PQR678-STU901-VWX234`

### 3. Pair Devices

To sync with another device:

1. **On the other device**:
   - Install Syncthing
   - Get its Device ID

2. **Add the remote device**:
   - In the web UI, click "Add Remote Device"
   - Enter the Device ID
   - Give it a name
   - Save

3. **Accept the connection**:
   - On the other device, accept the connection request
   - Choose which folders to share

### 4. Share Folders

1. Click "Add Folder"
2. Set a folder label
3. Choose the folder path
4. Select which devices to share with
5. Save

## Usage

- **Web UI**: http://localhost:8384
- **Status**: `systemctl --user status syncthing`
- **Logs**: `journalctl --user -u syncthing -f`
- **Restart**: `systemctl --user restart syncthing`

## Firewall Configuration

The installation script automatically configures:
- Port 22000/tcp (sync protocol)
- Port 22000/udp (QUIC sync)
- Port 21027/udp (discovery)

## Troubleshooting

**Can't access web UI:**
```bash
systemctl --user status syncthing
systemctl --user restart syncthing
```

**Devices not connecting:**
- Ensure both devices are online
- Check firewall settings
- Verify Device IDs are correct
- Try disabling global discovery if on local network

**Slow sync:**
- Check bandwidth limits in settings
- Enable "LAN Discovery" for local sync
- Adjust number of connection threads

**Conflicts:**
- Syncthing handles conflicts by creating `.sync-conflict-*` files
- Review and merge conflicts manually

## Advanced Configuration

### Ignore Patterns

Create `.stignore` files to exclude certain files:
```
*.tmp
*.log
node_modules
.git
```

### Versioning

Enable file versioning to keep old versions:
1. Folder → Edit
2. File Versioning
3. Choose type (Simple, Staggered, External)
4. Set parameters

### Relay and Discovery

- **Global Discovery**: Enabled by default, allows finding devices over internet
- **Relay**: Enabled by default, helps when direct connection isn't possible
- Disable either in Settings → Connections if not needed

## Security

- All data is encrypted in transit
- Device authentication via certificates
- Optional GUI password protection
- No central server - fully decentralized

## Resources

- Documentation: https://docs.syncthing.net/
- Forum: https://forum.syncthing.net/
- GitHub: https://github.com/syncthing/syncthing
