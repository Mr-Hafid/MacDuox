#!/usr/bin/env bash
set -euo pipefail
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_BUNDLE="${1:-$PROJECT_DIR/dist/MacDuox.app}"
if [ ! -x "$APP_BUNDLE/Contents/MacOS/MacDuox" ]; then
  echo "Build MacDuox before repairing its permission." >&2
  exit 1
fi
pkill -x MacDuox >/dev/null 2>&1 || true
/usr/bin/tccutil reset ScreenCapture com.mrhafid.MacDuox
/usr/bin/open -n "$APP_BUNDLE"
echo "Allow MacDuox in Screen Recording settings, then quit and reopen the same app if macOS requests it."
