#!/bin/sh
set -eu
repo_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
check_dir=$(mktemp -d)
trap 'rm -rf "$check_dir"' EXIT HUP INT TERM
swiftc "$repo_dir/EhPanda/App/Tools/LayoutMetrics.swift" \
    "$repo_dir/tests/duo-layout/main.swift" -o "$check_dir/duo-layout-checks"
"$check_dir/duo-layout-checks"
