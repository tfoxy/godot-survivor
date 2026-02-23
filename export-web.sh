#!/usr/bin/env bash
# Export Godot project to Web (index.html).
# Requires: Godot in PATH (or set GODOT=./path/to/Godot).
# First time: In Godot Editor, Project → Export → Add → Web, set export path to dist-web/index.html.
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Override if Godot is not in PATH (e.g. GODOT=./Godot_v4.2_linux.x86_64)
: "${GODOT:=godot}"

PRESET_NAME="Web"
DIST_DIR="dist-web"
OUT_HTML="index.html"

mkdir -p "$DIST_DIR"

echo "Exporting with preset \"${PRESET_NAME}\" to ${DIST_DIR}/${OUT_HTML} ..."
"$GODOT" --headless --path . --export-release "$PRESET_NAME" "${DIST_DIR}/${OUT_HTML}"

echo "Done. Open: ${DIST_DIR}/${OUT_HTML}"
