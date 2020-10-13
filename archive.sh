#!/bin/bash

set -eu

PRJ_DIR="WebViewScreenSaver"
BUILD_DIR="build"
PKG_DIR="WebViewScreenSaver.saver"
ARTIFACT="WebViewScreenSaver.saver.zip"

pushd "$PRJ_DIR"
xcodebuild -project WebViewScreenSaver.xcodeproj -scheme WebViewScreenSaver -configuration Release clean archive -archivePath "$BUILD_DIR/build.xcarchive" CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO

ln -s "$(find "$BUILD_DIR" -iname "*.saver")" "$PKG_DIR"
rm -f "../$ARTIFACT"
zip -r "../$ARTIFACT" "$PKG_DIR"

rm "$PKG_DIR"
rm -rf "$BUILD_DIR"

popd

