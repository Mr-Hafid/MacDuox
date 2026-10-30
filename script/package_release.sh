#!/usr/bin/env bash
set -euo pipefail
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_DIR"

MODE="${1:---experimental}"
case "$MODE" in
  --experimental|--notarize) ;;
  *) echo "usage: $0 [--experimental|--notarize]" >&2; exit 2 ;;
esac

if [ "$MODE" = --notarize ]; then
  : "${MACDUOX_SIGN_IDENTITY:?Set a Developer ID Application identity}"
  : "${MACDUOX_NOTARY_PROFILE:?Set an existing notarytool keychain profile}"
  case "$MACDUOX_SIGN_IDENTITY" in
    "Developer ID Application:"*) ;;
    *) echo "Notarization requires a Developer ID Application identity." >&2; exit 2 ;;
  esac
fi

BUILD_DIR="$PROJECT_DIR/build/release"
xcodebuild -project MacDuox.xcodeproj -scheme MacDuox -configuration Release \
  -destination 'platform=macOS' -derivedDataPath "$BUILD_DIR" \
  CODE_SIGNING_ALLOWED=NO build

BUILT_APP="$BUILD_DIR/Build/Products/Release/MacDuox.app"
VERSION="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$BUILT_APP/Contents/Info.plist")"
ARCH="$(uname -m)"

RELEASE_DIR="$PROJECT_DIR/dist/release"
APP_BUNDLE="$RELEASE_DIR/MacDuox.app"
ARCHIVE="$RELEASE_DIR/MacDuox-$VERSION-$ARCH.zip"
DISK_IMAGE="$RELEASE_DIR/MacDuox-$VERSION-$ARCH.dmg"

rm -rf "$APP_BUNDLE"
mkdir -p "$RELEASE_DIR"
/usr/bin/ditto "$BUILT_APP" "$APP_BUNDLE"

if [ "$MODE" = --notarize ]; then
  /usr/bin/codesign --force --options runtime --timestamp --sign "$MACDUOX_SIGN_IDENTITY" "$APP_BUNDLE"
else
  /usr/bin/codesign --force --options runtime --sign - --identifier com.mrhafid.MacDuox "$APP_BUNDLE"
fi
/usr/bin/codesign --verify --strict --verbose=2 "$APP_BUNDLE"
/usr/bin/ditto -c -k --sequesterRsrc --keepParent "$APP_BUNDLE" "$ARCHIVE"

if [ "$MODE" = --notarize ]; then
  xcrun notarytool submit "$ARCHIVE" --keychain-profile "$MACDUOX_NOTARY_PROFILE" --wait
  xcrun stapler staple "$APP_BUNDLE"
  xcrun stapler validate "$APP_BUNDLE"
  /usr/sbin/spctl --assess --type execute --verbose=2 "$APP_BUNDLE"
  /usr/bin/ditto -c -k --sequesterRsrc --keepParent "$APP_BUNDLE" "$ARCHIVE"
fi

"$PROJECT_DIR/script/package_dmg.sh" "$APP_BUNDLE" "$DISK_IMAGE"

if [ "$MODE" = --notarize ]; then
  /usr/bin/codesign --timestamp --sign "$MACDUOX_SIGN_IDENTITY" "$DISK_IMAGE"
  xcrun notarytool submit "$DISK_IMAGE" --keychain-profile "$MACDUOX_NOTARY_PROFILE" --wait
  xcrun stapler staple "$DISK_IMAGE"
  xcrun stapler validate "$DISK_IMAGE"
fi

(
  cd "$RELEASE_DIR"
  shasum -a 256 "MacDuox-$VERSION-$ARCH.zip" "MacDuox-$VERSION-$ARCH.dmg" > SHA256SUMS.txt
)

echo "Packaged: $ARCHIVE"
echo "Packaged: $DISK_IMAGE"
if [ "$MODE" = --experimental ]; then
  echo "EXPERIMENTAL: ad-hoc signed, not notarized. Gatekeeper will block downloaded copies."
fi
