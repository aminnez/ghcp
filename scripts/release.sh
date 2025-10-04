#!/bin/bash

# Release script for ghcp
# Usage: ./scripts/release.sh <version>
# Example: ./scripts/release.sh 1.0.1

set -e

if [ $# -eq 0 ]; then
    echo "Error: Version required"
    echo "Usage: $0 <version>"
    echo "Example: $0 1.0.1"
    exit 1
fi

VERSION="$1"
TAG="v$VERSION"

echo "🚀 Preparing release $VERSION"

# Validate version format
if ! [[ $VERSION =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "❌ Invalid version format. Use semantic versioning (e.g., 1.0.1)"
    exit 1
fi

# Check if we're on main branch
CURRENT_BRANCH=$(git branch --show-current)
if [ "$CURRENT_BRANCH" != "main" ]; then
    echo "❌ Please switch to main branch before releasing"
    echo "Current branch: $CURRENT_BRANCH"
    exit 1
fi

# Check for uncommitted changes
if [ -n "$(git status --porcelain)" ]; then
    echo "❌ You have uncommitted changes. Please commit or stash them first."
    git status --short
    exit 1
fi

# Pull latest changes
echo "📥 Pulling latest changes..."
git pull origin main

# Run quality checks
echo "🔍 Running quality checks..."
dart pub get
dart analyze
dart test
# dart pub publish --dry-run

echo "✅ All checks passed!"

# Check if version is already updated in pubspec.yaml
CURRENT_VERSION=$(grep "^version:" pubspec.yaml | cut -d' ' -f2)
if [ "$CURRENT_VERSION" != "$VERSION" ]; then
    echo "⚠️  Version in pubspec.yaml ($CURRENT_VERSION) doesn't match release version ($VERSION)"
    echo "Please update pubspec.yaml manually and run this script again."
    exit 1
fi

# Check if tag already exists
if git tag -l | grep -q "^$TAG$"; then
    echo "❌ Tag $TAG already exists"
    exit 1
fi

# Confirm release
echo ""
echo "📋 Release Summary:"
echo "  Version: $VERSION"
echo "  Tag: $TAG"
echo "  Branch: $CURRENT_BRANCH"
echo ""
read -p "Continue with release? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Release cancelled"
    exit 1
fi

# Create and push tag
echo "🏷️  Creating tag $TAG..."
git tag -a "$TAG" -m "Release $VERSION"

echo "📤 Pushing tag to origin..."
git push origin "$TAG"

echo ""
echo "🎉 Release $VERSION initiated!"
echo ""
echo "The GitHub Actions workflow will now:"
echo "  ✅ Build binaries for all platforms"
echo "  ✅ Run all tests and quality checks"
echo "  ✅ Publish to pub.dev"
echo "  ✅ Create GitHub release with assets"
echo ""
echo "Monitor progress at: https://github.com/aminnez/ghcp/actions"
echo "Package will be available at: https://pub.dev/packages/ghcp"