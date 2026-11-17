#!/bin/sh

set -e

echo "=== Preparing Avexa for Xcode Cloud ==="

cd "$CI_PRIMARY_REPOSITORY_PATH"

echo "=== Installing Flutter ==="
git clone https://github.com/flutter/flutter.git --depth 1 -b stable "$HOME/flutter"

export PATH="$HOME/flutter/bin:$PATH"

echo "=== Preparing iOS Flutter artifacts ==="
flutter precache --ios

echo "=== Installing Flutter dependencies ==="
flutter pub get

echo "=== Installing CocoaPods ==="
HOMEBREW_NO_AUTO_UPDATE=1 brew install cocoapods

echo "=== Installing iOS Pods ==="
cd ios
pod install

echo "=== Avexa environment ready ==="
