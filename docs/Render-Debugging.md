# Render Debugging

Loupe provides three tools for visualizing when and how SwiftUI views are being rendered and recomputed.

## Overview

SwiftUI's declarative nature can make it difficult to understand when views are being re-rendered or re-initialized. These debugging tools provide visual feedback to help you:

- Identify unnecessary re-renders
- Understand view lifecycle
- Optimize performance
- Debug state management issues

All render debugging tools are conditionally compiled with `#if DEBUG` and have zero impact on release builds.

## debugRender()

**File:** `Sources/Loupe/DebugRender.swift:55`

### What It Does

The `.debugRender()` modifier highlights when a view is **redrawn** by overlaying a random colored background each time SwiftUI renders the view.

### Usage

```swift
import Loupe

struct ContentView: View {
    @State private var count = 0

    var body: some View {
        VStack {
            Text("Count: \(count)")
                .debugRender()

            Button("Increment") {
                count += 1
            }
        }
    }
}
```

Each time the `Text` view re-renders (when `count` changes), you'll see a new colored background flash behind it.

### Parameters

- `enabled: Bool` - Toggle the debug visualization (default: `true`)

```swift
Text("Hello")
    .debugRender(enabled: shouldDebug)
```

### How It Works

`debugRender()` wraps your view in a `Canvas` that generates a random color on each render:

1. When SwiftUI redraws the view, the `Canvas`'s render closure executes
2. A new random hue (with high saturation and brightness) is generated
3. The color is drawn as a semi-transparent background (40% opacity)
4. The overlay doesn't block touch events (`allowsHitTesting(false)`)

**Key Implementation Details:**

- Uses `Canvas` for efficient rendering (requires iOS 15+)
- Random colors use HSB color space for distinct, vibrant hues
- The wrapper is removed entirely in release builds via `#if DEBUG`

### When to Use

- Debugging unnecessary re-renders caused by state changes
- Verifying that view optimizations (like `EquatableView`) are working
- Understanding how parent view updates affect children
- Checking if animations trigger re-renders

## debugCompute()

**File:** `Sources/Loupe/ComputeDebugView.swift:44`

### What It Does

The `.debugCompute()` modifier highlights when a view is **re-initialized** by flashing a red overlay. Since SwiftUI views are value types that get recreated on refresh, this shows when the view's initializer runs.

### Usage

```swift
import Loupe

struct ContentView: View {
    @State private var count = 0

    var body: some View {
        VStack {
            Text("Count: \(count)")
                .debugCompute()

            Button("Increment") {
                count += 1
            }
        }
    }
}
```

Each time the view is re-initialized, you'll see a red flash fade out over 0.3 seconds.

### Parameters

- `enabled: Bool` - Toggle the debug visualization (default: `true`)

```swift
Text("Hello")
    .debugCompute(enabled: shouldDebug)
```

### How It Works

`debugCompute()` uses a `LocalRenderManager` to track re-initializations:

1. Each time the view struct is initialized, a new `LocalRenderManager` is created
2. The manager immediately triggers a render by setting `rendered = true`
3. A red overlay (30% opacity) is displayed
4. After 0.4 seconds, the overlay fades out via animation
5. The fade uses `.easeOut(duration: 0.3)` for smooth visual feedback

**Key Implementation Details:**

- Uses `@ObservedObject` with `LocalRenderManager` to manage animation state
- The red flash is applied as an overlay (not a background)
- Animation timing: 0.4s delay + 0.3s ease-out animation
- The overlay doesn't block touch events

### Difference from debugRender()

- **`debugRender()`** shows when SwiftUI **redraws** the view (actual rendering)
- **`debugCompute()`** shows when the view **struct is recreated** (re-initialization)

A view can be re-initialized without being redrawn, and vice versa. Both tools together give you complete visibility into the view lifecycle.

### When to Use

- Understanding when view structs are being recreated
- Debugging expensive computations in view initializers
- Verifying that structural identity is preserved
- Checking if view updates are causing cascading re-initializations

## RenderCheck

**File:** `Sources/Loupe/RenderCheck.swift:13`

### What It Does

`RenderCheck` is a container view that automatically applies `.debugRender()` to **all** of its child views, making it easy to debug multiple views at once.

### Usage

