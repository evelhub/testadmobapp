#!/bin/bash
# Script to build iOS plugins for Godot 4.4.1
# Run this on Mac with Xcode installed or in GitHub Actions

set -e

echo "🔨 Building Yandex Ads and VK Ads iOS plugins..."

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGINS_DIR="$SCRIPT_DIR/plugins"
BUILD_DIR="$SCRIPT_DIR/build"

echo -e "${YELLOW}📁 Plugins directory: $PLUGINS_DIR${NC}"
echo -e "${YELLOW}📁 Build directory: $BUILD_DIR${NC}"

# Clean build directory
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

# Check if Yandex SDK is available
YANDEX_SDK_PATH="$PLUGINS_DIR/yandex_ads/YandexMobileAds.xcframework"
if [ ! -d "$YANDEX_SDK_PATH" ]; then
    echo -e "${YELLOW}⚠️  Yandex SDK not found at $YANDEX_SDK_PATH${NC}"
    echo "   Compilation will proceed but may fail if SDK headers are needed"
fi

# Function to build a plugin
build_plugin() {
    local PLUGIN_NAME=$1
    local SOURCE_FILE=$2
    
    echo -e "\n${YELLOW}🔨 Building $PLUGIN_NAME...${NC}"
    
    local PLUGIN_DIR="$PLUGINS_DIR/$PLUGIN_NAME"
    local BUILD_PLUGIN_DIR="$BUILD_DIR/$PLUGIN_NAME"
    
    mkdir -p "$BUILD_PLUGIN_DIR"
    
    # Additional framework paths
    local FRAMEWORK_PATHS=""
    if [ "$PLUGIN_NAME" = "yandex_ads" ] && [ -d "$YANDEX_SDK_PATH" ]; then
        FRAMEWORK_PATHS="-F$PLUGINS_DIR/yandex_ads"
    fi
    
    # Build for device (arm64)
    echo "  📱 Building for iOS device (arm64)..."
    xcrun clang++ \
        -x objective-c++ \
        -std=c++17 \
        -arch arm64 \
        -isysroot $(xcrun --sdk iphoneos --show-sdk-path) \
        -mios-version-min=13.0 \
        -fembed-bitcode-marker \
        -c "$PLUGIN_DIR/$SOURCE_FILE" \
        -o "$BUILD_PLUGIN_DIR/${PLUGIN_NAME}_device.o" \
        -F$(xcrun --sdk iphoneos --show-sdk-path)/System/Library/Frameworks \
        $FRAMEWORK_PATHS \
        -fobjc-arc \
        -fmodules \
        -Wno-error || {
            echo -e "${RED}❌ Device build failed${NC}"
            return 1
        }
    
    ar rcs "$BUILD_PLUGIN_DIR/lib${PLUGIN_NAME}_device.a" "$BUILD_PLUGIN_DIR/${PLUGIN_NAME}_device.o"
    
    # Build for simulator (arm64 + x86_64)
    echo "  🖥️  Building for iOS simulator (arm64 + x86_64)..."
    xcrun clang++ \
        -x objective-c++ \
        -std=c++17 \
        -arch arm64 -arch x86_64 \
        -isysroot $(xcrun --sdk iphonesimulator --show-sdk-path) \
        -mios-simulator-version-min=13.0 \
        -c "$PLUGIN_DIR/$SOURCE_FILE" \
        -o "$BUILD_PLUGIN_DIR/${PLUGIN_NAME}_simulator.o" \
        -F$(xcrun --sdk iphonesimulator --show-sdk-path)/System/Library/Frameworks \
        $FRAMEWORK_PATHS \
        -fobjc-arc \
        -fmodules \
        -Wno-error || {
            echo -e "${RED}❌ Simulator build failed${NC}"
            return 1
        }
    
    ar rcs "$BUILD_PLUGIN_DIR/lib${PLUGIN_NAME}_simulator.a" "$BUILD_PLUGIN_DIR/${PLUGIN_NAME}_simulator.o"
    
    # Create XCFramework
    echo "  📦 Creating XCFramework..."
    xcodebuild -create-xcframework \
        -library "$BUILD_PLUGIN_DIR/lib${PLUGIN_NAME}_device.a" \
        -library "$BUILD_PLUGIN_DIR/lib${PLUGIN_NAME}_simulator.a" \
        -output "$PLUGIN_DIR/${PLUGIN_NAME}.xcframework" || {
            echo -e "${RED}❌ XCFramework creation failed${NC}"
            return 1
        }
    
    echo -e "${GREEN}✅ $PLUGIN_NAME built successfully!${NC}"
    
    # Show framework structure
    echo "  📂 Framework structure:"
    ls -la "$PLUGIN_DIR/${PLUGIN_NAME}.xcframework"
}

# Build Yandex Ads plugin
if [ -f "$PLUGINS_DIR/yandex_ads/yandex_ads.mm" ]; then
    build_plugin "yandex_ads" "yandex_ads.mm"
else
    echo -e "${RED}❌ yandex_ads.mm not found${NC}"
    exit 1
fi

# Build VK Ads plugin (optional)
if [ -f "$PLUGINS_DIR/vk_ads/vk_ads.mm" ]; then
    build_plugin "vk_ads" "vk_ads.mm" || echo -e "${YELLOW}⚠️  VK plugin build failed, continuing...${NC}"
else
    echo -e "${YELLOW}⚠️  vk_ads.mm not found, skipping${NC}"
fi

echo -e "\n${GREEN}🎉 Plugin compilation completed!${NC}"
echo -e "${YELLOW}📝 Next steps:${NC}"
echo "  1. Verify .xcframework files exist"
echo "  2. Godot will use them during export"
echo "  3. Test on device"
