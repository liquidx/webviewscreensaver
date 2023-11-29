#!/bin/bash
set -u

abort() {
  printf "%s\n" "$@"
  exit 1
}

if [ -z "${BASH_VERSION:-}" ]; then
  abort "Bash is required to interpret this script."
fi

if [[ "$(uname)" != "Darwin" ]]; then
  abort "WebViewScreenSaver is only supported on macOS."
fi

if ! command -v git >/dev/null; then
    abort "Install process requires Git."
fi

if ! command -v xcodebuild >/dev/null; then
    abort "Install process requires Xcode."
fi

GIT_REMOTE="https://github.com/leavez/webviewscreensaver.git"
DIR_NAME="webviewscreensaver"
PRJ_NAME="WebViewScreenSaver"
BUILD_DIR="build"

printf 'Cloning %s...' "$GIT_REMOTE"
cd "$TMPDIR" || exit 1
rm -rf "$DIR_NAME"
git clone -q --depth 1 "$GIT_REMOTE" "$DIR_NAME"
printf ' Done\n'

printf 'Building %s...' "$PRJ_NAME"
cd "$DIR_NAME/$PRJ_NAME" || exit 1
mkdir "$BUILD_DIR"
xcodebuild -project WebViewScreenSaver.xcodeproj \
 -scheme WebViewScreenSaver \
 -configuration Release clean archive \
 -archivePath "$BUILD_DIR/build.xcarchive" \
 CODE_SIGN_IDENTITY="-" CODE_SIGNING_REQUIRED=YES > "$BUILD_DIR/build.log"
printf ' Done\n'

printf 'Installing %s...' "$PRJ_NAME"
cp -pr "$(find "$BUILD_DIR" -iname "*.saver")" "${HOME}/Library/Screen Savers"
printf ' Done\n'

printf 'Cleaning up...'
cd ../../
rm -rf "$DIR_NAME"
printf ' Done\n'
