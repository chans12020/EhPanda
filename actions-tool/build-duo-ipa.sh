#!/bin/sh
# Build an unsigned device IPA for re-signing with a sideloading tool.
set -eu
repo_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
archive_path="$repo_dir/build/EhPanda-Duo.xcarchive"
ipa_path=${1:-"$repo_dir/build/EhPanda-Duo-unsigned.ipa"}

if ! xcodebuild -version >/dev/null 2>&1; then
    echo "Cannot build IPA: full Xcode 27.1+ with the iOS SDK is required; Command Line Tools alone cannot compile iOS apps." >&2
    echo "Install Xcode, then run this script again. Set DEVELOPER_DIR if Xcode is not the selected developer toolchain." >&2
    exit 1
fi

"$repo_dir/actions-tool/build-duo.sh" "$archive_path"
"$repo_dir/actions-tool/package-duo-ipa.sh" "$archive_path" "$ipa_path"
