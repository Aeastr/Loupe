# Loupe - Visual Layout Guide

A visual debugging tool that displays layout bounds, safe area insets, and size information.

## Quick Start

```swift
import Loupe

ZStack {
    Color.blue
        .overlay {
            VisualLayoutGuide("Content Area")
        }
}
```

## Overview

`VisualLayoutGuide` overlays a semi-transparent shape on your view showing:
- View bounds with a visible border
- Width and height measurements
- Safe area insets (top, leading, bottom, trailing)
- Optional label for identification
- Automatic collision detection to prevent overlapping labels

## Features

### Visual Bounds Display

- Semi-transparent shape (20% opacity) fills the view
- 3-point border around the edges
- Choice of rectangle or concentric rectangle shape (iOS 26+)

### Size and Inset Information

The info overlay displays:
- **Width** (`x###`) - View width in points (left side)
- **Height** (`y###`) - View height in points (bottom)
- **Label** - Optional identifier (top-right corner)
- **Top Inset** (`to##`) - Safe area inset from top
- **Leading Inset** (`le##`) - Safe area inset from leading edge
- **Bottom Inset** (`bo##`) - Safe area inset from bottom
- **Trailing Inset** (`tr##`) - Safe area inset from trailing edge

### Automatic Collision Detection

Multiple `VisualLayoutGuide` instances automatically detect overlapping labels and stack them vertically with 8pt spacing:

```swift
ZStack {
    VisualLayoutGuide("View 1")
    VisualLayoutGuide("View 2")
    VisualLayoutGuide("View 3")
}
```

Labels that would overlap are automatically offset. Earlier guides have priority; later ones are pushed down.

### Draggable Overlays

Enable drag gestures to manually reposition the info overlay:

```swift
VisualLayoutGuide("Debug View")
    .visualLayoutGuideInteractions(dragEnabled: true, persistenceEnabled: true)
```

When dragging is enabled:
- Tap and drag the info overlay to reposition it
- Manual offsets are preserved even when collision detection is active
- Optional persistence saves positions to UserDefaults

### Persistent Positions

Store manual overlay positions across app launches:

```swift
VisualLayoutGuide("Primary", persistenceKey: "primary-guide")
    .visualLayoutGuideInteractions(
        dragEnabled: true,
        persistenceEnabled: true,
        persistenceNamespace: "debug"
    )
```

Positions are saved to `UserDefaults` using the format: `<namespace>.<persistenceKey>`

## Initialization

```swift
public init(
    _ label: String? = nil,
    alignment: Alignment = .center,
    shape: VisualLayoutGuideShape = .rectangle,
    persistenceKey: String? = nil
)
```

### Parameters

- **`label`** - Optional text label displayed in the info overlay
- **`alignment`** - Position of the info overlay within bounds (default: `.center`)
- **`shape`** - The shape style for visualization (default: `.rectangle`)
- **`persistenceKey`** - Optional identifier for persisting manual offsets

### Shape Options

```swift
public enum VisualLayoutGuideShape {
    case rectangle
    case concentricRectangle // iOS 26+, macOS 26+, tvOS 26+, watchOS 26+
}
```

## Environment Modifiers

### visualLayoutGuideInteractions

Controls dragging and persistence behavior for all guides within the view hierarchy.

```swift
func visualLayoutGuideInteractions(
    dragEnabled: Bool,
    persistenceEnabled: Bool,
    persistenceNamespace: String? = nil
) -> some View
```

### visualLayoutGuidePositioning

Controls automatic collision detection and label stacking.

```swift
func visualLayoutGuidePositioning(
    _ mode: VisualLayoutGuidePositioningMode
) -> some View
```

Modes:
- `.auto` - Enable collision detection (default)
- `.disabled` - Disable collision detection

## Custom Alignment

Position the info overlay at different locations within the bounds:

```swift
// Top-left corner
VisualLayoutGuide("Top Leading", alignment: .topLeading)

// Bottom edge, centered
VisualLayoutGuide("Bottom", alignment: .bottom)

// Right edge, centered
VisualLayoutGuide("Trailing", alignment: .trailing)
```

## Common Use Cases

### Debugging Layout Issues

```swift
NavigationView {
    VStack {
        VisualLayoutGuide("Content")
    }
    .navigationTitle("Screen")
}
```

Quickly verify that your content respects navigation bar and safe area constraints.

### Comparing Multiple Views

```swift
HStack {
    Color.red
        .overlay { VisualLayoutGuide("Red") }

    Color.blue
        .overlay { VisualLayoutGuide("Blue") }
}
```

See the exact dimensions and insets of each view side-by-side.

### Testing Safe Area Behavior

```swift
ZStack {
    // Respects safe area
    VisualLayoutGuide("In Safe Area")
        .foregroundStyle(.blue)

    // Ignores safe area
    VisualLayoutGuide("Ignoring Safe Area")
        .foregroundStyle(.red)
        .ignoresSafeArea()
}
```

Compare the inset values to verify safe area behavior.

### Prototyping Layouts

```swift
VStack {
    VisualLayoutGuide("Header", alignment: .top)
        .frame(height: 100)

    VisualLayoutGuide("Content")
        .frame(maxHeight: .infinity)

    VisualLayoutGuide("Footer", alignment: .bottom)
        .frame(height: 60)
}
.visualLayoutGuideInteractions(dragEnabled: true, persistenceEnabled: true)
```

Drag overlays around to annotate your prototype without cluttering the layout.

## How It Works

### Overlay Position Coordinator

The `OverlayPositionCoordinator` manages label positioning:

1. Each guide registers its frame in global coordinates
2. The coordinator tracks insertion order (earlier = higher priority)
3. When frames overlap, later guides are offset vertically
4. Manual offsets from dragging are preserved
5. The coordinator recalculates offsets whenever frames or manual offsets change

### Shape Rendering

The guide renders different shapes based on configuration:

**Rectangle:**
```swift
Rectangle()
    .opacity(0.2)
    .border(.primary, width: 3)
```

**ConcentricRectangle (iOS 26+):**
```swift
ConcentricRectangle()
    .opacity(0.2)
    .overlay(ConcentricRectangle().stroke(.primary, lineWidth: 3).padding(1.5))
```

## Performance Considerations

- Uses `onGeometryChange` for efficient size/inset tracking (iOS 17+)
- Overlay position updates only when frames actually change
- Manual offsets bypass collision detection when guides are dragged
- Coordinator caches calculated offsets to avoid redundant recalculation

## Related Documentation

- [Draggable Position View](DraggablePositionView.md) - Track coordinates
- [Visual Grid Guide](VisualGridGuide.md) - Alignment grids
- [Visual Corner Inset Guide](VisualCornerInsetGuide.md) - Container shapes (iOS 26+)
