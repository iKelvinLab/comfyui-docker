# ComfyUI image with custom nodes, built on top of the base image.
# Repos are listed one per line in the custom_nodes file.
#
# Build the base image first, then:
#   docker build --platform linux/amd64 -f custom-nodes.dockerfile \
#     --build-arg BASE_IMAGE=comfyui:v0.39.0-cu130 \
#     -t comfyui:v0.39.0-cu130-custom .

ARG BASE_IMAGE=comfyui:v0.39.0-cu130
FROM ${BASE_IMAGE}

# Optional pip mirror for local builds, e.g.
#   --build-arg PIP_INDEX_URL=https://pypi.tuna.tsinghua.edu.cn/simple
# Empty (default) uses the standard PyPI index.
ARG PIP_INDEX_URL=""
ENV PIP_INDEX_URL=${PIP_INDEX_URL}

COPY custom_nodes /tmp/custom_nodes

RUN set -eux; \
    while IFS= read -r repo || [ -n "$repo" ]; do \
        repo="$(printf '%s' "$repo" | tr -d '[:space:]')"; \
        case "$repo" in ''|'#'*) continue;; esac; \
        url="${repo%%#*}"; \
        ref="${repo#*#}"; \
        dir="/opt/comfyui/custom_nodes/$(basename "$url" .git)"; \
        if [ "$ref" = "$url" ]; then \
            git clone --depth 1 "$url" "$dir"; \
        else \
            git clone --depth 1 --branch "$ref" "$url" "$dir"; \
        fi; \
        if [ -f "$dir/requirements.txt" ]; then \
            /opt/comfyui/venv/bin/pip3 install -r "$dir/requirements.txt"; \
        fi; \
        touch "$dir/.requirements_installed"; \
    done < /tmp/custom_nodes; \
    rm /tmp/custom_nodes
