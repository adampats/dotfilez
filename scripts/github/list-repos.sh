#!/bin/bash

# Requires the gh command line utility to be installed and authenticated

function get_org_repos() {
    local org=$1
    local timestamp=$(date +"%Y%m%d-%H%M%S")
    local output_file="${org}_repos_${timestamp}.csv"
    
    echo "Fetching repositories for organization: $org"
    
    # See https://cli.github.com/manual/gh_repo_list for list of available fields
    (
        echo 'name,owner,primaryLanguage,isArchived,diskUsage,updatedAt,pushedAt,description' && \
        gh repo list "$org" \
            --json name,owner,primaryLanguage,isArchived,diskUsage,updatedAt,pushedAt,description \
            --limit 1000 | \
        jq -r '.[] | [.name, .owner.login, .primaryLanguage.name, .isArchived, .diskUsage, .updatedAt, .pushedAt, .description] | @csv'
    ) > "$output_file"
    
    echo "Repository data saved to: $output_file"
}

# main
if [ $# -eq 0 ]; then
    echo "Usage: $0 org1 [org2 org3 ...]"
    echo "Example: $0 org1 org2"
    exit 1
fi

for org in "$@"; do
    get_org_repos "$org"
done