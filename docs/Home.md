# Loupe

A SwiftUI debugging toolkit for visualizing renders, layouts, and measurements.

## Overview

Loupe provides runtime debugging tools for SwiftUI applications. Visualize render cycles, inspect layout bounds, track positions, and overlay precision grids—all with minimal setup and zero impact on production builds.

All debugging tools are conditionally compiled with `#if DEBUG`, meaning they're automatically excluded from release builds without any manual cleanup.

## Platform Support

- **iOS** 17+
- **macOS** 14+
- **tvOS** 17+
- **visionOS** 1+
- **watchOS** 10+

## Installation

### Swift Package Manager

Add Loupe to your project via Xcode:

1. Go to **File → Add Packages**
2. Paste the repository URL: `https://github.com/Aeastr/Loupe.git`
3. Select the version or branch you want to use

Or add it manually to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/Aeastr/Loupe.git", from: "1.0.0")
]
```

## Quick Start

Import Loupe in your SwiftUI views:

```swift
import Loupe
```

### See When Views Re-Render

```swift
Text("Count: \(count)")
    .debugRender()      // Colored backgrounds on re-render
```

### See When Views Re-Compute

```swift
Text("Count: \(count)")
    .debugCompute()     // Red flash on re-initialization
```

### Inspect Layout Bounds

```swift
ZStack {
    Color.blue
        .overlay {
            VisualLayoutGuide("Content Area")
        }
}
```

### Track Position

```swift
DraggablePositionView("Tracker")
    .draggablePositionViewInteractions(dragEnabled: true)
```

### Add Alignment Grids

```swift
VisualGridGuide("8pt Grid", squareSize: 8, fit: .exact)
    .ignoresSafeArea()
```

## Features

### Render Debugging

- [`.debugRender()`](Render-Debugging#debugrender) - Visualize when views re-render
- [`.debugCompute()`](Render-Debugging#debugcompute) - Visualize when views re-initialize
- [`RenderCheck`](Render-Debugging#rendercheck) - Batch debugging wrapper for multiple views

[→ Full Render Debugging Documentation](Render-Debugging)

### Layout Inspection

- [`VisualLayoutGuide`](Visual-Layout-Guide) - Display bounds, safe area insets, and dimensions
- [`DraggablePositionView`](Draggable-Position-View) - Track coordinates with draggable overlays
- [`VisualGridGuide`](Visual-Grid-Guide) - Overlay precision alignment grids

[→ Layout Tools Overview](#layout-tools)

### Container Shapes (iOS 26+)

- [`VisualCornerInsetGuide`](Visual-Corner-Inset-Guide) - Visualize ConcentricRectangle and container shapes

## Layout Tools

### VisualLayoutGuide

Displays a semi-transparent overlay showing:
- View bounds with border
- Width and height measurements
- Safe area insets (top, leading, bottom, trailing)
- Optional label for identification

**Features:**
- Automatic collision detection and stacking
- Draggable overlays (opt-in)
- Persistent positions with UserDefaults
- Multiple shape styles (rectangle, concentric rectangle on iOS 26+)

[→ Full Documentation](Visual-Layout-Guide)

### DraggablePositionView

A draggable overlay that displays:
- Current x, y coordinates
- Configurable coordinate space (local, named, global)
- Size information
- Optional label

**Features:**
- Optional drag gesture
- Constraint system (horizontal-only, vertical-only, custom ranges)
- Position change callbacks
- Persistent positions

[→ Full Documentation](Draggable-Position-View)

### VisualGridGuide

A precision grid overlay for alignment testing:
- Automatic square calculation based on GCD
- Custom square sizes with exact or preferred fit modes
- Grid metrics display (columns, rows, square size)
- Configurable line width

[→ Full Documentation](Visual-Grid-Guide)

### VisualCornerInsetGuide (iOS 26+)

Visualizes container shapes and corner radius:
- Renders ConcentricRectangle that respects container shape
- Displays view dimensions
- Perfect for testing `containerShape()` modifiers

[→ Full Documentation](Visual-Corner-Inset-Guide)

## Production Builds

All Loupe debugging tools are wrapped in `#if DEBUG` conditionals. They are automatically excluded from release builds, so there's no performance impact and no need to remove debug code before shipping.

## Documentation

- **[Render Debugging](Render-Debugging)** - debugRender(), debugCompute(), RenderCheck
- **[Visual Layout Guide](Visual-Layout-Guide)** - Bounds and inset inspection
- **[Draggable Position View](Draggable-Position-View)** - Position tracking
- **[Visual Grid Guide](Visual-Grid-Guide)** - Grid overlays
- **[Visual Corner Inset Guide](Visual-Corner-Inset-Guide)** - Container shape visualization
- **[API Reference](API-Reference)** - Complete API documentation

## Examples

Check out the preview sections in each source file for working examples, or refer to the individual documentation pages for comprehensive usage examples.

## License

MIT License. See [LICENSE](../LICENSE) for details.
