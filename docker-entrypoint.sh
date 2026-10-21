#!/usr/bin/env bash
set -e

# Optionally install requirements for custom nodes mounted at runtime
# (set AUTO_INSTALL_CUSTOM_NODES=1). Nodes baked in at build time already
# carry the marker and are skipped.
if [ "${AUTO_INSTALL_CUSTOM_NODES:-0}" = "1" ]; then
    for req in /opt/comfyui/custom_nodes/*/requirements.txt; do
        [ -f "$req" ] || continue
        dir="$(dirname "$req")"
        if [ ! -f "$dir/.requirements_installed" ]; then
            /opt/comfyui/venv/bin/pip3 install -r "$req" && touch "$dir/.requirements_installed"
        fi
    done
fi

# CLI_ARGS is intentionally unquoted so a full argument list expands
# into separate arguments, e.g. CLI_ARGS="--listen 0.0.0.0 --port 8188"
exec /opt/comfyui/venv/bin/python3 main.py ${CLI_ARGS} "$@"
