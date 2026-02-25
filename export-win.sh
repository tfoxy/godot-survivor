#!/usr/bin/env bash
# Export Godot project to Windows and zip for distribution.
# Requires: Godot in PATH (or set GODOT=./path/to/Godot).
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Override if Godot is not in PATH
: "${GODOT:=godot}"

PRESET_NAME="Windows"
EXPORT_NAME="godot-survivor"
DIST_DIR="dist"
EXEC_NAME="${EXPORT_NAME}.exe"
ZIP_NAME="${EXPORT_NAME}-windows.zip"

rm -rf "$DIST_DIR"
mkdir -p "$DIST_DIR"


echo "Exporting with preset \"${PRESET_NAME}\" to ${DIST_DIR}/${EXEC_NAME} ..."
"$GODOT" --headless --path . --export-release "$PRESET_NAME" "${DIST_DIR}/${EXEC_NAME}"

echo "Creating ${ZIP_NAME} ..."
cd "$DIST_DIR"
zip -r "../${ZIP_NAME}" . -x "*.zip"
cd ..

echo "Done. Run: ./${DIST_DIR}/${EXEC_NAME}"
echo "Distribute: ${ZIP_NAME}"
