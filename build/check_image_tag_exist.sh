#!/bin/bash

# This script checks if a Docker image with a specific tag exists in a remote registry.
# It uses 'docker manifest inspect' which is part of the Docker CLI.
#
# Prerequisites:
# 1. Docker CLI installed.
# 2. You must be logged into the Docker registry if it's private.
#    Use 'docker login <your-registry-url>' (e.g., docker login docker.io for Docker Hub).
#
# Usage: ./check_docker_image.sh <image_name> <tag> <result_path>
# Example: ./check_docker_image.sh myrepo/myimage latest check_result.txt
# Example: ./check_docker_image.sh nginx 1.25.3 check_result.txt

# Check if exactly two arguments (image name, tag and result file path) are provided
if [ "$#" -ne 3 ]; then
  echo "Usage: $0 <image_name> <tag> <result_path>"
  echo "Example: $0 myrepo/myimage latest /workspace/tag_check_result.txt"
  exit 1
fi

# Assign arguments to variables
IMAGE_NAME="$1"
TAG="$2"
RESULT_PATH="$3"
FULL_IMAGE="${IMAGE_NAME}:${TAG}"

echo "Checking for Docker image: ${FULL_IMAGE} in registry..."

# Attempt to inspect the manifest of the image.
# 'docker manifest inspect' will return a non-zero exit code if the manifest
# is not found (i.e., the image/tag does not exist) or if there's an error
# (e.g., authentication failure, network issue).
# We redirect stdout and stderr to /dev/null to keep the output clean,
# as we only care about the exit status.
if docker manifest inspect "${FULL_IMAGE}" >/dev/null 2>&1; then
  echo "1" >"${RESULT_PATH}"
  echo "Image tag exist in registry. Wrote '1' to ${RESULT_PATH}"
else
  echo "0" >"${RESULT_PATH}"
  echo "Image tag does NOT exist in registry. Wrote '0' to ${RESULT_PATH}"
fi
