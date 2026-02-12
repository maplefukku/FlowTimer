#!/bin/bash
set -euo pipefail

# FlowTimer Build Script
# Usage: ./Scripts/build.sh [--release|--debug] [--sign IDENTITY]

CONFIGURATION="Release"
CODE_SIGN_IDENTITY="-"
DERIVED_DATA="build/DerivedData"
BUILD_DIR="build"
ARCHIVE_PATH="build/FlowTimer.xcarchive"

while [[ $# -gt 0 ]]; do
    case $1 in
        --debug)
            CONFIGURATION="Debug"
            shift
            ;;
        --release)
            CONFIGURATION="Release"
            shift
            ;;
        --sign)
            CODE_SIGN_IDENTITY="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

echo "=== FlowTimer Build ==="
echo "Configuration: ${CONFIGURATION}"
echo ""

# Step 1: Generate Xcode project if needed
if [ ! -d "FlowTimer.xcodeproj" ]; then
    echo ">>> Generating Xcode project with XcodeGen..."
    if ! command -v xcodegen &> /dev/null; then
        echo "XcodeGen not found. Installing via Homebrew..."
        brew install xcodegen
    fi
    xcodegen generate
    echo ">>> Xcode project generated."
fi

# Step 2: Build
echo ">>> Building FlowTimer (${CONFIGURATION})..."
xcodebuild \
    -project FlowTimer.xcodeproj \
    -scheme FlowTimer \
    -configuration "${CONFIGURATION}" \
    -derivedDataPath "${DERIVED_DATA}" \
    CODE_SIGN_IDENTITY="${CODE_SIGN_IDENTITY}" \
    DEVELOPMENT_TEAM="" \
    clean build

# Step 3: Copy app bundle
APP_PATH="${DERIVED_DATA}/Build/Products/${CONFIGURATION}/FlowTimer.app"
if [ ! -d "${APP_PATH}" ]; then
    echo "ERROR: Build succeeded but app not found at ${APP_PATH}"
    exit 1
fi

mkdir -p "${BUILD_DIR}"
rm -rf "${BUILD_DIR}/FlowTimer.app"
cp -R "${APP_PATH}" "${BUILD_DIR}/FlowTimer.app"

echo ""
echo "=== Build Complete ==="
echo "App: ${BUILD_DIR}/FlowTimer.app"
echo ""
