.PHONY: setup generate build release clean dmg help

# Default target
help:
	@echo "FlowTimer Build System"
	@echo ""
	@echo "Usage:"
	@echo "  make setup      - Install dependencies (XcodeGen)"
	@echo "  make generate   - Generate Xcode project from project.yml"
	@echo "  make build      - Build the app (Release)"
	@echo "  make debug      - Build the app (Debug)"
	@echo "  make dmg        - Create DMG installer"
	@echo "  make release    - Build + create DMG"
	@echo "  make clean      - Remove build artifacts"
	@echo "  make open       - Open in Xcode"
	@echo ""

# Install dependencies
setup:
	@echo ">>> Installing dependencies..."
	brew install xcodegen || true
	brew install create-dmg || true
	@echo ">>> Dependencies installed."

# Generate Xcode project
generate:
	@echo ">>> Generating Xcode project..."
	xcodegen generate
	@echo ">>> Done. Open FlowTimer.xcodeproj in Xcode."

# Build (Release)
build: generate
	@echo ">>> Building FlowTimer..."
	xcodebuild \
		-project FlowTimer.xcodeproj \
		-scheme FlowTimer \
		-configuration Release \
		-derivedDataPath build/DerivedData \
		CODE_SIGN_IDENTITY="-" \
		DEVELOPMENT_TEAM="" \
		build
	@mkdir -p build
	@cp -R build/DerivedData/Build/Products/Release/FlowTimer.app build/
	@echo ">>> Build complete: build/FlowTimer.app"

# Build (Debug)
debug: generate
	@echo ">>> Building FlowTimer (Debug)..."
	xcodebuild \
		-project FlowTimer.xcodeproj \
		-scheme FlowTimer \
		-configuration Debug \
		-derivedDataPath build/DerivedData \
		CODE_SIGN_IDENTITY="-" \
		DEVELOPMENT_TEAM="" \
		build
	@mkdir -p build
	@cp -R build/DerivedData/Build/Products/Debug/FlowTimer.app build/
	@echo ">>> Debug build complete: build/FlowTimer.app"

# Create DMG
dmg: build
	@chmod +x Scripts/create-dmg.sh
	@./Scripts/create-dmg.sh

# Full release (build + DMG)
release: dmg
	@echo ">>> Release artifacts ready in build/"

# Clean
clean:
	@echo ">>> Cleaning..."
	@rm -rf build/
	@rm -rf FlowTimer.xcodeproj
	@rm -rf *.xcodeproj
	@echo ">>> Clean."

# Open in Xcode
open: generate
	@open FlowTimer.xcodeproj
