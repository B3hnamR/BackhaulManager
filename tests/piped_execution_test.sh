#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
MANAGER="$SCRIPT_DIR/../backhaul-manager.sh"

[[ -f "$MANAGER" ]] || { echo "manager script not found" >&2; exit 1; }

# A script read from stdin has no BASH_SOURCE[0]. Use a harmless runtime
# command so the interactive menu is never started, then check that nounset
# mode does not turn that condition into an error.
set +e
output=$(cat "$MANAGER" | bash -s -- --watchdog backhaul-piped-regression-test.service 2>&1)
set -e

if [[ "$output" == *"unbound variable"* || "$output" == *"BASH_SOURCE[0]"* ]]; then
    printf 'piped execution regression failed:\n%s\n' "$output" >&2
    exit 1
fi

echo "piped execution regression test: PASS"
