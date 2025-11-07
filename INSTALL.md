# Homepage Lite - Installation Guide

## Quick Installation

### 1. Create user and directories
```bash
sudo useradd -r -s /bin/false homepage
sudo mkdir -p /opt/homepage-lite
sudo chown homepage:homepage /opt/homepage-lite
```

### 2. Install binary and configuration
```bash
# Copy binary
sudo cp homepage-lite /opt/homepage-lite/
sudo chmod +x /opt/homepage-lite/homepage-lite

# Copy configuration
sudo cp config.yaml /opt/homepage-lite/
sudo chown homepage:homepage /opt/homepage-lite/config.yaml

# (Optional) Copy custom icons
sudo mkdir -p /opt/homepage-lite/static/dashboard-icons
sudo cp -r static/dashboard-icons/* /opt/homepage-lite/static/dashboard-icons/
sudo chown -R homepage:homepage /opt/homepage-lite/static
```

### 3. Install systemd service
```bash
sudo cp homepage-lite.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable homepage-lite
sudo systemctl start homepage-lite
```

### 4. Check status
```bash
sudo systemctl status homepage-lite
sudo journalctl -u homepage-lite -f
```

## Configuration

Edit `/opt/homepage-lite/config.yaml` then reload:
```bash
sudo systemctl restart homepage-lite
```

The application will auto-reload when config.yaml changes.

## Customization

### Change port
Edit `/opt/homepage-lite/config.yaml`:
```yaml
settings:
  port: 8080  # Change to desired port
```

### Use different config location
Edit `/etc/systemd/system/homepage-lite.service`:
```ini
ExecStart=/opt/homepage-lite/homepage-lite -config /path/to/config.yaml
```

Then reload:
```bash
sudo systemctl daemon-reload
sudo systemctl restart homepage-lite
```

## Logs

```bash
# View all logs
sudo journalctl -u homepage-lite

# Follow logs
sudo journalctl -u homepage-lite -f

# Logs since 1 hour ago
sudo journalctl -u homepage-lite --since "1 hour ago"
```

## Uninstall

```bash
sudo systemctl stop homepage-lite
sudo systemctl disable homepage-lite
sudo rm /etc/systemd/system/homepage-lite.service
sudo systemctl daemon-reload
sudo rm -rf /opt/homepage-lite
sudo userdel homepage
```

## Troubleshooting

### Service won't start
```bash
# Check logs
sudo journalctl -u homepage-lite -n 50

# Check file permissions
ls -la /opt/homepage-lite

# Test binary manually
sudo -u homepage /opt/homepage-lite/homepage-lite -config /opt/homepage-lite/config.yaml
```

### Port already in use
```bash
# Find what's using the port
sudo netstat -tulpn | grep :8080

# Change port in config.yaml
```

### Config file errors
```bash
# Validate YAML syntax
yamllint /opt/homepage-lite/config.yaml
```
