#!/bin/bash

# Get the last commit message
# Using `git log -1 --pretty=%B` ensures we get the full commit message body,
# not just the subject line, and avoids issues with newlines.
COMMIT_MESSAGE=$(git log -1 --pretty=%B)

# Define the regex pattern
# The pattern checks for:
# ^cd.* - Starts with "cd" followed by any characters
# ^chore(infra).* - Starts with "chore(infra)" followed by any characters
# ^chore(permission).* - Starts with "chore(permission)" followed by any characters
# The || operator in the user's request implies an OR condition.
# In regex, this is represented by the | character.
PATTERN="^cd.*|^chore(infra).*|^chore(permission).*"

# Check if the commit message matches the pattern
# `grep -E` enables extended regular expressions.
# `grep -q` suppresses output, we only care about the exit status.
if echo "${COMMIT_MESSAGE}" | grep -E -q "${PATTERN}"; then
  # If it matches, write "1" to the file
  echo "1" >/workspace/commit_check.txt
  echo "Commit message matches the pattern. Wrote '1' to /workspace/commit_check.txt"
else
  # If it does not match, write "0" to the file
  echo "0" >/workspace/commit_check.txt
  echo "Commit message does NOT match the pattern. Wrote '0' to /workspace/commit_check.txt"
fi
