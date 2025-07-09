#!/bin/bash

# This script checks if a Docker image with a specific tag exists in a remote registry.
# It uses 'docker manifest inspect' which is part of the Docker CLI.
#
# Prerequisites:
# 1. Docker CLI installed.
# 2. You must be logged into the Docker registry if it's private.
#    Use 'docker login <your-registry-url>' (e.g., docker login docker.io for Docker Hub).
#
# Usage: ./check_docker_image.sh <image_name> <tag>
# Example: ./check_docker_image.sh myrepo/myimage latest
# Example: ./check_docker_image.sh nginx 1.25.3

# Check if exactly two arguments (image name and tag) are provided
if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <image_name> <tag>"
  echo "Example: $0 myrepo/myimage latest"
  exit 1
fi

# Assign arguments to variables
IMAGE_NAME="$1"
TAG="$2"
FULL_IMAGE="${IMAGE_NAME}:${TAG}"

echo "Checking for Docker image: ${FULL_IMAGE} in registry..."

# Attempt to inspect the manifest of the image.
# 'docker manifest inspect' will return a non-zero exit code if the manifest
# is not found (i.e., the image/tag does not exist) or if there's an error
# (e.g., authentication failure, network issue).
# We redirect stdout and stderr to /dev/null to keep the output clean,
# as we only care about the exit status.
if docker manifest inspect "${FULL_IMAGE}" >/dev/null 2>&1; then
  echo "SUCCESS: Image '${FULL_IMAGE}' exists in the registry."
  # You can optionally add further actions here, e.g., exit 0
  exit 0
else
  # Check if the error was due to "no such manifest" specifically
  # This is a bit more robust than just checking the exit code,
  # as other errors (like auth) also give non-zero.
  # However, for simplicity and common cases, the exit code check is often sufficient.
  # For a more precise check, you'd capture stderr and parse it.
  # For this script, a general "not found or error" is acceptable.
  echo "FAILURE: Image '${FULL_IMAGE}' does NOT exist in the registry, or there was an error (e.g., authentication required)."
  # You can optionally add further actions here, e.g., exit 1
  exit 1
fi
