# Loupe - Visual Grid Guide

A visual debugging overlay that renders a precision square grid fitted to the view's size.

## Quick Start

```swift
import Loupe

ZStack {
    Color.blue

    VisualGridGuide("Layout Grid")
}
.ignoresSafeArea()
```

## Overview

`VisualGridGuide` overlays a grid of perfectly square cells on your view, helping you:
- Verify alignment and spacing
- Test responsive layouts
- Debug pixel-perfect designs
- Reason about layout using a grid coordinate system

The grid automatically calculates the largest square dimension that divides both width and height without remainder, or you can specify a preferred square size.

## Features

### Automatic Square Calculation

By default, the grid calculates the optimal square size using the greatest common divisor (GCD) of the view's width and height:

```swift
VisualGridGuide("Auto Grid")
```

For a 240×180 view:
- GCD(240, 180) = 60
- Square size: 60pt
- Grid: 4 columns × 3 rows

### Custom Square Size

Specify a preferred square size:

```swift
// Exact fit (must divide width and height evenly)
VisualGridGuide("8pt Grid", squareSize: 8, fit: .exact)

// Preferred fit (centers grid, allows small gutters)
VisualGridGuide("12pt Grid", squareSize: 12, fit: .preferred)
```

### Grid Metrics Display

The overlay shows:
- **Square size** - Side length of each square in points
- **Grid dimensions** - Number of columns × rows
- **Remainder** - Unused space (preferred fit only)
- **Optional label** - Custom identifier

### Fit Modes

```swift
public enum VisualGridGuideFit: Equatable {
    case exact     // Perfect tiling, no remainder
    case preferred // Prioritize square size, allow gutters
}
```

## Initialization

```swift
public init(
    _ label: String? = nil,
    lineWidth: CGFloat = 1,
    squareSize: CGFloat? = nil,
    fit: VisualGridGuideFit = .exact
)
```

### Parameters

- **`label`** - Optional caption displayed with the metrics overlay
- **`lineWidth`** - Logical stroke width for grid lines (default: `1`, auto-adjusted for display scale)
- **`squareSize`** - Preferred square side-length in points (default: `nil`, auto-calculate)
- **`fit`** - Strategy for reconciling square size with available dimensions (default: `.exact`)

## Fit Strategies

### Exact Fit

Ensures perfect tiling with no remainder. The grid will cover the entire view with no gaps or gutters.

```swift
VisualGridGuide("Exact", squareSize: 8, fit: .exact)
```

**Behavior:**
1. If the requested square size divides width and height evenly, use it
2. Otherwise, fall back to the largest exact square not exceeding the requested size
3. If no square size is provided, calculate the GCD-based optimal square

### Preferred Fit

Prioritizes the requested square size while keeping the grid centered. Allows small gutters if the square size doesn't divide evenly.

```swift
VisualGridGuide("Preferred", squareSize: 12, fit: .preferred)
```

**Behavior:**
1. Calculate columns and rows by rounding `width ÷ squareSize` and `height ÷ squareSize`
2. Adjust square size to fit: `min(width ÷ columns, height ÷ rows)`
3. Center the grid, leaving equal margins on all sides
4. Display remainder in metrics

## Common Use Cases

### 8-Point Grid System

Many design systems use 8pt spacing:

```swift
VisualGridGuide("8pt System", squareSize: 8, fit: .exact)
    .foregroundStyle(.blue.opacity(0.3))
    .ignoresSafeArea()
```

### Responsive Grid Overlay

Let the grid adapt to any size:

```swift
GeometryReader { proxy in
    VisualGridGuide("Adaptive")
}
.frame(width: 320, height: 240)
```

### Alignment Verification

Overlay a grid to verify that elements align to your grid system:

```swift
ZStack {
    // Your UI
    VStack(spacing: 16) {
        Text("Header").padding(8)
        Text("Content").padding(8)
    }

    // Debug grid
    VisualGridGuide("Alignment Check", squareSize: 8, fit: .preferred)
        .foregroundStyle(.red.opacity(0.3))
        .allowsHitTesting(false)
}
```

### Color-Coded Grids

```swift
ZStack {
    VisualGridGuide("Coarse", squareSize: 32, fit: .preferred)
        .foregroundStyle(.blue.opacity(0.2))

    VisualGridGuide("Fine", squareSize: 8, fit: .preferred)
        .foregroundStyle(.red.opacity(0.1))
}
```

### Grid with Toggle

```swift
struct DebugGridView: View {
    @State private var showGrid = false

    var body: some View {
        ZStack {
            MyContentView()

            if showGrid {
                VisualGridGuide("8pt Grid", squareSize: 8, fit: .preferred)
                    .foregroundStyle(.white.opacity(0.2))
                    .allowsHitTesting(false)
            }
        }
        .onTapGesture(count: 3) {
            showGrid.toggle()
        }
    }
}
```

Triple-tap to toggle the grid overlay.

## How It Works

### GCD-Based Calculation

When no square size is provided, the grid uses the greatest common divisor (GCD) to find the largest square that tiles perfectly:

```swift
private func greatestCommonDivisor(_ lhs: Int, _ rhs: Int) -> Int {
    var a = abs(lhs)
    var b = abs(rhs)

    while b != 0 {
        let remainder = a % b
        a = b
        b = remainder
    }

    return a
}
```

### Canvas Rendering

The grid is drawn efficiently using `Canvas`:
- Grid calculations are cached and only recomputed when size changes
- Canvas rendering is hardware-accelerated
- Line width scales with display scale for optimal rendering

## Performance Considerations

- Grid calculations are cached and only recomputed when size changes
- Canvas rendering is hardware-accelerated
- Line width scales with display scale for optimal rendering
- Metrics overlay uses minimal UI elements

## Troubleshooting

### Grid Too Fine

If the calculated square is too small:

```swift
// Force a larger square size
VisualGridGuide("Coarse", squareSize: 16, fit: .preferred)
```

### Grid Doesn't Align

For exact alignment with no remainder:

```swift
VisualGridGuide("Exact Alignment", squareSize: 8, fit: .exact)
```

Note: `.exact` may fall back to a different square size if your requested size doesn't divide evenly.

### Grid Not Visible

Check foreground style and line width:

```swift
VisualGridGuide("Visible", squareSize: 8, fit: .preferred)
    .foregroundStyle(.red)           // Change color
    .opacity(0.5)                    // Adjust opacity
```

## Related Documentation

- [Visual Layout Guide](VisualLayoutGuide.md) - Inspect bounds and insets
- [Draggable Position View](DraggablePositionView.md) - Track coordinates
