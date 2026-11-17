#!/bin/sh
set -e

echo "=== AVEXA: XCODE CLOUD SETUP ==="

cd "$CI_PRIMARY_REPOSITORY_PATH"

echo "=== Installing Flutter ==="
git clone https://github.com/flutter/flutter.git \
  --depth 1 \
  --branch 3.41.6 \
  "$HOME/flutter"

export PATH="$HOME/flutter/bin:$PATH"

echo "=== Flutter version ==="
flutter --version

echo "=== Preparing iOS artifacts ==="
flutter precache --ios

echo "=== Installing Flutter dependencies ==="
flutter pub get

echo "=== Installing CocoaPods dependencies ==="
cd ios
pod install

echo "=== AVEXA SETUP COMPLETED ==="
