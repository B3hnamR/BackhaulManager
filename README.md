# BackhaulManager

**BackhaulManager** is an interactive terminal manager for creating, monitoring, and recovering [Backhaul](https://github.com/Musixal/Backhaul) tunnels on Linux servers. It supports Iran (server) and Kharej (client) deployments and manages the generated systemd services for you.

![BackhaulManager showcase](assets/showcase.png)

> Current manager version: **1.3.0** · See the [changelog](CHANGELOG.md) for release notes.

Join the Telegram channel for updates and BackhaulManager news: [@B3hnamR](https://t.me/B3hnamR)

## Features

| Feature | Description |
| --- | --- |
| Interactive setup | Detects or lets you select the Iran/Kharej role and guides you through tunnel creation. |
| Supported transports | Creates `tcp`, `tcpmux`, `wsmux`, and `wssmux` Backhaul tunnels. |
| Production presets | Provides preset and advanced tuning modes for connection pool, mux, keepalive, and transport settings. |
| Service management | Generates systemd services and lets you start, stop, restart, inspect logs, edit, or delete tunnels. |
| Scheduled restart | Enables, changes, disables, or removes a per-tunnel recurring restart schedule. |
| Health watchdog | Checks service state, optional peer connectivity, and TCP queue pressure; restarts a tunnel after configurable consecutive failures. |
| Metrics history | Stores rolling per-tunnel CPU, memory, restart count, connection, and queue metrics in CSV files. |
| Safe restart | Restarts the local tunnel and confirms that the listener or client connection has recovered. |
| Pair verification | Exports an Iran-side manifest and checks Kharej-side settings using a token fingerprint, without exposing the token. |
| Telegram alerts | Sends optional watchdog failure and recovery alerts to a Telegram chat or channel. |
| Utilities | Includes config backup/restore, UFW/iptables helpers, WSSMUX certificate generation, and a two-way connectivity test. |

## Requirements

- A Linux server with `systemd`
- Root or `sudo` access
- `bash`, `curl` or `wget`, and `tar`
- Optional: `ufw`, `iptables`, and `openssl`

## Install and Run

Run this one-line command on each server:

```bash
curl -fsSL https://raw.githubusercontent.com/B3hnamR/BackhaulManager/master/backhaul-manager.sh | sudo bash
```

The command downloads the current script from this repository and opens the interactive manager. Review the script before piping it to `bash` if your server policy requires it.

### Manual Installation

```bash
git clone https://github.com/B3hnamR/BackhaulManager.git
cd BackhaulManager
chmod +x backhaul-manager.sh
sudo ./backhaul-manager.sh
```

## Quick Setup

1. Run the manager on the **Iran server** and select `IRAN`.
2. Choose **Install / Update Binary** if Backhaul is not installed.
3. Create the Iran-side tunnel, then note its transport, port, and token.
4. Run the manager on the **Kharej server**, select `KHAREJ`, and create the matching tunnel with the Iran server address and the same token.
5. Open **Manage Tunnels** to inspect, tune, protect, or restart the created tunnel.

For the usual setup, choose **WSSMUX** and use **Preset** mode. The manager can generate a self-signed TLS certificate when needed.

## Tunnel Management

Each tunnel has a dedicated systemd service named like this:

```text
backhaul-<role>-<transport>-<port>.service
```

From **Manage Tunnels**, you can:

- Start, stop, or restart a tunnel and follow its live logs.
- Edit its configuration or safely delete it.
- Enable a scheduled restart at an interval you choose; disable it while retaining the setting, or delete it entirely.
- Configure metric collection and review the local metric history.
- Configure an adaptive watchdog and choose service-only or peer-aware health checks.
- Use Safe Restart to confirm the tunnel has recovered after restarting.

### Health and Recovery

The watchdog is local to each server. In **peer mode**, a tunnel needs at least one established Backhaul connection; in **service mode**, only the systemd service state is checked. You can set the check interval, failure threshold, optional TCP queue threshold, and whether that tunnel sends Telegram alerts.

For a client-side tunnel, Safe Restart waits for an established Backhaul connection. For a server-side tunnel, it verifies that the listening port returns after the restart. Avoid restarting both ends of a tunnel at the same time.

## Pair Verification

Use **Pair Tools** to export a manifest on Iran and verify it on Kharej. The manifest compares the endpoint, transport, port, relevant shared tuning values, and a SHA-256 fingerprint of the token. The original token is never written into the manifest.

## Telegram Alerts

Open **Telegram Notifications** in the main menu to configure a bot token and chat ID (or channel handle), send a test message, disable alerts, or remove the configuration. Alerts are sent only when both global notifications and the tunnel watchdog's alert setting are enabled.

## Files and Data

| Path | Purpose |
| --- | --- |
| `/etc/backhaul/` | Generated tunnel configurations and manager data. |
| `/etc/backhaul/backups/` | Configuration backups created before overwrite, edit, or deletion. |
| `/etc/backhaul/metrics/` | Rolling local CSV metric history for each tunnel. |
| `/etc/backhaul/health/` | Watchdog configuration and runtime state. |
| `/etc/backhaul/pairs/` | Token-safe pair verification manifests. |
| `/etc/systemd/system/` | Generated tunnel, scheduled restart, metrics, and watchdog units. |

Deleting a tunnel also removes its related scheduled-restart, metrics, and watchdog units and local stored data.

## Security Notes

- Treat the Backhaul token as a secret and use a unique, strong token for every tunnel pair.
- Restrict firewall rules to only the ports your tunnel needs.
- Pair manifests contain a token fingerprint, not the token itself.
- Telegram settings, health state, metrics, and generated manager data use restricted permissions where applicable.

## License

No license has been added yet.
