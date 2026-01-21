# Draggable Position View

A visual debugging tool that displays a draggable overlay showing position and size information.

**File:** `Sources/Loupe/DraggablePositionView.swift:200`

## Overview

`DraggablePositionView` renders a small crosshair overlay with a label showing:
- Current x, y coordinates in the specified coordinate space
- Optional text label for identification
- Draggable positioning (opt-in)
- Constraint system for limiting drag behavior
- Persistent positions across app launches

Unlike `VisualLayoutGuide`, which shows bounds and insets, `DraggablePositionView` focuses on tracking the **position** of a specific point in your layout.

## Basic Usage

```swift
import Loupe

struct ContentView: View {
    var body: some View {
        ZStack {
            Color.blue

            DraggablePositionView("Tracker")
                .frame(width: 15)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
    }
}
```

This displays a small crosshair at the top-leading corner showing the current coordinates.

## Features

### Position Display

- Small crosshair indicator (1pt circle with vertical/horizontal lines)
- Label overlay showing:
  - **x:** Horizontal coordinate
  - **y:** Vertical coordinate
  - Optional text label
- Coordinates displayed with 1 decimal place precision

### Draggable

Enable drag gestures to manually move the position tracker:

```swift
DraggablePositionView("Drag Me")
    .draggablePositionViewInteractions(dragEnabled: true)
```

When dragging is enabled:
- Tap and drag the crosshair to reposition it
- Coordinates update in real-time
- Manual offsets are preserved

### Coordinate Spaces

Choose how position is reported:

```swift
// Local coordinates (relative to parent)
DraggablePositionView("Local", coordinateSpace: .local)

// Global coordinates (screen space)
DraggablePositionView("Global", coordinateSpace: .global)

// Named coordinates (custom coordinate space)
DraggablePositionView("Custom", coordinateSpace: .named("container"))
```

### Constraint System

Limit dragging to specific axes or ranges:

```swift
// Horizontal dragging only
DraggablePositionView("Horizontal")
    .draggablePositionViewInteractions(dragEnabled: true)
    .draggablePositionViewConstraints(.horizontal)

// Vertical dragging only
DraggablePositionView("Vertical")
    .draggablePositionViewInteractions(dragEnabled: true)
    .draggablePositionViewConstraints(.vertical)

// Custom range constraints
DraggablePositionView("Constrained")
    .draggablePositionViewInteractions(dragEnabled: true)
    .draggablePositionViewConstraints(
        DragConstraints(
            horizontalRange: 0...300,
            verticalRange: 0...500
        )
    )
```

### Persistent Positions

Save manual positions across app launches:

```swift
DraggablePositionView("Persistent", persistenceKey: "tracker-1")
    .draggablePositionViewInteractions(
        dragEnabled: true,
        persistenceEnabled: true,
        persistenceNamespace: "debug"
    )
```

## Initialization

```swift
public init(
    _ label: String? = nil,
    coordinateSpace: DraggablePositionCoordinateSpace = .local,
    startPosition: CGSize = .zero,
    persistenceKey: String? = nil
)
```

### Parameters

- **`label`** - Optional text label displayed in the info overlay
- **`coordinateSpace`** - Coordinate space for position reporting (default: `.local`)
- **`startPosition`** - Initial offset from the natural position (default: `.zero`)
- **`persistenceKey`** - Optional identifier for persisting manual offsets

### Coordinate Space Options

```swift
public enum DraggablePositionCoordinateSpace: Equatable, Sendable {
    case local          // Relative to parent
    case named(String)  // Custom named space
    case global         // Screen coordinates
}
```

## Environment Modifiers

### draggablePositionViewInteractions

Controls dragging and persistence behavior.

```swift
func draggablePositionViewInteractions(
    dragEnabled: Bool,
    persistenceEnabled: Bool = false,
    persistenceNamespace: String? = nil
) -> some View
```

#### Parameters

- **`dragEnabled`** - Enable/disable drag gestures
- **`persistenceEnabled`** - Save/restore manual offsets using UserDefaults (default: `false`)
- **`persistenceNamespace`** - Optional namespace for UserDefaults keys (default: `"DraggablePositionView"`)

#### Example

```swift
ZStack {
    DraggablePositionView("Point A", persistenceKey: "point-a")
    DraggablePositionView("Point B", persistenceKey: "point-b")
}
.draggablePositionViewInteractions(
    dragEnabled: true,
    persistenceEnabled: true,
    persistenceNamespace: "my-app-tracking"
)
```

### draggablePositionViewConstraints

Configures drag constraints.

```swift
func draggablePositionViewConstraints(
    _ constraints: DragConstraints
) -> some View
```

## Drag Constraints

```swift
public struct DragConstraints: Equatable, Sendable {
    public var horizontalRange: ClosedRange<CGFloat>?
    public var verticalRange: ClosedRange<CGFloat>?
    public var horizontalOnly: Bool
    public var verticalOnly: Bool
}
```

### Static Constraints

```swift
// No constraints - free dragging
DragConstraints.none

// Horizontal axis only
DragConstraints.horizontal

// Vertical axis only
DragConstraints.vertical
```

