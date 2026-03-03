# Syncthing Setup Guide

This guide explains how to configure Syncthing after installation.

## What is Syncthing?

Syncthing is a continuous file synchronization program that synchronizes files between two or more computers in real time, securely and privately.

**Key Features:**
- No central server - peer-to-peer
- All data is encrypted in transit
- Automatic syncing across devices
- Works on local network and internet
- Free and open source

## Initial Setup

### 1. Access the Web UI

After the installation script completes, open your browser and go to:

```
http://localhost:8384
```

This opens the Syncthing web interface.

### 2. Initial Configuration

**First time setup wizard:**

1. **Device Name** (optional):
   - Give your laptop a recognizable name
   - Example: "HP-ZBook-G1a" or "My-Laptop"

2. **GUI Authentication** (recommended):
   - Set a username and password
   - This protects the web interface
   - Remember these credentials!

3. **Anonymous Usage Reporting**:
   - Optional - helps developers improve Syncthing
   - Choose based on your privacy preferences

4. **Finish**:
   - Click "Finish" to complete setup

### 3. Note Your Device ID

Your **Device ID** is displayed in the top right of the web UI.

It looks like:
```
ABC123-DEF456-GHI789-JKL012-MNO345-PQR678-STU901-VWX234
```

**Save this!** You'll need it to pair with other devices.

## Pairing Devices

To sync files between devices, you need to pair them.

### Pair with Another Device

#### On the Other Device:

1. Install Syncthing on the other device
2. Get its Device ID (from its web UI)
3. Keep both devices connected to the internet

#### On Your Laptop:

1. In the Syncthing web UI, click **"Add Remote Device"**
2. Enter the other device's Device ID
3. Give it a friendly name (e.g., "My-Desktop" or "Work-PC")
4. Click **"Save"**

#### On the Other Device:

1. A notification will appear: "Device ABC123 wants to connect"
2. Click **"Add Device"**
3. Give your laptop a name
4. Click **"Save"**

**Devices are now paired!**

### Pair Multiple Devices

Repeat the process above for each device you want to sync with.

Common setups:
- **Laptop + Desktop**: Sync work files between computers
- **Laptop + Phone**: Access files on mobile
- **Laptop + Server**: Backup to home server
- **Multiple computers**: Keep all devices in sync

## Sharing Folders

Once devices are paired, you can share folders between them.

### Create a Shared Folder

1. In Syncthing web UI, click **"Add Folder"**

2. **General Tab**:
   - **Folder Label**: Give it a name (e.g., "Documents", "Photos")
   - **Folder Path**: Where on your laptop to store it
     - Example: `~/Sync/Documents` or `~/Documents`
   - **Folder ID**: Auto-generated, can leave as-is

3. **Sharing Tab**:
   - Check the devices you want to share with
   - Only paired devices will appear here

4. **Advanced Tab** (optional):
   - **Folder Type**:
     - **Send & Receive**: Both devices can modify files (default)
     - **Send Only**: This device sends but doesn't receive changes
     - **Receive Only**: This device receives but doesn't send changes
   - **Ignore Patterns**: Files to exclude (see below)
   - **Versioning**: Keep old versions of files (see below)

5. Click **"Save"**

### Accept the Folder on Other Device

1. On the other device, a notification appears: "Device wants to share folder"
2. Click **"Add"**
3. Choose where to save the folder on that device
4. Click **"Save"**

**Files will now sync between devices!**

### Common Folder Setups

#### Sync Documents
```
Folder Label: Documents
Folder Path: ~/Documents
Share with: Work-PC, Home-Desktop
```

#### Sync Photos
```
Folder Label: Photos
Folder Path: ~/Pictures
Share with: All devices
```

#### Sync Projects
```
Folder Label: Projects
Folder Path: ~/Projects
Share with: Work-PC
Type: Send & Receive
```

#### Backup to Server (One-way)
```
Folder Label: Laptop-Backup
Folder Path: ~/
Share with: Home-Server
Type: Send Only (laptop sends, server receives)
```

## Advanced Configuration

### Ignore Patterns

Exclude certain files from syncing by creating `.stignore` files.

**Example `.stignore`:**
```
// Ignore temporary files
*.tmp
*.log

// Ignore node_modules
node_modules

// Ignore git repositories (if you don't want to sync code)
.git

// Ignore IDE files
.vscode
.idea

// Ignore OS files
.DS_Store
Thumbs.db
```

**Where to place:**
- In the root of any synced folder
- Syncthing will read it automatically

### File Versioning

Keep old versions of files when they're modified or deleted.

**Enable versioning:**
1. Folder → Edit
2. Advanced tab
3. **File Versioning**:
   - **Simple File Versioning**: Keep X versions of each file
   - **Staggered File Versioning**: Keep versions with decreasing frequency
   - **External File Versioning**: Use custom script
4. Set parameters (e.g., "5" for 5 versions, "30" for 30 days)
5. Save

**Use cases:**
- **Documents**: Versioning prevents losing important work
- **Photos**: Versioning protects against accidental deletion
- **Code**: Versioning with git is usually better

### Ignore Permissions

By default, Syncthing syncs file permissions. On cross-platform syncs (Linux ↔ Windows), this can cause issues.

**To ignore permissions:**
1. Folder → Edit
2. Advanced tab
3. Check **"Ignore Permissions"**
4. Save

## Network Configuration

### Local Discovery

Syncthing can find devices on your local network automatically.

**Enable:**
1. Settings → Connections
2. Enable **"Local Discovery"**

