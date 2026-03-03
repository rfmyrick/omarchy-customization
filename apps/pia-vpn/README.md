# Private Internet Access (PIA) VPN

PIA VPN is a secure, private VPN service for protecting your internet connection.

## Prerequisites

Before the installation script can install PIA VPN, you must:

1. **Subscribe to PIA VPN**:
   - Visit: https://www.privateinternetaccess.com/
   - Sign up for a subscription

2. **Download the Linux installer**:
   - Go to: https://www.privateinternetaccess.com/download/linux-vpn
   - Download the Linux `.run` installer file (e.g., `pia-linux-3.7-08412.run`)
   - Any version is acceptable (the script auto-detects)

3. **Place the downloaded file in `~/Downloads/`**:
   ```bash
   mv ~/Downloads/pia-linux-*.run ~/Downloads/
   ```

## Installation

The installation script will:
- Detect the PIA installer in `~/Downloads/`
- Run the installer with sudo
- Enable and start the PIA daemon service
- Make it available in the system menu

## Post-Installation Setup

After installation, you need to complete the setup:

### 1. Launch PIA VPN

```bash
piavpn
```

Or find it in the app launcher (SUPER+SPACE).

### 2. Log In

- Enter your PIA username and password
- These are the credentials from your PIA account

### 3. Configure Auto-Connect (Optional)

To automatically connect to VPN on startup:

1. Open PIA VPN
2. Go to Settings
3. Enable "Connect on Launch"
4. Select your preferred server region

### 4. Test the Connection

1. Click the power button to connect
2. Visit https://www.dnsleaktest.com/ to verify your IP is hidden
3. You should see a different IP address and location

## Usage

- **Connect**: Click the power button in the PIA app
- **Disconnect**: Click the power button again
- **Change Server**: Select a different region from the list
- **Quick Launch**: Add to your favorites in the Omarchy menu

## Troubleshooting

**Installer not found:**
- Ensure the `.run` file is in `~/Downloads/`
- Look for files matching: `pia-linux-*.run`
- Re-download from: https://www.privateinternetaccess.com/download/linux-vpn

**Service won't start:**
```bash
sudo systemctl status piavpn
sudo systemctl restart piavpn
```

**Can't connect:**
- Check your internet connection
- Verify your credentials are correct
- Try a different server region
- Check if firewall is blocking the connection

**Slow speeds:**
- Try different server regions
- Enable "Use Small Packets" in settings
- Switch between UDP and TCP protocols

## Features

- **Kill Switch**: Automatically blocks internet if VPN disconnects
- **Split Tunneling**: Choose which apps use VPN
- **Multi-Hop**: Route through multiple servers for extra privacy
- **Port Forwarding**: Available on select servers

## Support

- PIA Support: https://www.privateinternetaccess.com/helpdesk
- Knowledge Base: https://helpdesk.privateinternetaccess.com/
