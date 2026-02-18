#!/usr/bin/env bash
set -euo pipefail

OUT_DIR="${1:-./debug-artifacts}"
TS="$(date +%Y%m%d-%H%M%S)"
RUN_DIR="${OUT_DIR%/}/quickshell-crash-${TS}"

mkdir -p "$RUN_DIR"

echo "[1/6] Collecting quickshell coredump summary..."
coredumpctl --no-pager --reverse | rg -i quickshell | head -n 20 >"$RUN_DIR/coredumps-summary.txt" || true

echo "[2/6] Collecting latest quickshell coredump details..."
LATEST_ID="$(coredumpctl --no-pager --reverse | rg -i quickshell | head -n 1 | awk '{print $5}')"
if [[ -n "${LATEST_ID:-}" ]]; then
  coredumpctl --no-pager info "$LATEST_ID" >"$RUN_DIR/coredump-latest.txt" || true
else
  echo "No quickshell coredumps found" >"$RUN_DIR/coredump-latest.txt"
fi

echo "[3/6] Collecting latest runtime log directory..."
LATEST_RUNTIME_DIR="$(ls -1dt /run/user/"$(id -u)"/quickshell/by-id/* 2>/dev/null | head -n 1 || true)"
if [[ -n "${LATEST_RUNTIME_DIR:-}" ]]; then
  echo "$LATEST_RUNTIME_DIR" >"$RUN_DIR/runtime-dir.txt"
  cp -a "$LATEST_RUNTIME_DIR" "$RUN_DIR/runtime" || true
else
  echo "No runtime by-id directories found" >"$RUN_DIR/runtime-dir.txt"
fi

echo "[4/6] Collecting journal logs (current boot)..."
journalctl --no-pager -b -t quickshell >"$RUN_DIR/journal-quickshell.txt" || true

echo "[5/6] Collecting environment snapshot..."
{
  echo "timestamp=$(date --iso-8601=seconds)"
  echo "kernel=$(uname -a)"
  echo "session_type=${XDG_SESSION_TYPE:-}"
  echo "wayland_display=${WAYLAND_DISPLAY:-}"
  echo "desktop=${XDG_CURRENT_DESKTOP:-}"
  echo "qt_qpa_platform=${QT_QPA_PLATFORM:-}"
  echo "mesa_loader_driver_override=${MESA_LOADER_DRIVER_OVERRIDE:-}"
} >"$RUN_DIR/env.txt"

echo "[6/6] Collecting git state..."
{
  git rev-parse --short HEAD
  git status --short
} >"$RUN_DIR/git.txt" 2>/dev/null || true

echo
echo "Done. Artifacts written to: $RUN_DIR"
