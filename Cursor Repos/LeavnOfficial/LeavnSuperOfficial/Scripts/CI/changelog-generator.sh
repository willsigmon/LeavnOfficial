#!/bin/bash
# Changelog Generator for LeavnSuperOfficial

set -e

# Configuration
OUTPUT_FILE="${1:-CHANGELOG.md}"
REPO_URL="https://github.com/LeavnOfficial/LeavnSuperOfficial"

# Colors
BLUE='\033[0;34m'
GREEN='\033[0;32m'
NC='\033[0m'

# Get the latest tag
LATEST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "")
if [ -z "$LATEST_TAG" ]; then
    echo "No tags found. Generating changelog for all commits."
    COMMIT_RANGE="HEAD"
else
    COMMIT_RANGE="$LATEST_TAG..HEAD"
fi

# Function to categorize commits
categorize_commit() {
    local message="$1"
    if [[ $message =~ ^feat ]]; then
        echo "Features"
    elif [[ $message =~ ^fix ]]; then
        echo "Bug Fixes"
    elif [[ $message =~ ^docs ]]; then
        echo "Documentation"
    elif [[ $message =~ ^style ]]; then
        echo "Styling"
    elif [[ $message =~ ^refactor ]]; then
        echo "Code Refactoring"
    elif [[ $message =~ ^test ]]; then
        echo "Tests"
    elif [[ $message =~ ^chore ]]; then
        echo "Chores"
    elif [[ $message =~ ^perf ]]; then
        echo "Performance"
    elif [[ $message =~ ^build ]]; then
        echo "Build System"
    elif [[ $message =~ ^ci ]]; then
        echo "CI/CD"
    else
        echo "Other"
    fi
}

# Generate changelog header
echo -e "${BLUE}Generating changelog...${NC}"

cat > "$OUTPUT_FILE" << EOF
# Changelog

All notable changes to LeavnSuperOfficial will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

EOF

# Get current version
CURRENT_VERSION=$(git describe --tags --always)
CURRENT_DATE=$(date +"%Y-%m-%d")

echo "## [$CURRENT_VERSION] - $CURRENT_DATE" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

# Collect commits by category
declare -A categories
while IFS= read -r line; do
    commit_hash=$(echo "$line" | cut -d' ' -f1)
    commit_message=$(echo "$line" | cut -d' ' -f2-)
    
    # Skip merge commits
    if [[ $commit_message =~ ^Merge ]]; then
        continue
    fi
    
    category=$(categorize_commit "$commit_message")
    
    # Extract scope if present
    if [[ $commit_message =~ ^[^:]+\(([^)]+)\): ]]; then
        scope="${BASH_REMATCH[1]}"
        clean_message=$(echo "$commit_message" | sed 's/^[^:]*: //')
        formatted_message="**$scope:** $clean_message"
    else
        clean_message=$(echo "$commit_message" | sed 's/^[^:]*: //')
        formatted_message="$clean_message"
    fi
    
    # Add commit link
    formatted_message="$formatted_message ([${commit_hash:0:7}]($REPO_URL/commit/$commit_hash))"
    
    if [ -z "${categories[$category]}" ]; then
        categories[$category]="- $formatted_message"
    else
        categories[$category]="${categories[$category]}"$'\n'"- $formatted_message"
    fi
done < <(git log $COMMIT_RANGE --pretty=format:"%H %s" --no-merges)

# Write categories to file
for category in "Features" "Bug Fixes" "Performance" "Documentation" "Tests" "Build System" "CI/CD" "Code Refactoring" "Styling" "Chores" "Other"; do
    if [ -n "${categories[$category]}" ]; then
        echo "### $category" >> "$OUTPUT_FILE"
        echo "" >> "$OUTPUT_FILE"
        echo "${categories[$category]}" >> "$OUTPUT_FILE"
        echo "" >> "$OUTPUT_FILE"
    fi
done

# Add previous releases if they exist
if [ -n "$LATEST_TAG" ]; then
    echo "---" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
    
    # Get all tags in reverse chronological order
    git tag -l --sort=-version:refname | while read -r tag; do
        if [ "$tag" != "$CURRENT_VERSION" ]; then
            tag_date=$(git log -1 --format=%ai $tag | cut -d' ' -f1)
            echo "## [$tag] - $tag_date" >> "$OUTPUT_FILE"
            
            # Get the previous tag
            prev_tag=$(git tag -l --sort=-version:refname | grep -A1 "^$tag$" | tail -n1)
            if [ "$prev_tag" = "$tag" ]; then
                # This is the first tag
                tag_range="$tag"
            else
                tag_range="$prev_tag..$tag"
            fi
            
            # Add a summary of changes
            echo "" >> "$OUTPUT_FILE"
            git log $tag_range --pretty=format:"- %s" --no-merges | head -10 >> "$OUTPUT_FILE"
            echo "" >> "$OUTPUT_FILE"
            echo "" >> "$OUTPUT_FILE"
        fi
    done
fi

echo -e "${GREEN}Changelog generated successfully: $OUTPUT_FILE${NC}"