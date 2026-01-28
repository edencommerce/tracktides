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

### Using XcodeBuildMCP (Recommended)

This project is configured to use [XcodeBuildMCP](https://github.com/cameroncooke/XcodeBuildMCP) for AI-assisted Xcode automation. The MCP server provides tools for building, testing, and running the app directly from Claude.

#### Key Tools for This Project

| Tool | Purpose |
|------|---------|
| `discover_projs` | Find Xcode projects in the workspace |
| `list_schemes` | List available build schemes |
| `build_sim` | Build for iOS Simulator |
| `boot_sim` | Boot a simulator |
| `launch_app_sim` | Install and launch app on simulator |
| `screenshot` | Capture simulator screenshots |
| `test_sim` | Run tests on simulator |
| `start_sim_log_cap` | Capture runtime logs |
| `clean` | Clean build artifacts |

#### Common Workflows

**Build and run on simulator:**
1. `discover_projs` - Find the tracktides.xcodeproj
2. `list_schemes` - Verify "tracktides" scheme exists
3. `build_sim` - Build for simulator
4. `boot_sim` - Boot iPhone simulator
5. `launch_app_sim` - Launch the app

**Debug a build failure:**
1. `build_sim` - Attempt build (errors returned in response)
2. Fix code issues based on compiler output
3. Rebuild until successful

**Run tests:**
1. `test_sim` - Run unit tests on simulator
2. Review test results

**Capture UI for review:**
1. `screenshot` - Take simulator screenshot
2. Use `snapshot_ui` for accessibility hierarchy

#### Session Defaults

Use `session_set_defaults` to avoid repeating project/scheme parameters:
- Set project path: `/Users/jasonhe/dev/tracktides/tracktides.xcodeproj`
- Set scheme: `tracktides`
- Set simulator: `iPhone 16`

### Manual Building

Open `tracktides.xcodeproj` in Xcode and press Cmd+R to build and run.

Alternatively, use command line:
```bash
xcodebuild -project tracktides.xcodeproj -scheme tracktides -destination 'platform=iOS Simulator,name=iPhone 16' build
```

## Hot Reloading with Inject

The project uses [Inject](https://github.com/krzysztofzablocki/Inject) for hot reloading SwiftUI views during development.

### Requirements

- [InjectionIII.app](https://github.com/johnno1962/InjectionIII/releases) running and watching the project directory
- Views must have `@ObserveInjection var inject` and `.enableInjection()` modifier

### Views with Hot Reload Enabled

- `ContentView.swift` - Main tab view

### How It Works

1. InjectionIII watches for file changes
2. On save (Cmd+S in Xcode), it recompiles just that file
3. The new code is injected into the running app
4. Views with `@ObserveInjection` automatically refresh

### Claude Code Workflow

**For simple view changes (colors, text, layout, modifiers):**
- Edit the file
- Tell user to save in Xcode (Cmd+S) to trigger hot reload
- **Skip `build_run_sim`** - no rebuild needed

**When to rebuild (`build_run_sim`):**
- Adding new files
- Changing models, enums, or structs
- Adding `@ObserveInjection` to new views
- Injection errors or platform mismatch

**If injection fails with platform errors:**
1. Run `clean` with `platform: "iOS Simulator"`
2. Delete DerivedData if needed: `rm -rf ~/Library/Developer/Xcode/DerivedData/tracktides-*`
3. Rebuild with `build_run_sim`

### Adding Hot Reload to New Views

```swift
import Inject

struct MyNewView: View {
    @ObserveInjection var inject

    var body: some View {
        // View content
        .enableInjection()
    }
}
```

### Troubleshooting

- **"No such module 'Inject'"** - Build the project first
- **Platform mismatch errors** - Clean build folder, rebuild
- **Changes not appearing** - Ensure file is saved in Xcode, not just external editor
- **InjectionIII not connecting** - Check File Watcher is set to project directory

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

## Architecture Guidelines

### Avoid Singletons, Prefer Actors and Dependency Injection

```swift
// ❌ Bad - Global singleton with shared mutable state
class DataManager {
    static let shared = DataManager()
    var cache: [String: Data] = [:]  // Not thread-safe
}

// ✅ Good - Actor for thread-safe shared state
actor DataCache {
    private var cache: [String: Data] = [:]

    func get(_ key: String) -> Data? {
        cache[key]
    }

    func set(_ key: String, data: Data) {
        cache[key] = data
    }
}

// ✅ Good - Dependency injection via Environment
@MainActor
@Observable
class TideViewModel {
    private let apiClient: APIClientProtocol

    init(apiClient: APIClientProtocol = APIClient()) {
        self.apiClient = apiClient
    }
}

// Inject via SwiftUI environment
struct ContentView: View {
    @State private var viewModel = TideViewModel()

    var body: some View {
        // Use viewModel
    }
}
```

### State Management Hierarchy

1. **`@State`** - Local view state (simple values, UI state)
2. **`@Observable`** - Shared state within a view hierarchy (Swift 6 preferred over `@ObservableObject`)
3. **`@Environment`** - App-wide dependencies and settings
4. **Actors** - Thread-safe shared resources (caches, network clients)

## Accessibility Requirements

The app must support all iOS accessibility features:

### Dynamic Type

```swift
// ✅ Always use system fonts that scale
Text("Tide Level")
    .font(.headline)  // Automatically scales

// ✅ For custom sizes, use relative scaling
Text("Custom")
    .font(.system(size: 18, weight: .medium, design: .rounded))
    .dynamicTypeSize(...DynamicTypeSize.accessibility3)  // Set max if needed

// ❌ Never use fixed sizes that ignore Dynamic Type
Text("Fixed")
    .font(.system(size: 14))  // Won't scale - avoid
```

### Dark Mode

```swift
// ✅ Use semantic colors that adapt
Text("Title")
    .foregroundStyle(.primary)

Color.accentColor  // Adapts to system
Color(.systemBackground)  // UIKit semantic colors

// ✅ Define adaptive colors in asset catalog
Color("TideBlue")  // With light/dark variants

// ❌ Never hardcode colors
Color(red: 0.2, green: 0.4, blue: 0.8)  // Won't adapt
```

### Right-to-Left (RTL) Layout

```swift
// ✅ Use leading/trailing instead of left/right
HStack {
    Text("Label")
    Spacer()
    Text("Value")
}
.padding(.leading, 16)  // Flips automatically for RTL

// ✅ Images that should flip
Image(systemName: "arrow.right")
    .flipsForRightToLeftLayoutDirection(true)

// ❌ Avoid absolute positioning
.padding(.left, 16)  // Won't flip for RTL
```

### VoiceOver and Accessibility Labels

```swift
// ✅ Add meaningful labels
Button(action: refreshTides) {
    Image(systemName: "arrow.clockwise")
}
.accessibilityLabel("Refresh tide data")

// ✅ Group related elements
VStack {
    Text("High Tide")
    Text("3:42 PM")
}
.accessibilityElement(children: .combine)

// ✅ Hide decorative elements
Image("wave-decoration")
    .accessibilityHidden(true)
```

## Common Pitfalls to Avoid

### Swift 6 Concurrency Pitfalls

```swift
// ❌ UI updates from non-main actor
actor DataFetcher {
    func fetch() async {
        let data = await api.getData()
        viewModel.items = data  // ERROR: Not on MainActor
    }
}

// ✅ Explicitly dispatch to MainActor
actor DataFetcher {
    func fetch() async {
        let data = await api.getData()
        await MainActor.run {
            viewModel.items = data
        }
    }
}

// ❌ Capturing non-Sendable types across actor boundaries
class UnsafeCache {  // Not Sendable
    var data: [String: Any] = [:]
}

// ✅ Make it Sendable or use an actor
actor SafeCache {
    var data: [String: String] = [:]
}
```

### SwiftUI View Pitfalls

```swift
// ❌ Heavy computation in body
var body: some View {
    let processed = heavyComputation(items)  // Runs every refresh
    List(processed) { item in ... }
}

// ✅ Cache in @State or computed property
@State private var processedItems: [Item] = []

var body: some View {
    List(processedItems) { item in ... }
        .task { processedItems = await heavyComputation(items) }
}

// ❌ Creating objects in body
var body: some View {
    MyView(viewModel: ViewModel())  // New instance every render
}

// ✅ Use @State or @StateObject
@State private var viewModel = ViewModel()

// ❌ Forgetting @MainActor on ObservableObject
class ViewModel: ObservableObject {
    @Published var items: [Item] = []  // Unsafe if updated from background
}

// ✅ Always mark view models as @MainActor
@MainActor
class ViewModel: ObservableObject {
    @Published var items: [Item] = []
}
```

### Memory and Performance Pitfalls

```swift
// ❌ Strong reference cycles in closures
class ViewModel {
    var onComplete: (() -> Void)?

    func setup() {
        onComplete = {
            self.doSomething()  // Strong capture creates cycle
        }
    }
}

// ✅ Use weak or unowned
onComplete = { [weak self] in
    self?.doSomething()
}

// ❌ Loading all data at once
func loadAllTides() async -> [Tide] {
    return await api.fetchAll()  // May be huge
}

// ✅ Use pagination or lazy loading
func loadTides(page: Int, limit: Int = 20) async -> [Tide] {
    return await api.fetch(page: page, limit: limit)
}
```

### API and Networking Pitfalls

```swift
// ❌ Assuming network always succeeds
let data = try! await URLSession.shared.data(from: url)

// ✅ Handle all error cases
do {
    let (data, response) = try await URLSession.shared.data(from: url)
    guard let httpResponse = response as? HTTPURLResponse,
          (200...299).contains(httpResponse.statusCode) else {
        throw APIError.invalidResponse
    }
    // Process data
} catch {
    // Show user-friendly error
}

// ❌ Not cancelling tasks when view disappears
.onAppear {
    Task {
        await loadData()  // May complete after view is gone
    }
}

// ✅ Use .task modifier (auto-cancels)
.task {
    await loadData()
}
```

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

## App Store & TestFlight Submission

For detailed instructions on submitting to TestFlight and the App Store, see:
- **[APP_STORE_SUBMISSION.md](APP_STORE_SUBMISSION.md)** - Complete submission guide
- **[APP_ICON_GUIDE.md](APP_ICON_GUIDE.md)** - App icon requirements and tips

The project includes a **Privacy Manifest** (`tracktides/PrivacyInfo.xcprivacy`) required for App Store submission. Update this file if you add features that use required reason APIs.
