#!/bin/bash

if [ $# -ne 1 ]; then
    echo "Usage: $0 <organization-name>"
    exit 1
fi

ORG_NAME="$1"
OUTPUT_DIR="$ORG_NAME-repos"

mkdir -p "$OUTPUT_DIR"
cd "$OUTPUT_DIR" || exit

echo "Fetching repositories for organization: $ORG_NAME"
gh repo list "$ORG_NAME" --limit 1000 --json nameWithOwner -q '.[].nameWithOwner' | while read -r repo; do
    if [[ -d "${repo##*/}" ]]; then
        echo "Folder already exists: $repo"
    else
        echo "Cloning: $repo"
        gh repo clone "$repo" || echo "Failed to clone: $repo"
    fi
done

echo "Finished cloning repositories to directory: $OUTPUT_DIR"