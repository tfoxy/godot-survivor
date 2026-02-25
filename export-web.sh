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
EXPORT_NAME="godot-survivor"
DIST_DIR="dist"
OUT_HTML="index.html"
ZIP_NAME="${EXPORT_NAME}-web.zip"

rm -rf "$DIST_DIR"
mkdir -p "$DIST_DIR"


echo "Exporting with preset \"${PRESET_NAME}\" to ${DIST_DIR}/${OUT_HTML} ..."
"$GODOT" --headless --path . --export-release "$PRESET_NAME" "${DIST_DIR}/${OUT_HTML}"

echo "Creating ${ZIP_NAME} ..."
cd "$DIST_DIR"
zip -r "../${ZIP_NAME}" . -x "*.zip"
cd ..

echo "Done. Open: ${DIST_DIR}/${OUT_HTML}"
echo "Distribute: ${ZIP_NAME}"

