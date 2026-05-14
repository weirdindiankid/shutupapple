# shutupapple

Fuck off for not allowing me sovereignty over my own device, Apple.

A toggleable script that blocks Apple telemetry, analytics, AirPlay discovery, push notifications, and every other phone-home process that Apple forces onto your Mac without your consent.

## What it does

- Sinkholes 34+ known Apple telemetry/analytics/tracking/ads/push domains via `/etc/hosts`
- Kills Apple spyware processes: `analyticsd`, `diagnosticd`, `symptomsd`, `submissionsd`, `apsd`, `AirPlayXPCHelper`, `AirPlayUIAgent`, `rapportd`
- Disables those daemons across reboots via `launchctl disable`
- Nuclear mode: installs a root LaunchDaemon that kills Apple processes every second so they can't respawn (SIP keeps them alive until reboot otherwise)
- Fully reversible with a single command

## Install

```bash
git clone <this-repo> shutupapple
cd shutupapple
sudo ./install.sh
```

## Usage

```bash
# Block telemetry, kill processes once, disable daemons for next reboot
sudo apple-block on

# Go nuclear: all of the above PLUS a persistent daemon that
# murders Apple processes every second so they stay dead
sudo apple-block nuclear

# Check what's blocked and if anything is still phoning home
sudo apple-block status

# Restore everything (if Apple breaks something you need)
sudo apple-block off
```

## Uninstall

```bash
sudo ./uninstall.sh
```

Or manually:

```bash
sudo apple-block off
sudo rm /usr/local/bin/apple-block
sudo rm /usr/local/bin/kill-airplay.sh
sudo launchctl unload /Library/LaunchDaemons/com.shutupapple.kill-apple.plist
sudo rm /Library/LaunchDaemons/com.shutupapple.kill-apple.plist
```

## Optional: pf firewall rules for AirPlay

If you want to block AirPlay device discovery at the network level (so your neighbors' Apple TVs stop showing up as audio outputs), add the following to `/etc/pf.conf` after all `dummynet-anchor` lines but before any `anchor` lines:

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

## License

Do whatever you want with this. Apple certainly does whatever they want with your computer.
