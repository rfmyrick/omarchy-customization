# VPN Setup Guide

This guide explains how to configure Private Internet Access (PIA) VPN after installation.

## Initial Setup

### 1. Launch PIA VPN

After the installation script completes, launch PIA VPN:

```bash
piavpn
```

Or find it in the app launcher (SUPER+SPACE) and search for "Private Internet Access".

### 2. Log In

When PIA launches for the first time:

1. Enter your **PIA username** (usually your email)
2. Enter your **PIA password**
3. Click "Login"

**Note:** These are the credentials you created when you subscribed to PIA, not your computer credentials.

### 3. Connect to VPN

1. Select a server region from the list (or use "Auto" for closest/fastest)
2. Click the **power button** to connect
3. Wait for the connection to establish (usually 3-10 seconds)
4. The power button will turn green when connected

## Configuration

### Enable Auto-Connect

To automatically connect to VPN when PIA starts:

1. Open PIA VPN
2. Click the **gear icon** (Settings) in the top right
3. Go to **General** tab
4. Enable **"Connect on Launch"**
5. Select your preferred server region from the dropdown
6. Close settings

Now PIA will automatically connect every time you start the application.

### Enable Kill Switch

The kill switch blocks all internet traffic if the VPN connection drops:

1. Open Settings (gear icon)
2. Go to **Privacy** tab
3. Enable **"Kill Switch"**
4. Choose mode:
   - **Auto**: Blocks traffic when VPN disconnects unexpectedly
   - **Always**: Only allows traffic through VPN (strictest)

**Recommendation:** Use "Auto" for most users.

### Configure Split Tunneling

Split tunneling lets you choose which apps use the VPN:

1. Open Settings
2. Go to **Split Tunnel** tab
3. Enable **"Split Tunnel"**
4. Add apps:
   - **Bypass VPN**: Apps that should NOT use VPN (e.g., local network apps)
   - **Only VPN**: Apps that MUST use VPN (e.g., torrent client)

**Use case:** Let your browser use VPN for privacy, but allow Steam to bypass for better gaming performance.

### Enable Multi-Hop

Multi-hop routes your traffic through two VPN servers for extra privacy:

1. Open Settings
2. Go to **Privacy** tab
3. Enable **"Multi-hop"**
4. Select your entry and exit regions

**Note:** This will reduce connection speed but increase privacy.

### Port Forwarding

Some PIA servers support port forwarding (useful for torrenting):

1. Connect to a server that supports port forwarding (marked with ↗ in the list)
2. Go to Settings → **Network**
3. Enable **"Request Port Forwarding"**
4. The forwarded port will be displayed

## Testing Your Connection

### Verify VPN is Working

1. **Check your IP address:**
   ```bash
   curl ipinfo.io
   ```
   The location should match your VPN server location, not your real location.

2. **Check for DNS leaks:**
   - Visit: https://www.dnsleaktest.com/
   - Run the extended test
   - All DNS servers should show your VPN location

3. **Check for WebRTC leaks:**
   - Visit: https://browserleaks.com/webrtc
   - Your real IP should NOT be visible

### Test Kill Switch

1. Connect to VPN
2. Start a continuous ping:
   ```bash
   ping 8.8.8.8
   ```
3. Disconnect VPN (click power button)
4. **With kill switch enabled:** Ping should stop/fail
5. **Without kill switch:** Ping continues with your real IP

## Usage Tips

### Quick Connect/Disconnect

- **GUI**: Click the power button in PIA app
- **CLI**: Use the `piavpn` command with flags (if available)
- **Menu**: Add PIA to your favorites in Omarchy menu for quick access

### Choosing Server Regions

- **Closest to you**: Fastest speed, lowest latency
- **Specific country**: Access geo-restricted content
- **Streaming optimized**: Some servers work better with Netflix/Hulu
- **P2P friendly**: Marked with ↗, support port forwarding

### When to Use VPN

**Always use VPN:**
- On public WiFi (coffee shops, airports, hotels)
- When accessing sensitive accounts
- When downloading torrents
- When bypassing geo-restrictions

**VPN optional:**
- At home on trusted network
- For high-bandwidth activities (gaming, 4K streaming)
- When maximum speed is required

### Performance Tips

1. **Choose nearby servers** for better speed
2. **Use WireGuard protocol** (faster than OpenVPN)
   - Settings → Network → Protocol → WireGuard
3. **Disable Multi-hop** if speed is priority
4. **Use split tunneling** to bypass VPN for speed-critical apps

## Troubleshooting

### Can't Connect

1. **Check internet connection:**
   ```bash
   ping 8.8.8.8
   ```

2. **Restart PIA daemon:**
   ```bash
   sudo systemctl restart piavpn
   ```

3. **Check service status:**
   ```bash
   sudo systemctl status piavpn
   ```

4. **Try different server:**
   - Some servers may be temporarily down
   - Try a different region

### Slow Speeds

1. **Switch to WireGuard:**
   - Settings → Network → Protocol → WireGuard

2. **Try different server:**
   - Distance matters - closer is faster
   - Some servers are less congested

3. **Disable Multi-hop:**
   - Settings → Privacy → Multi-hop → Off

4. **Use split tunneling:**
   - Bypass VPN for bandwidth-heavy apps

### Connection Drops Frequently

1. **Enable Kill Switch:**
   - Prevents data leakage during drops

2. **Change protocol:**
   - Try OpenVPN instead of WireGuard
   - Or vice versa

3. **Check firewall:**
   ```bash
   sudo ufw status
   # Should show PIA ports are allowed
   ```

4. **Check logs:**
   ```bash
   journalctl -u piavpn -f
   ```

### DNS Leaks

1. **Enable PIA DNS:**
   - Settings → Network → DNS → PIA DNS

2. **Disable IPv6** (if not using):
   - Settings → Network → IPv6 → Disable

3. **Test again:**
   - https://www.dnsleaktest.com/

### App Won't Start

1. **Check if daemon is running:**
   ```bash
   sudo systemctl status piavpn
   ```

2. **Start daemon:**
   ```bash
   sudo systemctl start piavpn
   ```

3. **Enable auto-start:**
   ```bash
   sudo systemctl enable piavpn
   ```

4. **Reinstall if needed:**
   ```bash
   yay -S piavpn-bin
   ```

## CLI Usage

PIA also offers command-line control:

```bash
# Check status
piactl get connectionstate

# Connect
piactl connect

# Disconnect
piactl disconnect

# Get current region
piactl get region

# List all regions
piactl get regions

# Set region
piactl set region "us-east"

# Enable kill switch
piactl set killswitch on
```

## Security Best Practices

1. **Always use kill switch** - Prevents IP leaks
2. **Enable auto-connect** - Ensures VPN is always on
3. **Use strong passwords** - Protect your PIA account
4. **Enable 2FA** - On your PIA account for extra security
5. **Keep PIA updated** - Regular updates fix security issues

## Privacy Notes

- PIA has a **strict no-logs policy** (verified by third parties)
- PIA is based in the USA (Five Eyes country)
- PIA supports **anonymous payment** (cryptocurrency, gift cards)
- PIA provides **court-proven** no-logs evidence

## Support

- **PIA Help Center**: https://helpdesk.privateinternetaccess.com/
- **Live Chat**: Available on PIA website
- **Email Support**: support@privateinternetaccess.com
- **Community**: https://www.reddit.com/r/PrivateInternetAccess/
