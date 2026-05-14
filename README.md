# shutupapple

Fuck off for not allowing me sovereignty over my own device, Apple.

A toggleable shell script that blocks Apple telemetry, analytics, AirPlay discovery, push notifications, and every other phone-home process that Apple forces onto your Mac without your consent.

## What it does

- Sinkholes 34 known Apple telemetry/analytics/tracking/ads domains via `/etc/hosts`
- Kills Apple spyware processes: `analyticsd`, `diagnosticd`, `symptomsd`, `submissionsd`, `apsd`, `AirPlayXPCHelper`, `AirPlayUIAgent`, `rapportd`
- Disables those daemons across reboots via `launchctl disable`
- Fully reversible with a single command

## Install

```bash
sudo cp apple-block /usr/local/bin/apple-block
sudo chmod +x /usr/local/bin/apple-block
```

## Usage

```bash
# Block everything
sudo apple-block on

# Check what's still phoning home
sudo apple-block status

# Restore Apple services (if something breaks)
sudo apple-block off
```

## Optional: pf firewall rules for AirPlay

If you also want to block AirPlay device discovery at the network level (so your neighbors' Apple TVs stop showing up as audio outputs), add the following to `/etc/pf.conf` in the filter rules section (after all `scrub-anchor`, `nat-anchor`, `rdr-anchor`, and `dummynet-anchor` lines, but before the `anchor` lines):

```
block drop out quick proto udp to 224.0.0.251 port 5353
block drop in quick proto udp from 224.0.0.251 port 5353
block drop out quick proto tcp to any port 7000
block drop out quick proto tcp to any port 7100
block drop out quick proto udp to any port 7000
block drop out quick proto udp to any port 7011
```

Then reload with `sudo pfctl -f /etc/pf.conf`.

Note: blocking mDNS multicast (224.0.0.251:5353) also disables Bonjour printer discovery. Add your printer by IP address instead.

## Optional: kill daemon

If SIP prevents the `launchctl disable` from taking immediate effect (processes respawn until reboot), create a root LaunchDaemon that kills them every 5 seconds:

```bash
sudo tee /Library/LaunchDaemons/com.shutupapple.kill-airplay.plist <<'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.shutupapple.kill-airplay</string>
    <key>ProgramArguments</key>
    <array>
        <string>/usr/local/bin/kill-airplay.sh</string>
    </array>
    <key>StartInterval</key>
    <integer>5</integer>
    <key>RunAtLoad</key>
    <true/>
    <key>StandardOutPath</key>
    <string>/dev/null</string>
    <key>StandardErrorPath</key>
    <string>/dev/null</string>
</dict>
</plist>
EOF

sudo tee /usr/local/bin/kill-airplay.sh <<'EOF'
#!/bin/bash
killall -9 AirPlayXPCHelper 2>/dev/null
killall -9 AirPlayUIAgent 2>/dev/null
killall -9 rapportd 2>/dev/null
EOF

sudo chmod +x /usr/local/bin/kill-airplay.sh
sudo launchctl load /Library/LaunchDaemons/com.shutupapple.kill-airplay.plist
```

## Uninstall

```bash
sudo apple-block off
sudo rm /usr/local/bin/apple-block
# If you installed the kill daemon:
sudo launchctl unload /Library/LaunchDaemons/com.shutupapple.kill-airplay.plist
sudo rm /Library/LaunchDaemons/com.shutupapple.kill-airplay.plist
sudo rm /usr/local/bin/kill-airplay.sh
```

## License

Do whatever you want with this. Apple certainly does whatever they want with your computer.
