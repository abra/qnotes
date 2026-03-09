#!/bin/bash

set -e

PASS=0
FAIL=0

run() {
  local label=$1
  local cmd=$2
  local dir=$3

  echo ""
  echo "▶ $label"
  if (cd "$dir" && eval "$cmd" 2>&1); then
    PASS=$((PASS + 1))
  else
    FAIL=$((FAIL + 1))
  fi
}

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

run "shared"                 "dart test test/"                     "$SCRIPT_DIR/packages/shared"
run "notes_repository"       "flutter test test/"                  "$SCRIPT_DIR/packages/notes_repository"
run "preferences_repository" "flutter test test/"                  "$SCRIPT_DIR/packages/preferences_repository"
run "component_library"      "flutter test test/"                  "$SCRIPT_DIR/packages/component_library"
run "monitoring"             "flutter test test/"                  "$SCRIPT_DIR/packages/monitoring"

echo ""
echo "────────────────────────────"
echo "  passed: $PASS  failed: $FAIL"
echo "────────────────────────────"

[ $FAIL -eq 0 ]
