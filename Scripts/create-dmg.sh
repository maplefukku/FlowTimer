#!/bin/bash
set -euo pipefail

# FlowTimer DMG Creation Script
# Usage: ./Scripts/create-dmg.sh [--app PATH] [--output PATH]

APP_PATH="build/FlowTimer.app"
OUTPUT_DIR="build"
DMG_NAME="FlowTimer"
VOLUME_NAME="FlowTimer"

while [[ $# -gt 0 ]]; do
    case $1 in
        --app)
            APP_PATH="$2"
            shift 2
            ;;
        --output)
            OUTPUT_DIR="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

if [ ! -d "${APP_PATH}" ]; then
    echo "ERROR: App bundle not found at ${APP_PATH}"
    echo "Run ./Scripts/build.sh first."
    exit 1
fi

# Parse version from Info.plist
VERSION=$(defaults read "$(pwd)/${APP_PATH}/Contents/Info" CFBundleShortVersionString 2>/dev/null || echo "1.0.0")
DMG_FILENAME="${DMG_NAME}-${VERSION}.dmg"

echo "=== Creating DMG ==="
echo "App: ${APP_PATH}"
echo "Version: ${VERSION}"
echo ""

mkdir -p "${OUTPUT_DIR}"

# Function: create DMG using hdiutil (always available on macOS)
create_dmg_hdiutil() {
    local TEMP_DIR
    TEMP_DIR=$(mktemp -d)
    local DMG_TEMP="${TEMP_DIR}/${DMG_NAME}"

    mkdir -p "${DMG_TEMP}"
    cp -R "${APP_PATH}" "${DMG_TEMP}/"

    # Create Applications symlink
    ln -s /Applications "${DMG_TEMP}/Applications"

    # Create DMG
    hdiutil create \
        -volname "${VOLUME_NAME}" \
        -srcfolder "${DMG_TEMP}" \
        -ov \
        -format UDZO \
        "${OUTPUT_DIR}/${DMG_FILENAME}"

    rm -rf "${TEMP_DIR}"
}

# Check if create-dmg is available (prettier DMGs)
if command -v create-dmg &> /dev/null; then
    echo ">>> Using create-dmg for enhanced DMG..."

    # Remove existing DMG
    rm -f "${OUTPUT_DIR}/${DMG_FILENAME}"

    create-dmg \
        --volname "${VOLUME_NAME}" \
        --volicon "${APP_PATH}/Contents/Resources/AppIcon.icns" \
        --window-pos 200 120 \
        --window-size 600 400 \
        --icon-size 100 \
        --icon "FlowTimer.app" 150 190 \
        --hide-extension "FlowTimer.app" \
        --app-drop-link 450 190 \
        --no-internet-enable \
        "${OUTPUT_DIR}/${DMG_FILENAME}" \
        "${APP_PATH}" \
        || true  # create-dmg returns non-zero if no icon, which is OK

    # Fallback if create-dmg failed
    if [ ! -f "${OUTPUT_DIR}/${DMG_FILENAME}" ]; then
        echo ">>> create-dmg failed, falling back to hdiutil..."
        create_dmg_hdiutil
    fi
else
    echo ">>> Using hdiutil for DMG creation..."
    create_dmg_hdiutil
fi

echo ""
echo "=== DMG Created ==="
echo "Output: ${OUTPUT_DIR}/${DMG_FILENAME}"
echo ""

# Print file info
ls -lh "${OUTPUT_DIR}/${DMG_FILENAME}"
