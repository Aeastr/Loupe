# Loupe - Draggable Position View

A visual debugging tool that displays a draggable overlay showing position and size information.

## Quick Start

```swift
import Loupe

ZStack {
    Color.blue

    DraggablePositionView("Tracker")
        .frame(width: 15)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
}
```

## Overview

`DraggablePositionView` renders a small crosshair overlay with a label showing:
- Current x, y coordinates in the specified coordinate space
- Optional text label for identification
- Draggable positioning (opt-in)
- Constraint system for limiting drag behavior
- Persistent positions across app launches

Unlike `VisualLayoutGuide`, which shows bounds and insets, `DraggablePositionView` focuses on tracking the **position** of a specific point in your layout.

## Features

### Position Display

- Small crosshair indicator (1pt circle with vertical/horizontal lines)
- Label overlay showing x, y coordinates
- Coordinates displayed with 1 decimal place precision

### Draggable

Enable drag gestures to manually move the position tracker:

```swift
DraggablePositionView("Drag Me")
    .draggablePositionViewInteractions(dragEnabled: true)
```

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
DragConstraints.none       // No constraints - free dragging
DragConstraints.horizontal // Horizontal axis only
DragConstraints.vertical   // Vertical axis only
```

## Common Use Cases

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

## How It Works

### Crosshair Rendering

The crosshair is intentionally minimal to avoid obscuring content:

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

### Position Tracking

Uses `onGeometryChange(for:)` to monitor position. Position updates automatically when the view moves, the parent container changes, or the coordinate space changes.

### Smart Label Positioning

The info label automatically flips above the crosshair when it would overflow the bottom edge of the screen.

## Performance Considerations

- Lightweight rendering (minimal overlay)
- Efficient position tracking via `onGeometryChange`
- Drag gestures only enabled when requested
- Persistence writes only on drag end (not during drag)

## Related Documentation

- [Visual Layout Guide](VisualLayoutGuide.md) - Inspect bounds and insets
- [Visual Grid Guide](VisualGridGuide.md) - Alignment grids