**Benefits:**
- Faster syncing on local network
- Doesn't use internet bandwidth
- Lower latency

### Global Discovery

Find devices over the internet.

**Enable:**
1. Settings → Connections
2. Enable **"Global Discovery"**

**How it works:**
- Uses Syncthing's public discovery servers
- Devices announce their presence
- Only Device IDs are shared (no file data)

**Privacy note:**
- You can disable global discovery and still sync via:
  - Static IP addresses
  - DynDNS
  - Local network only

### Relays

When devices can't connect directly (e.g., both behind NAT), Syncthing can use relay servers.

**Enable:**
1. Settings → Connections
2. Enable **"Relaying"**

**Performance:**
- Relays are slower than direct connections
- Used only when direct connection isn't possible
- Can be disabled if you have direct connectivity

## Troubleshooting

### Devices Won't Connect

1. **Check if both devices are online**
   - Both need internet or local network access

2. **Verify Device IDs are correct**
   - Typos in Device IDs prevent connection
   - Copy-paste IDs to avoid errors

3. **Check firewall**
   ```bash
   # Syncthing uses these ports:
   # 22000/tcp - sync protocol
   # 22000/udp - QUIC sync
   # 21027/udp - discovery
   
   # Check if ports are open
   sudo ufw status
   
   # The installation script should have configured this
   ```

4. **Enable discovery**
   - Settings → Connections → Enable "Local Discovery" and/or "Global Discovery"

5. **Check logs**
   - In web UI: Settings → Logs
   - Or: `journalctl --user -u syncthing -f`

### Syncing is Slow

1. **Check connection type**
   - Local network: Should be fast
   - Internet: Limited by upload speed of sending device
   - Relay: Slower than direct connection

2. **Enable LAN discovery**
   - Ensures local sync doesn't go through internet

3. **Check bandwidth limits**
   - Settings → Connections → Incoming/Outgoing Rate Limit
   - Make sure they're not set too low

4. **Number of threads**
   - Advanced setting: "Max Concurrent Incoming/Outgoing Requests"
   - Increasing can help with many small files

### Files Not Syncing

1. **Check folder status**
   - Web UI shows folder status (e.g., "Up to Date", "Syncing")
   - Click folder to see details

2. **Check ignore patterns**
   - Files matching `.stignore` patterns won't sync
   - Check ignore patterns on both devices

3. **Check conflicts**
   - Syncthing creates `.sync-conflict-*` files when conflicts occur
   - Search for files with "sync-conflict" in the name
   - Manually resolve conflicts

4. **Check permissions**
   - Syncthing needs read/write access to folders
   - Check file ownership with `ls -la`

### Conflict Files

When the same file is modified on two devices simultaneously, Syncthing creates conflict files.

**Example:**
```
report.docx
report.sync-conflict-20250220-143000.docx
```

**Resolution:**
1. Both versions are preserved
2. Compare the files
3. Merge changes manually
4. Delete the conflict file

**Prevention:**
- Don't edit the same file on multiple devices simultaneously
- Use file locking (if application supports it)
- Communicate with collaborators

### Web UI Not Loading

1. **Check if Syncthing is running**
   ```bash
   systemctl --user status syncthing
   ```

2. **Restart Syncthing**
   ```bash
   systemctl --user restart syncthing
   ```

3. **Check if port 8384 is in use**
   ```bash
   ss -tlnp | grep 8384
   ```

4. **Check logs**
   ```bash
   journalctl --user -u syncthing -n 50
   ```

## Best Practices

### Security

1. **Set GUI password** - Prevents unauthorized access to web UI
2. **Use HTTPS** - Enable TLS in Settings → GUI
3. **Limit device access** - Only pair trusted devices
4. **Keep Syncthing updated** - Regular updates fix security issues

### Performance

1. **Sync only what you need** - Don't sync entire home directory
2. **Use ignore patterns** - Exclude temporary and cache files
3. **Enable LAN discovery** - Faster local syncing
4. **Schedule restarts** - Restart Syncthing weekly for best performance

### Organization

1. **Descriptive folder names** - "Work-Docs" is better than "Folder1"
2. **Device naming** - "HP-ZBook-G1a" is better than "Device-A"
3. **Separate folders by purpose** - Work, Personal, Media, etc.
4. **Document your setup** - Keep notes on what syncs where

### Backup Strategy

Syncthing is **not** a backup solution - it's a synchronization tool.

**Differences:**
- **Sync**: If you delete a file on one device, it's deleted everywhere
- **Backup**: Deleted files are preserved for recovery

**Proper backup strategy:**
1. Use Syncthing to sync between devices
2. Use a separate backup tool (e.g., restic, borg) for actual backups
3. Or: Use Syncthing's "Send Only" mode to push to a backup server

## Command Line Usage

While the web UI is easiest, you can also control Syncthing via CLI:

```bash
# Check status
systemctl --user status syncthing

# View logs
journalctl --user -u syncthing -f

# Restart
systemctl --user restart syncthing

# Stop
systemctl --user stop syncthing

# Start on boot
systemctl --user enable syncthing

# Disable auto-start
systemctl --user disable syncthing
```

## Resources

- **Documentation**: https://docs.syncthing.net/
- **Forum**: https://forum.syncthing.net/
- **GitHub**: https://github.com/syncthing/syncthing
- **Security**: https://syncthing.net/security/

## Support

- Check the [forum](https://forum.syncthing.net/) for community help
- Report bugs on [GitHub](https://github.com/syncthing/syncthing/issues)
- Read the [documentation](https://docs.syncthing.net/)
