#!/bin/bash
# Setup script for tracktides development environment

set -e

echo "🔧 Setting up tracktides development environment..."

# Check if Homebrew is installed
if ! command -v brew &> /dev/null; then
    echo "❌ Homebrew is not installed. Please install it first:"
    echo "   /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
    exit 1
fi

echo "✅ Homebrew found"

# Install SwiftLint
if ! command -v swiftlint &> /dev/null; then
    echo "📦 Installing SwiftLint..."
    brew install swiftlint
else
    echo "✅ SwiftLint already installed ($(swiftlint version))"
fi

# Install SwiftFormat
if ! command -v swiftformat &> /dev/null; then
    echo "📦 Installing SwiftFormat..."
    brew install swiftformat
else
    echo "✅ SwiftFormat already installed ($(swiftformat --version))"
fi

echo ""
echo "✨ Setup complete!"
echo ""
echo "Available commands:"
echo "  make lint        - Run SwiftLint"
echo "  make format      - Format code with SwiftFormat"
echo "  make check       - Run both lint and format checks"
echo ""
echo "Next steps:"
echo "  1. Open tracktides.xcodeproj in Xcode"
echo "  2. Build the project (Cmd+B) to verify everything works"
echo "  3. Run 'make format' to format all code"
echo ""
