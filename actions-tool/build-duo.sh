#!/bin/sh
# Build an unsigned device archive with the native iPhone Duo SDK.
set -eu
repo_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
archive_path=${1:-"$repo_dir/build/EhPanda-Duo.xcarchive"}
sdk_version=$(xcrun --sdk iphoneos --show-sdk-version)
if ! awk -v sdk="$sdk_version" 'BEGIN { split(sdk, v, "."); exit !(v[1] > 27 || (v[1] == 27 && v[2] >= 1)) }'; then
    echo "iPhone Duo builds require Xcode 27.1 or later (iOS SDK 27.1+). Selected SDK: $sdk_version" >&2
    exit 1
fi
xcodebuild archive \
    -project "$repo_dir/EhPanda.xcodeproj" \
    -scheme EhPanda \
    -configuration Release \
    -skipMacroValidation \
    -destination 'generic/platform=iOS' \
    -archivePath "$archive_path" \
    CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO \
    CODE_SIGN_IDENTITY= CODE_SIGN_ENTITLEMENTS= DEVELOPMENT_TEAM= PROVISIONING_PROFILE_SPECIFIER=
printf 'Unsigned archive: %s\n' "$archive_path"
