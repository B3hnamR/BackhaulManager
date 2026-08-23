# Changelog

All notable changes to Backhaul Manager are documented in this file.

## [1.3.1] - 2026-08-23

### Fixed

- **File-based installer compatibility** — Prevents an unbound `BASH_SOURCE` error when the manager is launched from standard input and provides a clear message when timer features need a script file.

### Changed

- **One-line installation command** — Downloads and installs the manager as `/root/backhaul-manager.sh` before launching it, so runtime timer features can safely copy the script.
- **Deployment guidance** — Documents the recommended Kharej-only scheduled restart policy and Telegram configuration for Iran/Kharej monitoring.

## [1.3.0] - 2026-08-23

### Added

- **Adaptive Health Watchdog** — Monitors tunnel service state, peer connectivity, and optional TCP queue pressure; automatically restarts a tunnel after a configurable number of failed checks.
- **Persistent Metrics History** — Records CPU, memory, restart count, established connections, and TCP queue data in rolling per-tunnel CSV history files.
- **Safe Restart with Health Confirmation** — Restarts a local tunnel and verifies that its listener or client connection has recovered before reporting success.
- **Pair Configuration Verification** — Exports a token-safe server manifest and verifies client-side tunnel settings without exposing the shared token.
- **Telegram Alerts** — Sends optional watchdog recovery and failure notifications to a configured Telegram chat.
- **Scheduled Restart Controls** — Lets users enable, change, disable, or completely remove recurring per-tunnel restart schedules.

### Improved

- **Tunnel Lifecycle Cleanup** — Deleting a tunnel now also removes its scheduled restart, metrics, and watchdog units and stored data.
- **Configuration Validation** — Adds stricter validation for advanced configuration values and avoids irrelevant transport-specific prompts.
- **Helper Unit Filtering** — Keeps generated timer and watchdog services out of the regular tunnel-management list.

### Security

- **Protected Runtime Data** — Stores notification settings, pair manifests, health state, and metrics with restricted file permissions where applicable.
