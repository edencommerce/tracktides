.PHONY: help lint format format-check check setup clean

help:
	@echo "Available commands:"
	@echo "  make setup        - Install development tools (SwiftLint, SwiftFormat)"
	@echo "  make lint         - Run SwiftLint"
	@echo "  make format       - Format code with SwiftFormat"
	@echo "  make format-check - Check formatting without modifying files"
	@echo "  make check        - Run all checks (lint + format)"
	@echo "  make clean        - Clean build artifacts"

setup:
	@chmod +x scripts/setup.sh
	@./scripts/setup.sh

lint:
	@echo "🔍 Running SwiftLint..."
	@swiftlint lint --strict

format:
	@echo "✨ Formatting code with SwiftFormat..."
	@swiftformat .

format-check:
	@echo "🔍 Checking code formatting..."
	@swiftformat --lint .

check: lint format-check
	@echo "✅ All checks passed!"

clean:
	@echo "🧹 Cleaning build artifacts..."
	@rm -rf .build
	@rm -rf DerivedData
	@echo "✅ Clean complete"
