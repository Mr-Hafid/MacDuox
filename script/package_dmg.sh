#!/usr/bin/env bash
set -euo pipefail
if [ "$#" -ne 2 ]; then echo "usage: $0 /path/MacDuox.app /path/output.dmg" >&2; exit 2; fi
APP_BUNDLE="$1"
OUTPUT_DMG="$2"
test -x "$APP_BUNDLE/Contents/MacOS/MacDuox"
test -f "$APP_BUNDLE/Contents/Resources/LICENSE.txt"
DMG_STAGE="$(mktemp -d "${TMPDIR:-/tmp}/macduox-dmg.XXXXXX")"
trap 'rm -rf "$DMG_STAGE"' EXIT
/usr/bin/ditto "$APP_BUNDLE" "$DMG_STAGE/MacDuox.app"
ln -s /Applications "$DMG_STAGE/Applications"
cp "$APP_BUNDLE/Contents/Resources/LICENSE.txt" "$DMG_STAGE/LICENSE.txt"
/usr/bin/hdiutil create -ov -volname 'MacDuox' -srcfolder "$DMG_STAGE" -format UDZO -fs HFS+ "$OUTPUT_DMG"
/usr/bin/hdiutil verify "$OUTPUT_DMG"
