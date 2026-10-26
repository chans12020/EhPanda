#!/bin/sh
# Package a successfully compiled iPhoneOS archive; never substitute simulator binaries.
set -eu
repo_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
archive_path=${1:-"$repo_dir/build/EhPanda-Duo.xcarchive"}
ipa_path=${2:-"$repo_dir/build/EhPanda-Duo-unsigned.ipa"}
app_path="$archive_path/Products/Applications/EhPanda.app"

if [ ! -d "$app_path" ]; then
    echo "Missing compiled app: $app_path. Build a device archive first." >&2
    exit 1
fi
platform=$(/usr/libexec/PlistBuddy -c 'Print :CFBundleSupportedPlatforms:0' "$app_path/Info.plist")
if [ "$platform" != iPhoneOS ]; then
    echo "Cannot package $platform as a device IPA. An iPhoneOS archive is required." >&2
    exit 1
fi
executable=$(/usr/libexec/PlistBuddy -c 'Print :CFBundleExecutable' "$app_path/Info.plist")
xcrun lipo -verify_arch arm64 "$app_path/$executable"

staging_dir=$(mktemp -d)
trap 'rm -rf "$staging_dir"' EXIT HUP INT TERM
mkdir -p "$staging_dir/Payload" "$(dirname -- "$ipa_path")"
ditto "$app_path" "$staging_dir/Payload/EhPanda.app"
ditto -c -k --keepParent "$staging_dir/Payload" "$staging_dir/EhPanda.ipa"
unzip -tq "$staging_dir/EhPanda.ipa"
mv -f "$staging_dir/EhPanda.ipa" "$ipa_path"
printf 'Unsigned IPA for re-signing: %s\n' "$ipa_path"
shasum -a 256 "$ipa_path" > "$ipa_path.sha256"
cat "$ipa_path.sha256"
