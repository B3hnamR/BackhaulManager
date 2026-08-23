#!/usr/bin/env bash

# Lightweight unit checks for the scheduled-restart helpers.  No systemd daemon
# is required: systemctl is mocked and all generated unit files stay in mktemp.
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/backhaul-manager.sh"

test_root=$(mktemp -d)
trap 'rm -rf "$test_root"' EXIT
SERVICE_DIR="$test_root/units"
mkdir -p "$SERVICE_DIR"

systemctl() {
    case "$1" in
        daemon-reload) return 0 ;;
        enable)
            [[ "$2" == "backhaul-iran-wssmux-9743-restart.timer" ]]
            ;;
        restart) [[ "$2" == "backhaul-iran-wssmux-9743-restart.timer" ]] ;;
        disable)
            [[ "$2" == "--now" && "$3" == "backhaul-iran-wssmux-9743-restart.timer" ]]
            ;;
        is-enabled) return 0 ;;
        list-unit-files)
            printf '%s\n' \
                'backhaul-iran-wssmux-9743.service enabled' \
                'backhaul-iran-wssmux-9743-restart.service static' \
                'backhaul-iran-wssmux-9743-restart.timer enabled' \
                'not-backhaul.service enabled'
            ;;
        *) return 0 ;;
    esac
}

list_tunnels tunnels
[[ ${#tunnels[@]} -eq 1 ]]
[[ "${tunnels[0]}" == 'backhaul-iran-wssmux-9743.service' ]]
is_tunnel_service_name 'backhaul-kharej-tcp-1.service'
! is_tunnel_service_name 'backhaul-iran-wssmux-9743-restart.service'
is_valid_restart_interval_hours 8760
! is_valid_restart_interval_hours 0
! is_valid_port 080

ADV_KEEPALIVE=75
ADV_NODELAY=true
ADV_SNIFFER=false
ADV_LOG_LEVEL=info
ADV_WEB_PORT=0
ADV_MSS=1360
ADV_SO_RCVBUF=4194304
ADV_SO_SNDBUF=4194304
ADV_HEARTBEAT=40
ADV_CHANNEL_SIZE=4096
ADV_MUX_CON=8
ADV_MUX_VERSION=1
ADV_MUX_FRAMESIZE=32768
ADV_MUX_RECVBUF=4194304
ADV_MUX_STREAMBUF=65536
validate_tuning_parameters iran tcp
ADV_MSS=invalid
! validate_tuning_parameters iran tcp >/dev/null
ADV_MSS=1360

enable_scheduled_restart 'backhaul-iran-wssmux-9743.service' 6
grep -qx 'OnActiveSec=6h' "$SERVICE_DIR/backhaul-iran-wssmux-9743-restart.timer"
grep -qx 'OnUnitActiveSec=6h' "$SERVICE_DIR/backhaul-iran-wssmux-9743-restart.timer"
grep -qx 'ExecStart=/usr/bin/systemctl try-restart backhaul-iran-wssmux-9743.service' \
    "$SERVICE_DIR/backhaul-iran-wssmux-9743-restart.service"
[[ "$(get_scheduled_restart_hours 'backhaul-iran-wssmux-9743.service')" == 6 ]]
if command -v systemd-analyze >/dev/null 2>&1; then
    systemd-analyze verify \
        "$SERVICE_DIR/backhaul-iran-wssmux-9743-restart.service" \
        "$SERVICE_DIR/backhaul-iran-wssmux-9743-restart.timer"
fi

disable_scheduled_restart 'backhaul-iran-wssmux-9743.service'
[[ -e "$SERVICE_DIR/backhaul-iran-wssmux-9743-restart.timer" ]]
[[ -e "$SERVICE_DIR/backhaul-iran-wssmux-9743-restart.service" ]]
[[ "$(get_scheduled_restart_hours 'backhaul-iran-wssmux-9743.service')" == 6 ]]
delete_scheduled_restart 'backhaul-iran-wssmux-9743.service'
[[ ! -e "$SERVICE_DIR/backhaul-iran-wssmux-9743-restart.timer" ]]
[[ ! -e "$SERVICE_DIR/backhaul-iran-wssmux-9743-restart.service" ]]

echo 'scheduled-restart helper tests: PASS'
