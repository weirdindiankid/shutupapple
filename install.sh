#!/bin/bash
set -e

if [[ $EUID -ne 0 ]]; then
    echo "Run as root: sudo ./install.sh"
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REAL_USER="${SUDO_USER:-$USER}"
REAL_HOME=$(eval echo "~$REAL_USER")

echo "Installing shutupapple..."

cp "$SCRIPT_DIR/apple-block" /usr/local/bin/apple-block
chmod +x /usr/local/bin/apple-block
echo "  Installed apple-block to /usr/local/bin/"

cp "$SCRIPT_DIR/apple-block-check" /usr/local/bin/apple-block-check
chmod +x /usr/local/bin/apple-block-check
echo "  Installed apple-block-check to /usr/local/bin/"

AGENT_DIR="$REAL_HOME/Library/LaunchAgents"
mkdir -p "$AGENT_DIR"
cp "$SCRIPT_DIR/com.shutupapple.check.plist" "$AGENT_DIR/com.shutupapple.check.plist"
chown "$REAL_USER" "$AGENT_DIR/com.shutupapple.check.plist"
sudo -u "$REAL_USER" launchctl load "$AGENT_DIR/com.shutupapple.check.plist" 2>/dev/null || true
echo "  Installed login checker (alerts you if a macOS update wipes protections)"

PF_PLIST="/Library/LaunchDaemons/com.shutupapple.pf-restore.plist"
cp "$SCRIPT_DIR/com.shutupapple.pf-restore.plist" "$PF_PLIST"
chown root:wheel "$PF_PLIST"
chmod 644 "$PF_PLIST"
launchctl load "$PF_PLIST" 2>/dev/null || true
echo "  Installed pf.conf restore daemon (restores custom firewall rules on boot)"

echo ""
echo "Installed. Now run:"
echo "  sudo apple-block on        # block Apple telemetry"
echo "  sudo apple-block nuclear   # block + kill daemon (recommended)"
echo "  sudo apple-block scan      # find and block new Apple processes"
echo "  sudo apple-block pf-save   # save your /etc/pf.conf so it survives updates"
echo "  sudo apple-block status    # verify"
echo ""
echo "After macOS updates, the login checker will alert you if"
echo "protections were wiped. Just re-run: sudo apple-block nuclear"
