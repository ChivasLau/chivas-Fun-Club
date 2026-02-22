#!/bin/bash

# 华仔趣玩社 - IPA打包脚本
# 使用方法: ./build_ipa.sh [开发团队ID]

set -e

PROJECT_NAME="华仔趣玩社"
SCHEME="华仔趣玩社"
CONFIGURATION="Release"
BUILD_DIR="build"
ARCHIVE_PATH="$BUILD_DIR/${PROJECT_NAME}.xcarchive"
IPA_OUTPUT_PATH="$BUILD_DIR/ipa"

TEAM_ID="${1:-}"

echo "========================================"
echo "  华仔趣玩社 - IPA 打包脚本"
echo "========================================"
echo ""

if [ ! -d "${PROJECT_NAME}.xcodeproj" ]; then
    echo "❌ 错误: 未找到 ${PROJECT_NAME}.xcodeproj"
    echo "请确保在项目根目录运行此脚本"
    exit 1
fi

if [ -z "$TEAM_ID" ]; then
    echo "⚠️  警告: 未提供开发团队ID"
    echo "请在Xcode中手动签名，或运行: ./build_ipa.sh YOUR_TEAM_ID"
    echo ""
fi

echo "📦 开始清理旧的构建文件..."
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

echo ""
echo "🔨 开始构建 Archive..."
xcodebuild archive \
    -project "${PROJECT_NAME}.xcodeproj" \
    -scheme "$SCHEME" \
    -configuration "$CONFIGURATION" \
    -archivePath "$ARCHIVE_PATH" \
    -destination "generic/platform=iOS" \
    ONLY_ACTIVE_ARCH=NO \
    ${TEAM_ID:+DEVELOPMENT_TEAM=$TEAM_ID} \
    | xcpretty || exit 1

echo ""
echo "📁 创建导出配置..."

cat > "$BUILD_DIR/ExportOptions.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>development</string>
    <key>compileBitcode</key>
    <false/>
    <key>destination</key>
    <string>export</string>
    <key>signingStyle</key>
    <string>automatic</string>
    <key>stripSwiftSymbols</key>
    <true/>
    <key>teamID</key>
    <string>${TEAM_ID}</string>
    <key>thinning</key>
    <string>&lt;none&gt;</string>
</dict>
</plist>
EOF

echo ""
echo "📤 导出 IPA..."
xcodebuild -exportArchive \
    -archivePath "$ARCHIVE_PATH" \
    -exportPath "$IPA_OUTPUT_PATH" \
    -exportOptionsPlist "$BUILD_DIR/ExportOptions.plist" \
    | xcpretty || exit 1

IPA_FILE=$(find "$IPA_OUTPUT_PATH" -name "*.ipa" -type f | head -n 1)

if [ -n "$IPA_FILE" ] && [ -f "$IPA_FILE" ]; then
    echo ""
    echo "========================================"
    echo "✅ 打包成功!"
    echo "========================================"
    echo ""
    echo "📱 IPA 文件位置:"
    echo "   $IPA_FILE"
    echo ""
    echo "📊 文件大小: $(du -h "$IPA_FILE" | cut -f1)"
    echo ""
    echo "🚀 安装方式:"
    echo "   1. 使用 Xcode -> Window -> Devices and Simulators"
    echo "   2. 使用 Apple Configurator 2"
    echo "   3. 使用 AltStore / Sideloadly"
    echo ""
else
    echo "❌ 打包失败: 未找到 IPA 文件"
    exit 1
fi
