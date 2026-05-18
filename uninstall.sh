#!/bin/bash
set -e

if [[ $EUID -ne 0 ]]; then
    echo "Run as root: sudo ./uninstall.sh"
    exit 1
fi

REAL_USER="${SUDO_USER:-$USER}"
REAL_HOME=$(eval echo "~$REAL_USER")

echo "Uninstalling shutupapple..."

apple-block off 2>/dev/null || true

PLIST="/Library/LaunchDaemons/com.shutupapple.kill-apple.plist"
if [[ -f "$PLIST" ]]; then
    launchctl unload "$PLIST" 2>/dev/null || true
    rm -f "$PLIST"
    echo "  Removed kill daemon"
fi

PF_PLIST="/Library/LaunchDaemons/com.shutupapple.pf-restore.plist"
if [[ -f "$PF_PLIST" ]]; then
    launchctl unload "$PF_PLIST" 2>/dev/null || true
    rm -f "$PF_PLIST"
    echo "  Removed pf restore daemon"
fi

AGENT="$REAL_HOME/Library/LaunchAgents/com.shutupapple.check.plist"
if [[ -f "$AGENT" ]]; then
    sudo -u "$REAL_USER" launchctl unload "$AGENT" 2>/dev/null || true
    rm -f "$AGENT"
    echo "  Removed login checker"
fi

rm -f /usr/local/bin/apple-block
rm -f /usr/local/bin/apple-block-check
rm -f /usr/local/bin/kill-airplay.sh
rm -rf /usr/local/etc/shutupapple
echo "  Removed scripts and config from /usr/local/"

launchctl enable system/com.apple.apsd 2>/dev/null || true
launchctl enable system/com.apple.AirPlayXPCHelper 2>/dev/null || true
launchctl enable system/com.apple.rapportd 2>/dev/null || true

echo ""
echo "Uninstalled. Apple services will fully restore after a reboot."