### Custom Constraints

```swift
DragConstraints(
    horizontalRange: 0...500,    // Limit x between 0 and 500
    verticalRange: 100...800,    // Limit y between 100 and 800
    horizontalOnly: false,
    verticalOnly: false
)
```

## Start Position

Offset the initial position without dragging:

```swift
DraggablePositionView("Offset", startPosition: CGSize(width: 100, height: 50))
```

This is useful for:
- Positioning trackers at specific points
- Creating multiple trackers at different starting positions
- Testing layouts programmatically

## Advanced Usage

### Tracking View Corners

```swift
ZStack {
    Color.blue
        .frame(width: 200, height: 150)
        .overlay {
            DraggablePositionView("TL", coordinateSpace: .global)
                .frame(width: 10)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        .overlay {
            DraggablePositionView("BR", coordinateSpace: .global)
                .frame(width: 10)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
        }
}
```

Place trackers at each corner to monitor exact positions.

### Named Coordinate Space

```swift
ScrollView {
    VStack {
        DraggablePositionView("Scroll Content", coordinateSpace: .named("scroll"))
            .frame(width: 10)
    }
}
.coordinateSpace(name: "scroll")
```

Track position relative to a custom coordinate space (useful for scroll views).

### Combining with Layout Guides

```swift
ZStack {
    VisualLayoutGuide("Bounds")
        .foregroundStyle(.blue)

    DraggablePositionView("Center")
        .frame(width: 10)
}
.draggablePositionViewInteractions(dragEnabled: true)
```

Use both tools together for complete layout debugging.

### Overlay Smart Positioning

The info label automatically flips above the crosshair when it would overflow the bottom edge of the screen:

```swift
// Label appears below crosshair (default)
DraggablePositionView("Top")
    .frame(width: 10)
    .frame(maxHeight: .infinity, alignment: .top)

// Label automatically flips above when near bottom
DraggablePositionView("Bottom")
    .frame(width: 10)
    .frame(maxHeight: .infinity, alignment: .bottom)
```

## How It Works

### Crosshair Rendering

```swift
Circle()
    .opacity(0.0)
    .background(.thinMaterial, in: .circle)
    .overlay {
        ZStack {
            Rectangle().frame(width: 1)  // Vertical line
            Rectangle().frame(height: 1) // Horizontal line
            Circle().foregroundStyle(.black).frame(width: 1) // Center point
        }
    }
```

The crosshair is intentionally minimal to avoid obscuring content.

### Position Tracking

Uses `onGeometryChange(for:)` to monitor position:

```swift
.onGeometryChange(for: CGPoint.self) { proxy in
    proxy.frame(in: coordinateSpaceValue).origin
} action: { newValue in
    viewPosition = newValue
}
```

Position updates automatically when:
- The view moves
- The parent container changes
- The coordinate space changes

### Gesture Handling

Drag gestures update offsets in real-time:

1. `DragGesture` tracks translation in global space
2. `activeDragOffset` is updated during drag
3. On drag end, offset is committed to `persistedManualOffset`
4. If persistence is enabled, offset is saved to UserDefaults

### Persistence

Offsets are stored as an array of two doubles:

```swift
UserDefaults.standard.set(
    [Double(width), Double(height)],
    forKey: "\(namespace).\(sanitizedKey)"
)
```

## Performance Considerations

- Lightweight rendering (minimal overlay)
- Efficient position tracking via `onGeometryChange`
- Drag gestures only enabled when requested
- Persistence writes only on drag end (not during drag)

## Common Use Cases

### Testing Scroll Views

```swift
ScrollView {
    VStack {
        ForEach(0..<20) { i in
            Text("Row \(i)")
                .padding()
        }

        DraggablePositionView("Scroll Position", coordinateSpace: .global)
            .frame(width: 10)
    }
}
```

Track position as content scrolls.

### Debugging Animations

```swift
struct AnimatedView: View {
    @State private var offset: CGFloat = 0

    var body: some View {
        ZStack {
            DraggablePositionView("Animated", coordinateSpace: .global)
                .frame(width: 10)
                .offset(y: offset)
                .animation(.easeInOut, value: offset)
        }
        .onTapGesture {
            offset = offset == 0 ? 200 : 0
        }
    }
}
```

See exact coordinates during animations.

### Prototyping Touch Areas

```swift
DraggablePositionView("Tap Target")
    .frame(width: 44, height: 44) // Standard tap target size
    .draggablePositionViewInteractions(dragEnabled: true)
```

Position and verify tap targets meet accessibility guidelines.

### Testing Coordinate Spaces

```swift
GeometryReader { proxy in
    ZStack {
        DraggablePositionView("Local", coordinateSpace: .local)
            .foregroundStyle(.blue)

        DraggablePositionView("Global", coordinateSpace: .global)
            .foregroundStyle(.red)
            .offset(x: 20)
    }
}
```

Compare local vs global coordinates.

## Related Documentation

- [Visual Layout Guide](Visual-Layout-Guide) - Inspect bounds and insets
- [Visual Grid Guide](Visual-Grid-Guide) - Alignment grids
- [API Reference](API-Reference) - Complete API documentation
