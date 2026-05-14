#!/bin/bash
set -e

if [[ $EUID -ne 0 ]]; then
    echo "Run as root: sudo ./uninstall.sh"
    exit 1
fi

echo "Uninstalling shutupapple..."

apple-block off 2>/dev/null || true

PLIST="/Library/LaunchDaemons/com.shutupapple.kill-apple.plist"
if [[ -f "$PLIST" ]]; then
    launchctl unload "$PLIST" 2>/dev/null || true
    rm -f "$PLIST"
    echo "  Removed kill daemon"
fi

rm -f /usr/local/bin/apple-block
rm -f /usr/local/bin/kill-airplay.sh
echo "  Removed scripts from /usr/local/bin/"

launchctl enable system/com.apple.apsd 2>/dev/null || true
launchctl enable system/com.apple.AirPlayXPCHelper 2>/dev/null || true
launchctl enable system/com.apple.rapportd 2>/dev/null || true

echo ""
echo "Uninstalled. Apple services will fully restore after a reboot."
