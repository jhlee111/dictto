#!/bin/bash
# Update appcast.xml with new release info
#
# Usage:
#   ./scripts/update-appcast.sh <version> <signature> <size> <release_notes>
#
# Example:
#   ./scripts/update-appcast.sh "0.12.0" "abc123..." "12345678" "Bug fixes and improvements"
#
# Or read from sparkle-info.json:
#   VERSION=$(jq -r .version ../app/dist/sparkle-info.json)
#   SIGNATURE=$(jq -r .edSignature ../app/dist/sparkle-info.json)
#   SIZE=$(jq -r .size ../app/dist/sparkle-info.json)
#   ./scripts/update-appcast.sh "$VERSION" "$SIGNATURE" "$SIZE" "Release notes"

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
APPCAST_FILE="$REPO_ROOT/docs/appcast.xml"

# Parse arguments
VERSION="$1"
SIGNATURE="$2"
SIZE="$3"
RELEASE_NOTES="$4"

if [ -z "$VERSION" ] || [ -z "$SIGNATURE" ] || [ -z "$SIZE" ]; then
    echo "Usage: $0 <version> <signature> <size> [release_notes]"
    echo ""
    echo "Arguments:"
    echo "  version       Version string (e.g., 0.12.0)"
    echo "  signature     EdDSA signature from build-app.sh"
    echo "  size          File size in bytes"
    echo "  release_notes Optional release notes (HTML list items)"
    exit 1
fi

# Default release notes if not provided
if [ -z "$RELEASE_NOTES" ]; then
    RELEASE_NOTES="Bug fixes and improvements"
fi

# Generate pubDate in RFC 2822 format
PUB_DATE=$(date -R)

# Download URL
DOWNLOAD_URL="https://github.com/jhlee111/dictto/releases/download/v${VERSION}/Dictto-${VERSION}.zip"

# Create new item XML
NEW_ITEM=$(cat <<EOF
        <item>
            <title>Version ${VERSION}</title>
            <sparkle:version>${VERSION}</sparkle:version>
            <sparkle:shortVersionString>${VERSION}</sparkle:shortVersionString>
            <pubDate>${PUB_DATE}</pubDate>
            <enclosure url="${DOWNLOAD_URL}"
                       sparkle:edSignature="${SIGNATURE}"
                       length="${SIZE}"
                       type="application/octet-stream"/>
            <sparkle:minimumSystemVersion>14.0</sparkle:minimumSystemVersion>
            <description><![CDATA[
                <h2>What's New in ${VERSION}</h2>
                <ul>
                    <li>${RELEASE_NOTES}</li>
                </ul>
            ]]></description>
        </item>

EOF
)

# Check if appcast.xml exists
if [ ! -f "$APPCAST_FILE" ]; then
    echo "Error: appcast.xml not found at $APPCAST_FILE"
    exit 1
fi

# Check if this version already exists
if grep -q "sparkle:version>${VERSION}</sparkle:version" "$APPCAST_FILE"; then
    echo "Warning: Version ${VERSION} already exists in appcast.xml"
    read -p "Replace existing entry? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Aborted."
        exit 1
    fi
    # Remove existing entry for this version
    # This is a simple approach - removes from <item> to </item> for matching version
    sed -i.bak "/<item>/,/<\/item>/{ /<sparkle:version>${VERSION}<\/sparkle:version>/,/<\/item>/d; }" "$APPCAST_FILE"
fi

# Insert new item after <language>en</language>
# Using awk for reliable multi-line insertion
awk -v new_item="$NEW_ITEM" '
    /<language>en<\/language>/ {
        print
        print ""
        printf "%s", new_item
        next
    }
    { print }
' "$APPCAST_FILE" > "$APPCAST_FILE.tmp"

mv "$APPCAST_FILE.tmp" "$APPCAST_FILE"

echo "✅ Updated appcast.xml with version ${VERSION}"
echo ""
echo "Changes:"
echo "  - Version: ${VERSION}"
echo "  - Signature: ${SIGNATURE:0:20}..."
echo "  - Size: ${SIZE} bytes"
echo "  - URL: ${DOWNLOAD_URL}"
echo ""
echo "Next steps:"
echo "  1. Review: cat $APPCAST_FILE"
echo "  2. Commit: git add docs/appcast.xml && git commit -m 'chore: add v${VERSION} to appcast'"
echo "  3. Push: git push"
