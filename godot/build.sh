#!/bin/sh
# Web export (Godot 4.5.2, Compatibility, no threads -> no COOP/COEP headers needed on Pages).
set -e
GODOT=${GODOT:-godot}
cd "$(dirname "$0")"
mkdir -p ../export/web
"$GODOT" --headless --path . --export-release "Web" ../export/web/index.html
