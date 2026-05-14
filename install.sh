#!/bin/bash
set -e

if [[ $EUID -ne 0 ]]; then
    echo "Run as root: sudo ./install.sh"
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "Installing shutupapple..."

cp "$SCRIPT_DIR/apple-block" /usr/local/bin/apple-block
chmod +x /usr/local/bin/apple-block
echo "  Installed apple-block to /usr/local/bin/"

cp "$SCRIPT_DIR/kill-airplay.sh" /usr/local/bin/kill-airplay.sh
chmod +x /usr/local/bin/kill-airplay.sh
echo "  Installed kill-airplay.sh to /usr/local/bin/"

PLIST_DEST="/Library/LaunchDaemons/com.shutupapple.kill-apple.plist"
sed "s|/usr/local/bin/kill-airplay.sh|/usr/local/bin/kill-airplay.sh|" \
    "$SCRIPT_DIR/com.shutupapple.kill-apple.plist" > "$PLIST_DEST"
chown root:wheel "$PLIST_DEST"
chmod 644 "$PLIST_DEST"
launchctl unload "$PLIST_DEST" 2>/dev/null || true
launchctl load "$PLIST_DEST"
echo "  Installed and loaded kill daemon"

echo ""
echo "Installed. Now run:"
echo "  sudo apple-block on      # block Apple telemetry"
echo "  sudo apple-block status  # verify"
echo ""
echo "The kill daemon is already running and will keep Apple"
echo "processes dead until they stay dead after a reboot."
