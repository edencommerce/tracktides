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
- SwiftLint (for linting)
- SwiftFormat (for code formatting)

## Setup

For first-time setup, run:
```bash
make setup
```

This will install SwiftLint and SwiftFormat via Homebrew.

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

## Development Tools & Best Practices

### Linting and Formatting

The project uses industry-standard tools for code quality:

- **SwiftLint** - Enforces Swift style and conventions
- **SwiftFormat** - Automatic code formatting

#### Quick Commands

```bash
make lint         # Run SwiftLint to check for issues
make format       # Auto-format all code
make format-check # Check formatting without modifying files
make check        # Run all checks (lint + format)
```

#### Configuration Files

- `.swiftlint.yml` - SwiftLint rules and settings
- `.swiftformat` - SwiftFormat style configuration
- `.editorconfig` - Editor settings for consistent formatting

### Strict Type Checking

The project has **strict Swift compiler settings** enabled:

#### Enabled Features:

1. **Strict Concurrency Checking** (`SWIFT_STRICT_CONCURRENCY = complete`)
   - Full data-race safety checking
   - Enforces actor isolation and Sendable conformance
   - Required for Swift 6 concurrency model

2. **Treat Warnings as Errors** (`SWIFT_TREAT_WARNINGS_AS_ERRORS = YES`)
   - Zero-tolerance policy for warnings
   - Ensures code quality and prevents technical debt

3. **Upcoming Features** (via `OTHER_SWIFT_FLAGS`)
   - `StrictConcurrency` - Strict concurrency checking
   - `ConciseMagicFile` - Better #file behavior
   - `ExistentialAny` - Explicit `any` for existential types

#### What This Means:

- **All compiler warnings become errors** - Must fix them to build
- **Concurrency safety is enforced** - No data races possible
- **Type safety is maximized** - Fewer runtime crashes

### Code Style Guidelines

#### Swift Naming Conventions

```swift
// Variables and functions: camelCase
let userName = "jason"
func fetchUserData() { }

// Types: PascalCase
struct UserProfile { }
class NetworkManager { }
enum AppState { }

// Constants: camelCase (not SCREAMING_SNAKE_CASE)
let maxRetryCount = 3

// Private properties: prefix with underscore is optional
private let _cache = [String: Any]()
```

#### SwiftUI Best Practices

```swift
// ✅ Good - Use @State for local state
struct MyView: View {
    @State private var isExpanded = false

    var body: some View {
        // Implementation
    }
}

// ✅ Good - Extract complex views
struct MyView: View {
    var body: some View {
        VStack {
            headerSection
            contentSection
        }
    }

    private var headerSection: some View {
        Text("Header")
    }

    private var contentSection: some View {
        Text("Content")
    }
}

// ✅ Good - Use explicit self with property wrappers
Button("Tap") {
    self.isExpanded.toggle()
}

// ❌ Bad - Forced unwrapping
let value = dictionary["key"]!  // Avoid this

// ✅ Good - Safe unwrapping
if let value = dictionary["key"] {
    // Use value safely
}

// ✅ Good - Guard for early exit
guard let value = dictionary["key"] else {
    return
}
```

#### Concurrency Patterns

```swift
// ✅ Mark async functions
func fetchData() async throws -> Data {
    // Implementation
}

// ✅ Use @MainActor for UI updates
@MainActor
class ViewModel: ObservableObject {
    @Published var data: [Item] = []

    func loadData() async {
        // Already on main actor
        self.data = await fetchItems()
    }
}

// ✅ Use Task for concurrent work
Task {
    let result = await fetchData()
    // Process result
}
```

### Avoiding Common Swift Mistakes

```swift
// ❌ Don't use print() in production
print("Debug info")  // SwiftLint will warn

// ✅ Use logging or #if DEBUG
#if DEBUG
print("Debug info")
#endif

// ❌ Don't force unwrap
let view = self.view!

// ✅ Use optional binding
guard let view = self.view else { return }

// ❌ Don't use implicitly unwrapped optionals unnecessarily
var name: String!

// ✅ Use regular optionals
var name: String?

// ❌ Don't ignore errors
try? someFunction()  // Silently fails

// ✅ Handle errors properly
do {
    try someFunction()
} catch {
    // Handle error
}
```

### Testing

When writing tests:
- Place tests in a `tracktides Tests` group
- Follow the Arrange-Act-Assert pattern
- Use descriptive test names: `test_functionName_whenCondition_thenExpectedOutcome`

```swift
func test_userLogin_whenValidCredentials_thenSucceeds() {
    // Arrange
    let username = "test@example.com"
    let password = "password123"

    // Act
    let result = authManager.login(username: username, password: password)

    // Assert
    XCTAssertTrue(result.isSuccess)
}
```

### Pre-commit Checklist

Before committing code:

1. ✅ Run `make format` to auto-format code
2. ✅ Run `make lint` to check for issues
3. ✅ Build the project (Cmd+B) to ensure it compiles
4. ✅ Run tests if available
5. ✅ Check that all warnings are fixed (warnings = errors)

### Resources

- [Swift.org - Language Guide](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/)
- [Apple - Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/)
- [SwiftLint Rules](https://realm.github.io/SwiftLint/rule-directory.html)
- [Swift 6 Migration Guide](https://www.swift.org/migration/documentation/swift-6-concurrency-migration-guide/)
