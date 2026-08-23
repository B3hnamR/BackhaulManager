#!/usr/bin/env bash

# Unit checks for local metrics, adaptive watchdog, and generated systemd units.
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/backhaul-manager.sh"

test_root=$(mktemp -d)
trap 'rm -rf "$test_root"' EXIT

INSTALL_DIR="$test_root/backhaul"
SERVICE_DIR="$test_root/units"
METRICS_DIR="$INSTALL_DIR/metrics"
HEALTH_DIR="$INSTALL_DIR/health"
PAIR_DIR="$INSTALL_DIR/pairs"
NOTIFY_FILE="$INSTALL_DIR/telegram-notify.conf"
MANAGER_RUNTIME="$INSTALL_DIR/backhaul-manager-runtime.sh"
mkdir -p "$INSTALL_DIR" "$SERVICE_DIR"

printf '%s\n' \
    '[server]' \
    'bind_addr = "0.0.0.0:9743"' \
    'transport = "wssmux"' \
    'token = "test-token"' \
    'keepalive_period = 75' \
    'nodelay = true' \
    'mux_version = 1' \
    'mux_framesize = 32768' \
    'mux_recievebuffer = 4194304' \
    'mux_streambuffer = 65536' \
    > "$INSTALL_DIR/iran-wssmux-9743.toml"

test_connections=1
target_restart_count=0
test_pid=$$

systemctl() {
    case "$1" in
        is-active) [[ "$test_connections" -ge 0 ]] ;;
        is-enabled) return 0 ;;
        show)
            case "$2" in
                -p)
                    case "$3" in
                        MainPID) echo "$test_pid" ;;
                        NRestarts) echo 0 ;;
                        *) echo '' ;;
                    esac
                    ;;
                *) return 0 ;;
            esac
            ;;
        restart)
            [[ "$2" == 'backhaul-iran-wssmux-9743.service' ]] && target_restart_count=$(( target_restart_count + 1 ))
            return 0
            ;;
        daemon-reload|enable|disable) return 0 ;;
        cat) return 1 ;;
        *) return 0 ;;
    esac
}

ps() {
    case "$*" in
        *'%cpu='*) echo '1.5' ;;
        *'rss='*) echo '2048' ;;
        *) return 0 ;;
    esac
}

ss() {
    case "$*" in
        *'state established'*)
            if [[ "$test_connections" -gt 0 ]]; then
                printf '%s\n' 'ESTAB 0 0 10.0.0.1:9743 10.0.0.2:45000'
            fi
            ;;
        *'-ltn'*) printf '%s\n' 'LISTEN 0 4096 0.0.0.0:9743 0.0.0.0:*' ;;
        *) return 0 ;;
    esac
}

snapshot=$(get_tunnel_snapshot 'backhaul-iran-wssmux-9743.service')
[[ "$snapshot" == *,active,"$test_pid",1.5,2048,0,1,0,0 ]]
[[ "$(get_tunnel_token_hash 'backhaul-iran-wssmux-9743.service')" =~ ^[a-f0-9]{64}$ ]]
is_valid_watchdog_threshold 60
! is_valid_watchdog_threshold 61
is_valid_queue_threshold 2147483647
! is_valid_queue_threshold 2147483648

pair_file="$test_root/iran.pair"
printf '%s\n' 'format=1' 'role=iran' 'endpoint=10.0.0.1' 'transport=wssmux' > "$pair_file"
[[ "$(get_manifest_value "$pair_file" endpoint)" == '10.0.0.1' ]]

collect_tunnel_metrics 'backhaul-iran-wssmux-9743.service'
metrics_file=$(metrics_file_path 'backhaul-iran-wssmux-9743.service')
[[ -f "$metrics_file" ]]
grep -qx 'timestamp,service,active,pid,cpu_percent,rss_kb,restarts,connections,max_recvq,max_sendq' "$metrics_file"

enable_metrics_collection 'backhaul-iran-wssmux-9743.service' 5
grep -qx 'OnUnitActiveSec=5min' "$SERVICE_DIR/backhaul-iran-wssmux-9743-metrics.timer"
grep -qx "ExecStart=/usr/bin/env bash ${MANAGER_RUNTIME} --collect-metrics backhaul-iran-wssmux-9743.service" \
    "$SERVICE_DIR/backhaul-iran-wssmux-9743-metrics.service"

enable_tunnel_watchdog 'backhaul-iran-wssmux-9743.service' 2 peer 2 0 false
run_tunnel_watchdog 'backhaul-iran-wssmux-9743.service'
[[ "$(read_watchdog_failures 'backhaul-iran-wssmux-9743.service')" == 0 ]]

test_connections=0
run_tunnel_watchdog 'backhaul-iran-wssmux-9743.service'
[[ "$(read_watchdog_failures 'backhaul-iran-wssmux-9743.service')" == 1 ]]
[[ "$target_restart_count" -eq 0 ]]
run_tunnel_watchdog 'backhaul-iran-wssmux-9743.service'
[[ "$target_restart_count" -eq 1 ]]
[[ "$(read_watchdog_failures 'backhaul-iran-wssmux-9743.service')" == 0 ]]

if command -v systemd-analyze >/dev/null 2>&1; then
    systemd-analyze verify \
        "$SERVICE_DIR/backhaul-iran-wssmux-9743-metrics.service" \
        "$SERVICE_DIR/backhaul-iran-wssmux-9743-metrics.timer" \
        "$SERVICE_DIR/backhaul-iran-wssmux-9743-watchdog.service" \
        "$SERVICE_DIR/backhaul-iran-wssmux-9743-watchdog.timer"
fi

delete_tunnel_health_artifacts 'backhaul-iran-wssmux-9743.service'
[[ ! -e "$SERVICE_DIR/backhaul-iran-wssmux-9743-metrics.timer" ]]
[[ ! -e "$SERVICE_DIR/backhaul-iran-wssmux-9743-watchdog.timer" ]]

echo 'health feature tests: PASS'
