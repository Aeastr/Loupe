# Visual Grid Guide

A visual debugging overlay that renders a precision square grid fitted to the view's size.

**File:** `Sources/Loupe/VisualGridGuide.swift:17`

## Overview

`VisualGridGuide` overlays a grid of perfectly square cells on your view, helping you:
- Verify alignment and spacing
- Test responsive layouts
- Debug pixel-perfect designs
- Reason about layout using a grid coordinate system

The grid automatically calculates the largest square dimension that divides both width and height without remainder, or you can specify a preferred square size.

## Basic Usage

```swift
import Loupe

struct ContentView: View {
    var body: some View {
        ZStack {
            Color.blue

            VisualGridGuide("Layout Grid")
        }
        .ignoresSafeArea()
    }
}
```

This displays a grid overlay with metrics showing the square size, columns, and rows.

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

**Mode:** `.exact`

Ensures perfect tiling with no remainder. The grid will cover the entire view with no gaps or gutters.

```swift
VisualGridGuide("Exact", squareSize: 8, fit: .exact)
```

**Behavior:**

1. If the requested square size divides width and height evenly, use it
2. Otherwise, fall back to the largest exact square not exceeding the requested size
3. If no square size is provided, calculate the GCD-based optimal square

**Example:**

For a 240×180 view with `squareSize: 8`:
- 240 ÷ 8 = 30 (exact)
- 180 ÷ 8 = 22.5 (not exact)
- Fallback to largest divisor: probably 60 or smaller
- Result: Grid with no gutters

### Preferred Fit

**Mode:** `.preferred`

Prioritizes the requested square size while keeping the grid centered. Allows small gutters if the square size doesn't divide evenly.

```swift
VisualGridGuide("Preferred", squareSize: 12, fit: .preferred)
```

**Behavior:**

1. Calculate columns and rows by rounding `width ÷ squareSize` and `height ÷ squareSize`
2. Adjust square size to fit: `min(width ÷ columns, height ÷ rows)`
3. Center the grid, leaving equal margins on all sides
4. Display remainder in metrics

**Example:**

For a 312×168 view with `squareSize: 12`:
- Columns: round(312 ÷ 12) = 26
- Rows: round(168 ÷ 12) = 14
- Adjusted square: min(312 ÷ 26, 168 ÷ 14) = 12pt
- Grid: 26 × 14 with 0pt remainder

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

### Fullscreen Grid

```swift
VisualGridGuide("Fullscreen", squareSize: 8, fit: .preferred)
    .foregroundStyle(.white.opacity(0.2))
    .ignoresSafeArea()
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

**Example:**

For a 240×180 view:
1. GCD(240, 180) = 60
2. Columns = 240 ÷ 60 = 4
3. Rows = 180 ÷ 60 = 3
4. Square size = 60pt

### Precision Scaling

To handle fractional dimensions, the algorithm scales values by 1000 before computing the GCD:

```swift
let precisionScale: CGFloat = 1000
let widthUnits = Int(round(width * precisionScale))
let heightUnits = Int(round(height * precisionScale))
let gcdUnits = greatestCommonDivisor(widthUnits, heightUnits)
let baseSquareSize = CGFloat(gcdUnits) / precisionScale
```

This preserves three decimal places of precision.

### Canvas Rendering

The grid is drawn efficiently using `Canvas`:

```swift
Canvas { context, size in
    var gridPath = Path()

    // Vertical lines
    for column in 0...metrics.columns {
        let x = startX + CGFloat(column) * squareSize
        gridPath.move(to: CGPoint(x: x, y: startY))
        gridPath.addLine(to: CGPoint(x: x, y: endY))
    }

    // Horizontal lines
    for row in 0...metrics.rows {
        let y = startY + CGFloat(row) * squareSize
        gridPath.move(to: CGPoint(x: startX, y: y))
        gridPath.addLine(to: CGPoint(x: endX, y: y))
    }

    context.stroke(gridPath, with: .style(.primary), lineWidth: lineWidth / displayScale)
}
```

Line width is adjusted for display scale to maintain consistent appearance on retina displays.

### Metrics Overlay

The info panel displays:

```swift
VStack(alignment: .leading, spacing: 4) {
    if let label {
        Text(label)
            .font(.system(size: 11, weight: .semibold, design: .monospaced))
    }

    Text("square: \(String(format: "%.2f", squareSize))pt")
    Text("grid: \(columns) × \(rows)")

    // For preferred fit with remainder
    if fitMode == .preferred {
        Text("remainder: W \(horizontalRemainder) / H \(verticalRemainder)")
    }
}
```

### Dynamic Updates

The grid recalculates when the view size changes:

```swift
.onGeometryChange(for: CGSize.self) { proxy in
    proxy.size
} action: { newSize in
    metrics = calculateGridMetrics(for: newSize, squareSize: squareSize, fit: fit)
}
```

## Performance Considerations

- Grid calculations are cached and only recomputed when size changes
- Canvas rendering is hardware-accelerated
- Line width scales with display scale for optimal rendering
- Metrics overlay uses minimal UI elements

## Advanced Usage

### Multiple Grid Sizes

```swift
ZStack {
    // 32pt major grid
    VisualGridGuide("Major", squareSize: 32, fit: .preferred)
        .foregroundStyle(.blue.opacity(0.15))

    // 8pt minor grid
    VisualGridGuide("Minor", squareSize: 8, fit: .preferred)
        .foregroundStyle(.blue.opacity(0.05))
}
```

### Custom Line Width

```swift
// Thicker lines for visibility
VisualGridGuide("Thick", lineWidth: 2, squareSize: 16, fit: .exact)

// Hairline for precision
VisualGridGuide("Hairline", lineWidth: 0.5, squareSize: 4, fit: .exact)
```

### Conditional Grid

```swift
#if DEBUG
ZStack {
    MyView()

    if showGrid {
        VisualGridGuide("Debug Grid", squareSize: 8, fit: .preferred)
            .foregroundStyle(.red.opacity(0.2))
            .allowsHitTesting(false)
    }
}
#else
MyView()
#endif
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

### Accessibility

The grid includes accessibility support:

```swift
.accessibilityLabel("Visual grid guide")
.accessibilityValue(metricsDescription)
```

VoiceOver will announce: "Visual grid guide, 30 columns, 40 rows, square size 8.00 points"

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

### Grid Shifts on Rotation

The grid recalculates automatically when view size changes, so rotation is handled correctly. However, metrics will change as aspect ratio changes.

## Related Documentation

- [Visual Layout Guide](Visual-Layout-Guide) - Inspect bounds and insets
- [Draggable Position View](Draggable-Position-View) - Track coordinates
- [API Reference](API-Reference) - Complete API documentation
