#!/bin/sh
set -e

PATH="/usr/local/bin:$PATH"
TAILSCALED_PID=""
APP_PID=""

cleanup() {
    [ -n "$APP_PID" ] && kill -TERM "$APP_PID" && wait "$APP_PID"
    tailscale --socket="$TS_SOCKET" down
}

trap cleanup EXIT
trap 'trap - EXIT; cleanup; exit 0' INT TERM

mkdir -p "$(dirname "$TS_SOCKET")" "$TS_STATE_DIR"
tailscaled --socket="$TS_SOCKET" --statedir="$TS_STATE_DIR" $TS_TAILSCALED_EXTRA_ARGS &> /dev/null &
TAILSCALED_PID=$!

tailscale --socket="$TS_SOCKET" up --authkey="$TS_AUTHKEY" --hostname="$TS_HOSTNAME" \
    --advertise-routes="$TS_ROUTES" --snat-subnet-routes=false $TS_EXTRA_ARGS
tailscale --socket="$TS_SOCKET" status --peers=false

/sidestore-vpn "$@" &
APP_PID=$!
set +e
wait "$APP_PID"
APP_STATUS=$?
set -e
exit "$APP_STATUS"
