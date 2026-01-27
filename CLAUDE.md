# CLAUDE.md

This file provides guidance to Claude Code when working with the tracktides iOS project.

## Project Type

This is a native iOS app built with SwiftUI, targeting iOS 26+ and using Apple's Liquid Glass design language.

## Project Structure

- **tracktides.xcodeproj/** - Xcode project file (open this in Xcode)
- **tracktides/** - Source code directory
  - `tracktideApp.swift` - App entry point (@main)
  - `ContentView.swift` - Main view implementation
  - `Assets.xcassets/` - Asset catalog (images, colors, app icon)
  - `Preview Content/` - Assets for Xcode previews

## Requirements

- iOS 26.0+ deployment target
- Xcode 26.0+
- Swift 6.0

## Building and Running

Open `tracktides.xcodeproj` in Xcode and press Cmd+R to build and run.

Alternatively, use command line:
```bash
xcodebuild -project tracktides.xcodeproj -scheme tracktides -destination 'platform=iOS Simulator,name=iPhone 16' build
```

## Liquid Glass APIs

The app uses Apple's native Liquid Glass APIs introduced in iOS 26:

### Core Modifiers
- `.glassEffect()` - Applies glass effect to views
- `.glassEffect(.regular)` - Standard glass appearance
- `.glassEffect(.clear)` - More transparent variant
- `.glassEffect(.regular.tint(.blue))` - Add color tint
- `.glassEffect(.regular.interactive())` - Touch-responsive glass

### Container
- `GlassEffectContainer { }` - Wrap glass elements for coordinated blending and transitions

### Morphing Transitions
```swift
@Namespace private var glassNamespace
.glassEffectID("uniqueID", in: glassNamespace)
```

### Button Styles
- `.buttonStyle(.glass)` - Secondary action button (translucent)
- `.buttonStyle(.glassProminent)` - Primary action button (opaque)

## Design Principles

When working with Liquid Glass:
- Content sits at the bottom layer
- Glass controls float on top
- Always group related glass elements in `GlassEffectContainer`
- Use `.glassEffectID()` for elements that morph between states
- Apply glass to navigation and control layers, not main content

## Code Style

- Use SwiftUI property wrappers: `@State`, `@Namespace`, `@Binding`
- Prefer computed properties over functions for view composition
- Extract reusable components into separate structs
- Use `.foregroundStyle()` instead of deprecated `.foregroundColor()`
- Use system fonts with appropriate weights
- Include `#Preview` macros for Xcode previews

## Adding New Files

When adding new Swift files to the project:
1. Create the file in the `tracktides/` directory
2. Update the Xcode project to include the file (or let Xcode auto-detect it)
3. Ensure the file has the correct target membership

## Common Tasks

### Add a new view
Create a new `.swift` file in `tracktides/` directory following this pattern:
```swift
import SwiftUI

struct MyNewView: View {
    var body: some View {
        // View implementation
    }
}

#Preview {
    MyNewView()
}
```

### Add assets
1. Add images to `tracktides/Assets.xcassets/`
2. Create new color sets in the asset catalog for custom colors
3. Reference them in code: `Image("imageName")` or `Color("colorName")`

### Update app configuration
Modify build settings in `tracktides.xcodeproj/project.pbxproj` or use Xcode's project settings UI.
