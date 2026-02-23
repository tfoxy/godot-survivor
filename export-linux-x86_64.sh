#!/usr/bin/env bash
# Export Godot project to Linux x86_64 and zip for distribution.
# Requires: Godot in PATH (or set GODOT=./path/to/Godot).
# First time: In Godot Editor, Project → Export → Add → Linux/X11, set export path to dist/game.x86_64.
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Override if Godot is not in PATH (e.g. GODOT=./Godot_v4.2_linux.x86_64)
: "${GODOT:=godot}"

PRESET_NAME="Linux/X11"
EXPORT_NAME="game"
DIST_DIR="dist"
EXEC_NAME="${EXPORT_NAME}.x86_64"
ZIP_NAME="${EXPORT_NAME}-linux-x86_64.zip"

mkdir -p "$DIST_DIR"

echo "Exporting with preset \"${PRESET_NAME}\" to ${DIST_DIR}/${EXEC_NAME} ..."
"$GODOT" --headless --path . --export-release "$PRESET_NAME" "${DIST_DIR}/${EXEC_NAME}"

echo "Creating ${ZIP_NAME} ..."
cd "$DIST_DIR"
zip -r "../${ZIP_NAME}" . -x "*.zip"
cd ..

echo "Done. Run: ./${DIST_DIR}/${EXEC_NAME}"
echo "Distribute: ${ZIP_NAME}"
