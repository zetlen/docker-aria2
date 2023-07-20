#!/bin/bash
REPO_DIR="$(git rev-parse --show-toplevel)"
IMAGE_NAME="$(basename "$REPO_DIR")"
docker build -t "$IMAGE_NAME" "$REPO_DIR"