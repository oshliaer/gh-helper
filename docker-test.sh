#!/bin/bash
# Build the test image and run test-install.sh inside Docker.
# Requires: docker, gh (authenticated)
#
# Usage: bash docker-test.sh

set -euo pipefail

IMAGE="gh-helper-test"
REPO_ROOT=$(git rev-parse --show-toplevel)
GH_TOKEN=$(gh auth token 2>/dev/null || true)

if [[ -z "$GH_TOKEN" ]]; then
  echo "Error: gh is not authenticated. Run: gh auth login" >&2
  exit 1
fi

echo "Building test image..."
docker build -f Dockerfile.test -t "$IMAGE" . -q

echo "Running tests..."
# Mount as /root/gh-helper so gh extension install uses the correct name
docker run --rm \
  -v "$REPO_ROOT:/root/gh-helper" \
  -e GH_TOKEN="$GH_TOKEN" \
  "$IMAGE"
