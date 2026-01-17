#!/bin/bash
# Deploy website to Cloudflare Pages
#
# Prerequisites:
#   - wrangler CLI installed: npm install -g wrangler
#   - Authenticated: wrangler login
#
# Usage:
#   ./scripts/deploy-website.sh              # Deploy to production
#   ./scripts/deploy-website.sh --preview    # Deploy to preview URL

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
WEBSITE_DIR="$REPO_ROOT/website"

# Cloudflare Pages project name
PROJECT_NAME="dictto"

# Check if wrangler is installed
if ! command -v wrangler &> /dev/null; then
    echo "Error: wrangler CLI not found"
    echo "Install with: npm install -g wrangler"
    exit 1
fi

# Check if website directory exists
if [ ! -d "$WEBSITE_DIR" ]; then
    echo "Error: website directory not found at $WEBSITE_DIR"
    exit 1
fi

# Parse arguments
BRANCH=""
if [ "$1" == "--preview" ]; then
    BRANCH="--branch preview"
    echo "Deploying to preview..."
else
    BRANCH="--branch main"
    echo "Deploying to production..."
fi

# Deploy
cd "$WEBSITE_DIR"
wrangler pages deploy . --project-name "$PROJECT_NAME" $BRANCH

echo ""
echo "Deploy complete!"
