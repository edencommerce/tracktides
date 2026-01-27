# tracktides

An iOS app built with SwiftUI and Apple's Liquid Glass design language.

## Requirements

- iOS 26.0+
- Xcode 26.0+
- Swift 6.0

## About Liquid Glass

Liquid Glass is Apple's new design language introduced for iOS 26. It provides translucent, dynamic materials that reflect and refract surrounding content, creating elements that appear to float above the main UI layer.

### Key Features

- **`.glassEffect()`** - Applies the interactive glass appearance to views
- **`GlassEffectContainer { }`** - Coordinates how glass elements blend and transition
- **`.glassEffectID()`** - Associates related glass elements for morphing transitions
- **Glass button styles** - `.buttonStyle(.glass)` and `.buttonStyle(.glassProminent)`

## Project Structure

```
tracktides/
├── tracktides.xcodeproj/       # Xcode project file
├── tracktides/                  # Source code directory
│   ├── tracktideApp.swift      # App entry point
│   ├── ContentView.swift       # Main view
│   ├── Assets.xcassets/        # Asset catalog
│   └── Preview Content/        # Preview assets
└── README.md
```

## Getting Started

### First-Time Setup

1. **Install development tools**:
   ```bash
   make setup
   ```
   This installs SwiftLint and SwiftFormat via Homebrew.

2. **Open the project**:
   ```bash
   open tracktides.xcodeproj
   ```

3. **Build and run** (Cmd+R in Xcode)

### Development Workflow

```bash
make format       # Auto-format code
make lint         # Check for linting issues
make check        # Run all checks
```

## Code Quality

This project uses strict Swift development practices:

- **SwiftLint** - Enforces style guidelines and best practices
- **SwiftFormat** - Automatic code formatting (4-space indent, 120 char line length)
- **Strict Concurrency** - Full Swift 6 data-race safety
- **Warnings as Errors** - Zero-tolerance quality policy

Configuration files:
- `.swiftlint.yml` - Linting rules
- `.swiftformat` - Formatting style
- `.editorconfig` - Editor settings

## Features

The app showcases several Liquid Glass features:

- **GlassEffectContainer** - Coordinates glass elements for seamless blending and transitions
- **Interactive glass cards** - Morphing transitions using `@Namespace` and `.glassEffectID()`
- **Glass button styles** - Both `.glass` (secondary) and `.glassProminent` (primary) variants
- **Tinted glass** - Custom tints with `.tint()` modifier
- **Glass variants** - `.regular`, `.clear`, and `.interactive()` effects
- **Tab navigation** - Glass bottom navigation bar

## Customization

You can customize glass effects with modifiers:

```swift
// Different glass variants
.glassEffect()                               // Default regular glass
.glassEffect(.clear)                         // More transparent
.glassEffect(.regular.tint(.blue))          // With color tint
.glassEffect(.regular.interactive())        // Responds to touch

// Morphing transitions
@Namespace private var namespace
.glassEffectID("uniqueID", in: namespace)   // For animated morphing
```

## Resources

- [Apple Developer - Liquid Glass Overview](https://developer.apple.com/documentation/TechnologyOverviews/liquid-glass)
- [Apple Developer - Applying Liquid Glass to custom views](https://developer.apple.com/documentation/SwiftUI/Applying-Liquid-Glass-to-custom-views)
- [Liquid Glass Kit](https://liquidglass-kit.dev/)
