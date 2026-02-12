# FlowTimer

**Menu Bar Native Pomodoro for macOS**

A beautiful, minimal Pomodoro timer that lives in your macOS menu bar. Built with SwiftUI and AppKit, featuring a Liquid Glass design, global keyboard shortcuts, and zero disruption to your workflow.

## Features

- **Menu Bar First** — Timer lives in the menu bar. Check time without switching windows
- **Liquid Glass Panel** — Translucent, always-on-top panel with macOS-native glass effect
- **Pomodoro Cycles** — Focus → Short Break → Focus → ... → Long Break, fully customizable
- **Global Shortcuts** — Control the timer from anywhere without opening the panel
- **4 Built-in Presets** — Deep Focus (50min), Standard (25min), Quick Sprint (15min), Creative Flow (45min)
- **Notifications** — Visual, audio, and haptic feedback on session completion
- **Statistics** — Track daily sessions, focus time, streaks, and weekly/monthly trends
- **Data Export** — Export session history as CSV or JSON
- **Bilingual** — English and Japanese localization
- **Lightweight** — < 25MB memory, < 0.1% CPU when collapsed

## Requirements

- macOS 14.0 (Sonoma) or later
- Apple Silicon or Intel Mac
- Xcode 16.0+ (for building from source)

## Installation

### Download DMG

Download the latest `.dmg` from [Releases](../../releases).

1. Open the DMG file
2. Drag **FlowTimer** to your **Applications** folder
3. Launch FlowTimer
4. (First launch) Right-click → Open if prompted about unidentified developer

### Build from Source

```bash
# Clone the repository
git clone https://github.com/maplefukku/FlowTimer.git
cd FlowTimer

# Install dependencies
make setup

# Build and open in Xcode
make open

# Or build from command line
make build

# Create DMG installer
make dmg
```

## Usage

### Menu Bar

Click the FlowTimer icon in the menu bar to open/close the timer panel. The icon shows:

| Display Level | Shows | Width |
|---|---|---|
| Minimal | Icon with progress arc | ~18px |
| Standard | Icon + remaining time | ~80px |
| Full | Icon + time + cycle dots | ~120px |

### Keyboard Shortcuts

| Shortcut | Action | Scope |
|---|---|---|
| `⌘⇧P` | Toggle panel | Global |
| `⌘⇧S` | Start / Stop timer | Global |
| `⌘⇧R` | Reset timer | Global |
| `⌘⇧K` | Skip break | Global |
| `⌘⇧1-4` | Switch preset | Global |
| `Space` | Start / Pause | Panel open |
| `Esc` | Close panel | Panel open |

### Presets

| Preset | Focus | Break | Long Break |
|---|---|---|---|
| Deep Focus | 50 min | 10 min | 30 min |
| Standard | 25 min | 5 min | 15 min |
| Quick Sprint | 15 min | 3 min | 10 min |
| Creative Flow | 45 min | 10 min | 20 min |

## Project Structure

```
FlowTimer/
├── project.yml              # XcodeGen configuration
├── Makefile                  # Build commands
├── FlowTimer/
│   ├── App/                  # App entry point & delegate
│   ├── Core/                 # Timer engine, Pomodoro manager, settings
│   ├── MenuBar/              # NSStatusItem & icon rendering
│   ├── Views/
│   │   ├── Panel/            # Timer panel (ring, controls, stats)
│   │   ├── Settings/         # Settings window tabs
│   │   ├── Onboarding/       # First launch experience
│   │   └── Statistics/       # Statistics dashboard
│   ├── Models/               # Data models
│   ├── Services/             # Notifications, sound, haptics, hotkeys
│   ├── Styles/               # Liquid Glass design system
│   ├── Extensions/           # Swift extensions
│   ├── Localization/         # en + ja strings
│   └── Resources/            # Sounds, assets
├── Scripts/                  # Build & DMG scripts
└── .github/workflows/        # CI/CD
```

## Build System

The project uses [XcodeGen](https://github.com/yonaskolb/XcodeGen) to generate the Xcode project from `project.yml`. This keeps the repository clean and avoids merge conflicts in `.xcodeproj`.

```bash
# Generate Xcode project
make generate

# Full release build with DMG
make release

# Clean all build artifacts
make clean
```

## Release Process

1. Tag a version: `git tag v1.0.0`
2. Push the tag: `git push origin v1.0.0`
3. GitHub Actions automatically builds, creates DMG, and publishes a Release

For manual releases:
```bash
make release
# Output: build/FlowTimer-1.0.0.dmg
```

### Code Signing & Notarization

The automated builds are **unsigned** (ad-hoc signed). For distribution:

1. Set your Developer ID in Xcode or pass `--sign "Developer ID Application: Your Name"` to the build script
2. Notarize with: `xcrun notarytool submit build/FlowTimer-1.0.0.dmg --apple-id YOUR_ID --team-id YOUR_TEAM`
3. Staple: `xcrun stapler staple build/FlowTimer-1.0.0.dmg`

## Tech Stack

| Layer | Technology |
|---|---|
| UI | SwiftUI + AppKit (hybrid) |
| Menu Bar | NSStatusItem + NSPopover |
| Data | JSON file persistence |
| Charts | Swift Charts |
| Audio | AVFoundation |
| Haptics | NSHapticFeedbackManager |
| Shortcuts | Carbon Hot Key API |
| Build | XcodeGen + xcodebuild |
| CI/CD | GitHub Actions |

## License

MIT License. See [LICENSE](LICENSE) for details.