```swift
import Loupe

struct ContentView: View {
    @State private var count = 0

    var body: some View {
        RenderCheck {
            Text("Count: \(count)")
            Text("Double: \(count * 2)")
            Text("Triple: \(count * 3)")

            Button("Increment") {
                count += 1
            }
        }
    }
}
```

All views inside `RenderCheck` will show colored backgrounds when they re-render, without needing to add `.debugRender()` to each one individually.

### How It Works

`RenderCheck` uses SwiftUI's `Group(subviews:)` API to access and wrap child views:

**iOS 18+ / macOS 15+ / visionOS 2+ / tvOS 18+ / watchOS 11+:**
- Uses `Group(subviews:)` to iterate over children
- Applies `.debugRender()` to the entire group

**Earlier OS Versions:**
- Falls back to `_VariadicView.Tree` (underscored API)
- Uses `_RenderCheckGroup` to apply `.debugRender()` to each child via `ForEach`

**Key Implementation Details:**

- Supports `@ViewBuilder` content, so you can pass multiple views without wrapping them
- Automatically selects the appropriate implementation based on OS version
- Each subview gets its own debug overlay
- All child views are wrapped, regardless of nesting depth

### When to Use

- Debugging complex view hierarchies
- Quickly identifying which views in a container are re-rendering
- Batch debugging without modifying each view
- Testing render performance of lists or groups

### Limitations

- Only applies to direct children (doesn't recursively apply to nested views)
- Uses underscored APIs (`_VariadicView`) for backward compatibility
- Only works with views that can be iterated (doesn't work with single views or conditionals)

## LocalRenderManager

**File:** `Sources/Loupe/LocalRenderManager.swift:19`

### What It Is

`LocalRenderManager` is an internal `ObservableObject` used by `debugCompute()` to manage animation state.

### Implementation

```swift
@MainActor
class LocalRenderManager: ObservableObject {
    var id = UUID()
    @Published var rendered: Bool = false

    func triggerRender() {
        rendered = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            self.rendered = false
        }
    }
}
```

### How It Works

- `@MainActor` ensures thread safety for UI updates
- `@Published var rendered` triggers view updates when changed
- `triggerRender()` sets `rendered = true`, then resets it after 0.4 seconds
- Each `debugCompute()` wrapper creates its own instance

You typically won't use this class directly—it's an internal implementation detail of `debugCompute()`.

## Performance Considerations

### Debug Builds

- Minimal overhead (Canvas rendering is efficient)
- Safe for active development
- No blocking of user interactions

### Release Builds

- **Zero impact** - all debug tools are compiled out via `#if DEBUG`
- No performance cost
- No code size increase

### Best Practices

1. **Use sparingly** - Don't wrap every view; focus on suspected problem areas
2. **Combine tools** - Use both `debugRender()` and `debugCompute()` to get complete visibility
3. **Remove when done** - Clean up debug modifiers once you've identified the issue
4. **Use RenderCheck for batches** - More efficient than adding modifiers to each view individually

## Common Debugging Scenarios

### Identifying Unnecessary Re-Renders

```swift
struct ParentView: View {
    @State private var counter = 0

    var body: some View {
        VStack {
            ChildView()
                .debugRender() // Will this re-render when counter changes?

            Button("Increment") {
                counter += 1
            }
        }
    }
}
```

If `ChildView` shows a new color when you tap the button, it means it's re-rendering even though it doesn't depend on `counter`.

### Verifying EquatableView Optimization

```swift
struct ExpensiveView: View, Equatable {
    let data: String

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.data == rhs.data
    }

    var body: some View {
        Text(data)
            .debugRender()
    }
}

struct ParentView: View {
    @State private var counter = 0

    var body: some View {
        VStack {
            ExpensiveView(data: "Static")
                .equatable()

            Text("Counter: \(counter)")

            Button("Increment") {
                counter += 1
            }
        }
    }
}
```

The `ExpensiveView` should **not** show a new color when the button is tapped, because `.equatable()` prevents re-rendering when the data hasn't changed.

### Debugging State Changes

```swift
RenderCheck {
    Text("A")
    Text("B")
    Text("C")
}
```

Tap a button that changes state and see which views actually re-render. This helps identify over-subscription to state.

## Related Documentation

- [Visual Layout Guide](Visual-Layout-Guide) - Inspect bounds and safe areas
- [Draggable Position View](Draggable-Position-View) - Track positions
- [API Reference](API-Reference) - Complete API documentation
