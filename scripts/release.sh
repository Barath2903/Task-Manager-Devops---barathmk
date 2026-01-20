#!/bin/bash

# Release script for Task Manager
# Usage: ./scripts/release.sh <version> [message]

set -e

VERSION=$1
MESSAGE=${2:-"Release version $VERSION"}

if [ -z "$VERSION" ]; then
    echo "Error: Version is required"
    echo "Usage: ./scripts/release.sh <version> [message]"
    exit 1
fi

# Validate version format (semantic versioning)
if ! [[ $VERSION =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "Error: Version must be in format X.Y.Z (e.g., 1.0.0)"
    exit 1
fi

echo "Creating release $VERSION..."

# Update version in pom.xml
mvn versions:set -DnewVersion=$VERSION -DgenerateBackupPoms=false

# Commit version change
git add pom.xml */pom.xml
git commit -m "Bump version to $VERSION" || true

# Create tag
git tag -a "v$VERSION" -m "$MESSAGE"

echo "Release $VERSION created successfully!"
echo "To push the release, run:"
echo "  git push origin main"
echo "  git push origin v$VERSION"
echo ""
echo "Or create a GitHub release with tag v$VERSION to trigger the CI/CD pipeline"
