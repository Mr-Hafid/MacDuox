# MacDuox

Your desktop holds its angle while the lid moves, and blurs progressively as it folds.

MacDuox is a menu bar app for macOS. It reads the MacBook hinge angle from the built-in sensor, captures the desktop live, and re-renders it with Metal so windows and wallpaper appear to stay fixed in space while the lid tilts. Your apps stay clickable and keep keyboard focus throughout.

## Requirements

- Apple silicon MacBook. The binary is `arm64` only and will not run on Intel Macs.
- macOS 26.1 or newer.
- A readable lid angle sensor. **Support varies by model, and Apple silicon alone does not guarantee it.** The sensor first appeared in the MacBook Pro 16" (2019) and became standard in the 14"/16" M1 Pro/Max (2021) onward. A MacBook Pro 13" M1 (MacBookPro17,1), for example, does not have one.
- Screen Recording permission, so the desktop can be captured.

No sensor? **Simulate a Fold** in the menu drives the effect from a synthetic angle, so you can still see and tune it.

## Install

Current builds are ad-hoc signed and **not notarized**, so macOS will not open them on the first try.

1. Open `MacDuox-<version>-arm64.dmg` and drag **MacDuox.app** into **Applications**.
2. Eject the disk image, then **right-click the installed app → Open** and confirm. If macOS still refuses, allow it in **System Settings → Privacy & Security → Open Anyway**.
3. Look for the **laptop icon in the menu bar**. There is no Dock icon.
4. Click the icon to enable the effect, and allow **Screen Recording** when macOS asks. If it asks you to quit and reopen, reopen the same app from Applications and enable it again.
5. Move the lid gently. Keep the laptop base and your head roughly still for the best illusion. Normal lid-close sleep still applies.

If macOS ever reports malware or that the app will damage your computer, stop. Do not bypass that warning, and do not disable Gatekeeper.

## Controls

| Action | How |
| --- | --- |
| Turn the effect on or off | Click the menu bar icon, or press **⌃⌘L** |
| Open the options menu | Right-click or Control-click the icon |
| Limit the effect to a lid angle | **Use Activation Angle**, then set **Activate at or below** (10–180°) |
| Ignore small hinge movements | **Jitter tolerance** (0–5°, default 2°) |
| Reset the reference angle | **Anchor Here** |
| Settle back when you stop moving | **Auto-anchor When Still**, with **Pause Before Anchoring** |
| Soften the image as it folds | **Progressive Blur** |
| Hold the content angle | **Hold Content Angle** |
| Taper the far edge | **Perspective Taper** |
| Watch the raw angle | **Show Lid Angle in Menu Bar** |
| Preview without a sensor | **Simulate a Fold** |

## Settings window

**MacDuox Settings…** opens a separate window with the Appearance pane: a MacBook preview, an angle slider, the Silk / Shade / Frost style presets, and Perspective, Variable blur and Shadow controls.

The three sliders drive the renderer directly. **Variable blur** scales the progressive blur radius and applies whenever **Progressive Blur** is on. **Shadow** darkens the surface toward its far edge as the angle grows. **Perspective** moves the virtual eye closer or further away, so it only changes the image while **Perspective Taper** is on.

Picking a style loads its preset into the three sliders; moving a slider afterwards keeps your adjusted values. The MacBook preview in the pane is drawn with its own approximation of the fold, so treat it as a guide to the settings rather than a pixel-exact match of the live effect.

## Privacy

Desktop frames are processed on your Mac and held in memory. Nothing is recorded, saved, or uploaded. The app does not use the network, the camera, or the microphone. It reads the hinge angle from the Mac's own sensor and installs no accessibility or input monitoring hooks.

## Build from source

Open `MacDuox.xcodeproj` in Xcode and press **⌘R**. The app is a menu bar agent, so it appears in the menu bar rather than the Dock.

From the command line:

```bash
xcodebuild -project MacDuox.xcodeproj -scheme MacDuox -configuration Debug -destination 'platform=macOS' build
```

Xcode 26 does not ship the Metal toolchain by default. If the build fails with `cannot execute tool 'metal'`, run `xcodebuild -downloadComponent MetalToolchain` once.

Debug builds are signed for local development only and embed debug dylibs. **They will not launch on another Mac.** Use the packaging script below for anything you intend to copy or distribute.

## Packaging

```bash
./script/package_release.sh --experimental
```

Builds Release, ad-hoc signs with the hardened runtime, then writes a ZIP, a DMG and `SHA256SUMS.txt` to `dist/release/`.

```bash
MACDUOX_SIGN_IDENTITY="Developer ID Application: ..." \
MACDUOX_NOTARY_PROFILE=MacDuox \
./script/package_release.sh --notarize
```

Signs with Developer ID, submits to Apple, staples both the app and the disk image, and verifies with `spctl`. Store the notary credentials first with `xcrun notarytool store-credentials`.

`./script/repair_permissions.sh` resets Screen Recording for `com.mrhafid.MacDuox` alone, for when a rebuild invalidates an approval. It never touches other apps' permissions.

## Project layout

| Path | Contents |
| --- | --- |
| `MacDuox/App/` | Entry point and application delegate |
| `MacDuox/Engine/` | Sensor, capture, Metal renderer, menu bar engine |
| `MacDuox/LidAngle/` | Lid angle sources and shared state |
| `MacDuox/Capture/` | Screen Recording permission helper |
| `MacDuox/Render/` | Fold geometry and parameters used by the preview |
| `MacDuox/Settings/` | Settings window and Appearance pane |
| `script/` | Packaging and permission scripts |
