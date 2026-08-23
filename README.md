# BackhaulManager

Modern terminal manager for creating and operating [Backhaul](https://github.com/Musixal/Backhaul) tunnels with a clean interactive workflow.

Join the Telegram channel for updates, notes, and more BackhaulManager content: [@B3hnamR](https://t.me/B3hnamR)

![BackhaulManager showcase](assets/showcase.png)

## Highlights

- Interactive Iran/Kharej role selection with auto-detection
- One-command Backhaul binary install/update flow
- Guided tunnel creation for `tcp`, `tcpmux`, `wsmux`, and `wssmux`
- Preset and advanced tuning modes for production-style configs
- Systemd service generation, start/stop/restart, live logs, and deletion
- Per-tunnel scheduled restart (systemd timer; configure, disable, or delete it in **Manage Tunnels**)
- Per-tunnel health metrics history, adaptive watchdog recovery, and safe restart with connection verification
- Secure Iran/Kharej pair manifests that compare transport settings and a token fingerprint without exposing the token
- Optional Telegram alerts for watchdog warnings, recovery, and restart events
- Config backup/restore and firewall helper for UFW or iptables
- Built-in two-way link test for ping and TCP reachability checks
- WSSMUX TLS certificate generation with OpenSSL

## Requirements

- Linux server with `systemd`
- Root access
- `bash`, `curl` or `wget`, `tar`
- Optional: `ufw`, `iptables`, `openssl`

## Quick Start

```bash
chmod +x backhaul-manager.sh
sudo ./backhaul-manager.sh
```

Use **Install / Update Binary** first if Backhaul is not installed yet, then create a tunnel from the main menu.

## Recommended Setup

For the best default experience, choose **WSSMUX** as the tunnel transport and use **Preset** mode for tuning parameters.

## Typical Workflow

1. Run the script on the Iran server and choose `IRAN`.
2. Create a tunnel and copy the generated transport, port, and token.
3. Run the script on the Kharej server and choose `KHAREJ`.
4. Create the matching tunnel using the Iran server address and the same token.
5. Use **Manage Tunnels** to inspect status, follow logs, view health history, configure metrics/watchdog recovery, restart, edit, delete, or set a scheduled restart interval.

## Notes

- Generated configs are stored in `/etc/backhaul`.
- Services are created as `backhaul-<role>-<transport>-<port>.service`.
- Scheduled restarts run through a paired systemd timer. They restart only an already-running tunnel, so a tunnel stopped manually remains stopped; a schedule can be disabled while retaining its interval or deleted completely.
- **Health & Recovery** can collect a rolling local CSV history (up to 10,000 samples) and run an adaptive watchdog. Peer mode requires at least one established tunnel connection; service mode only checks whether Backhaul is active.
- Pair manifests contain the endpoint, shared transport parameters, and a SHA-256 token fingerprint—never the token itself. Export on Iran and verify on Kharej.
- Telegram alerts require `curl`, a bot token, and a chat ID or channel handle; they are sent only when both global Telegram settings and the tunnel watchdog's alert option are enabled.
- Existing configs are backed up before overwrite/edit/delete operations.
- For WSSMUX, the script can generate a self-signed TLS certificate automatically.

## License

No license has been added yet.
