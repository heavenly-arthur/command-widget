#!/bin/zsh

set -euo pipefail

project_root="${0:A:h:h}"
configuration="${1:-release}"
app_bundle="$project_root/build/Command Widget.app"
executable_path="$project_root/.build/$configuration/CommandWidget"

if [[ -d /Applications/Xcode.app/Contents/Developer ]]; then
    export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
fi

export CLANG_MODULE_CACHE_PATH="$project_root/.build/module-cache"

/usr/bin/xcrun swift build \
    --disable-sandbox \
    --cache-path "$project_root/.build/swiftpm-cache" \
    -c "$configuration" \
    --package-path "$project_root"

mkdir -p "$app_bundle/Contents/MacOS"
cp "$executable_path" "$app_bundle/Contents/MacOS/CommandWidget"
cp "$project_root/App/Info.plist" "$app_bundle/Contents/Info.plist"
codesign --force --deep --sign - "$app_bundle"

echo "$app_bundle"
