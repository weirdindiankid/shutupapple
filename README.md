# shutupapple

I wanted to have audio routed through my Airpods. Apple routed it through my neighbour's AppleTV somehow. This was with WiFi turned off. So I turned off Bluetooth and WiFi. I saw my neighbour's AppleTV still listed. Hence `shutupapple`.

This is a toggleable script that blocks Apple telemetry, analytics, AirPlay discovery, push notifications, and every other phone-home process that Apple forces onto your Mac without your consent. Works on any Mac running macOS 10.15+.

## Bird's-eye View

- Sinkholes 34+ known Apple telemetry/analytics/tracking/ads/push domains via `/etc/hosts`
- Kills 26+ known Apple processes on sight that do not meaningfully impact user experience
- Disables those daemons across reboots via `launchctl disable`
- Nuclear mode: **allowlist-based** -- kills ANY process connecting to Apple (17.0.0.0/8) unless you've explicitly allowed it. No more whack-a-mole when Apple adds new telemetry in updates.
- Interactive scanner that finds processes talking to Apple and lets you allow or block each one
- Fully reversible with a single command

## Install

```bash
git clone git@github.com:weirdindiankid/shutupapple.git
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

# Scan for any process talking to Apple and decide what to do
# (catches new stuff Apple adds in updates)
sudo apple-block scan

# Check what's blocked and if anything is still phoning home
sudo apple-block status

# Show your allow/block lists with descriptions
sudo apple-block list

# Restore everything (if Apple breaks something you need)
sudo apple-block off

# Reset allow/block lists to defaults
sudo apple-block reset
```

### The scan command

Run `sudo apple-block scan` after macOS updates or whenever you suspect new processes are phoning home. It finds every process with an active connection to Apple's IP range (17.0.0.0/8) and shows you what each one does:

```
Found 2 process(es) talking to Apple:

  1. softwareupdated -> 17.253.18.42:443
     Software Updates -- downloads macOS and security updates
     [a]llow  [b]lock  [s]kip  [?]explain >

  2. analyticsd -> 17.249.60.11:443 [BLOCKED]
     TELEMETRY -- sends device analytics/diagnostics to Apple

```

Your choices are saved to `/usr/local/etc/shutupapple/` and persist across runs. The `nuclear` and `on` commands read from this blocklist, so new processes you block via `scan` get picked up automatically.

## Uninstall

```bash
sudo ./uninstall.sh
```

Or manually:

```bash
sudo apple-block off
sudo rm /usr/local/bin/apple-block
sudo rm /usr/local/bin/kill-airplay.sh
sudo rm -rf /usr/local/etc/shutupapple
sudo launchctl unload /Library/LaunchDaemons/com.shutupapple.kill-apple.plist
sudo rm /Library/LaunchDaemons/com.shutupapple.kill-apple.plist
```

## Optional: OpenWrt router-level block

Block Apple telemetry for every device on your network via dnsmasq on OpenWrt.

```bash
# Copy files to your router
ssh root@192.168.8.1 'cat > /etc/shutupapple.conf' < openwrt-shutupapple.conf
ssh root@192.168.8.1 'cat > /usr/bin/apple-block-router && chmod +x /usr/bin/apple-block-router' < apple-block-router

# Persist across reboots (add to rc.local before the "exit 0" line)
ssh root@192.168.8.1 'echo "[ -f /etc/shutupapple.conf ] && cp /etc/shutupapple.conf /tmp/dnsmasq.d/shutupapple" >> /etc/rc.local'

# Toggle
ssh root@192.168.8.1 'apple-block-router on'      # block all devices
ssh root@192.168.8.1 'apple-block-router off'     # restore
ssh root@192.168.8.1 'apple-block-router status'  # check
```

## Optional: pf firewall rules for AirPlay

If you want to block AirPlay device discovery at the network level (so your neighbors' Apple TVs stop showing up as audio outputs), add the following to `/etc/pf.conf` after all `dummynet-anchor` lines but before any `anchor` lines.

First, allow local traffic on AirPlay ports so dev servers and Docker still work:

```
pass out quick proto tcp to 127.0.0.0/8 port 7000
pass out quick proto tcp to 127.0.0.0/8 port 7100
pass out quick proto tcp to 192.168.0.0/16 port 7000
pass out quick proto tcp to 192.168.0.0/16 port 7100
pass out quick proto tcp to 10.0.0.0/8 port 7000
pass out quick proto tcp to 10.0.0.0/8 port 7100
pass out quick proto tcp to 172.16.0.0/12 port 7000
pass out quick proto tcp to 172.16.0.0/12 port 7100
```

Then block AirPlay on physical/wireless interfaces. Rules are scoped to `en0`, `awdl0`, and `llw0` so VPN tunnel traffic (`utun*`) is not affected -- without this scoping, Mullvad and other VPN clients will experience intermittent disconnections during tunnel renegotiation:

```
block drop out quick on en0 proto udp to 224.0.0.251 port 5353
block drop in quick on en0 proto udp from 224.0.0.251 port 5353
block drop out quick on awdl0 proto udp to 224.0.0.251 port 5353
block drop in quick on awdl0 proto udp from 224.0.0.251 port 5353
block drop out quick on llw0 proto udp to 224.0.0.251 port 5353
block drop in quick on llw0 proto udp from 224.0.0.251 port 5353
block drop out quick on en0 proto tcp to any port 7000
block drop out quick on en0 proto tcp to any port 7100
block drop out quick on en0 proto udp to any port 7000
block drop out quick on en0 proto udp to any port 7011
block drop out quick on awdl0 proto tcp to any port 7000
block drop out quick on awdl0 proto tcp to any port 7100
block drop out quick on awdl0 proto udp to any port 7000
block drop out quick on awdl0 proto udp to any port 7011
block drop out quick on llw0 proto tcp to any port 7000
block drop out quick on llw0 proto tcp to any port 7100
block drop out quick on llw0 proto udp to any port 7000
block drop out quick on llw0 proto udp to any port 7011
```

Then reload with `sudo pfctl -f /etc/pf.conf`.

Note: blocking mDNS multicast (224.0.0.251:5353) also disables Bonjour printer discovery. Add your printer by IP address instead.

## License

AGPL v3. See [LICENSE](LICENSE).

Do whatever you want with this. Apple certainly does whatever they want with your computer.
