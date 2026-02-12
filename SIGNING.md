# Code Signing and Distribution Guide

## Prerequisites

You need an active Apple Developer Program membership and the following certificates installed:

- **Apple Distribution Certificate** - For distribution builds
- **Apple Development Certificate** - For development builds

## Current Configuration

The project is configured with the following signing settings:

- **Team ID**: U6W8A4Y252
- **Signing Identity**: Apple Distribution
- **Hardened Runtime**: Enabled
- **Code Sign Style**: Manual

## Available Certificates

Your machine has the following valid signing identities:

1. `Apple Distribution: Kaito Fukushima (U6W8A4Y252)` - For distribution
2. `Apple Development: Kaito Fukushima (B8VLTB63PB)` - For development

## Building for Distribution

### 1. Generate Xcode Project

```bash
xcodegen generate
```

### 2. Build the App

```bash
xcodebuild -project FlowTimer.xcodeproj \
  -scheme FlowTimer \
  -configuration Release \
  -archivePath build/FlowTimer.xcarchive \
  archive
```

### 3. Export the Archive

Create an export options plist file (`ExportOptions.plist`):

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>developer-id</string>
    <key>teamID</key>
    <string>U6W8A4Y252</string>
    <key>signingStyle</key>
    <string>manual</string>
    <key>signingCertificate</key>
    <string>Apple Distribution</string>
</dict>
</plist>
```

Then export:

```bash
xcodebuild -exportArchive \
  -archivePath build/FlowTimer.xcarchive \
  -exportPath build/export \
  -exportOptionsPlist ExportOptions.plist
```

## Notarization Process

After building and signing your app, you need to notarize it with Apple:

### 1. Create an App-Specific Password

1. Go to [appleid.apple.com](https://appleid.apple.com)
2. Sign in with your Apple ID
3. Navigate to "Security" > "App-Specific Passwords"
4. Generate a new password for notarization
5. Save this password securely

### 2. Store Credentials in Keychain

```bash
xcrun notarytool store-credentials "flowtimer-notarization" \
  --apple-id "your-apple-id@email.com" \
  --team-id "U6W8A4Y252" \
  --password "your-app-specific-password"
```

### 3. Create a ZIP Archive

```bash
cd build/export
ditto -c -k --keepParent FlowTimer.app FlowTimer.zip
```

### 4. Submit for Notarization

```bash
xcrun notarytool submit FlowTimer.zip \
  --keychain-profile "flowtimer-notarization" \
  --wait
```

The `--wait` flag will monitor the submission and display the result.

### 5. Check Notarization Status

If you need to check status later:

```bash
xcrun notarytool info <submission-id> \
  --keychain-profile "flowtimer-notarization"
```

### 6. Staple the Notarization Ticket

Once notarization succeeds:

```bash
xcrun stapler staple FlowTimer.app
```

### 7. Verify Notarization

```bash
xcrun stapler validate FlowTimer.app
spctl -a -vv FlowTimer.app
```

## Distribution

After successful notarization, you can:

1. **Create a DMG** for distribution
2. **Compress the app** and distribute as ZIP
3. **Upload to your website** or distribution platform

### Creating a DMG (Optional)

```bash
hdiutil create -volname "FlowTimer" \
  -srcfolder build/export/FlowTimer.app \
  -ov -format UDZO \
  FlowTimer.dmg
```

## Troubleshooting

### Signing Issues

- Verify certificates are installed: `security find-identity -v -p codesigning`
- Check certificate validity in Keychain Access
- Ensure your Apple Developer account is active

### Notarization Issues

- Check notarization log: `xcrun notarytool log <submission-id> --keychain-profile "flowtimer-notarization"`
- Common issues include:
  - Missing or invalid hardened runtime
  - Incorrect entitlements
  - Unsigned embedded frameworks or plugins

### Verification Commands

```bash
# Check app signature
codesign -vvv --deep --strict FlowTimer.app

# Check entitlements
codesign -d --entitlements - FlowTimer.app

# Check hardened runtime
codesign -d --verbose=4 FlowTimer.app | grep runtime
```

## Additional Resources

- [Apple Notarization Documentation](https://developer.apple.com/documentation/security/notarizing_macos_software_before_distribution)
- [Code Signing Guide](https://developer.apple.com/documentation/xcode/code-signing)
- [Hardened Runtime](https://developer.apple.com/documentation/security/hardened_runtime)
