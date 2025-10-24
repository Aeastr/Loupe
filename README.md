<div align="center">
  <img width="200" height="200" src="/assets/icon.png" alt="Loupe">
  <h1>Loupe</h1>
  <p>A SwiftUI debugging toolkit for visualizing renders, layouts, and measurements.</p>
</div>

<div align="center">
  <a href="https://swift.org">
    <img src="https://img.shields.io/badge/Swift-6-orange.svg" alt="Swift 6">
  </a>
  <a href="https://www.apple.com/ios/">
    <img src="https://img.shields.io/badge/iOS-17%2B-blue.svg" alt="iOS">
  </a>
  <a href="https://www.apple.com/macos/">
    <img src="https://img.shields.io/badge/macOS-14%2B-blue.svg" alt="macOS">
  </a>
  <a href="https://www.apple.com/tvos/">
    <img src="https://img.shields.io/badge/tvOS-17%2B-blue.svg" alt="tvOS">
  </a>
  <a href="https://www.apple.com/visionos/">
    <img src="https://img.shields.io/badge/visionOS-1%2B-purple.svg" alt="visionOS">
  </a>
  <a href="https://www.apple.com/watchos/">
    <img src="https://img.shields.io/badge/watchOS-10%2B-red.svg" alt="watchOS">
  </a>
  <a href="https://github.com/Aeastr/Loupe/wiki">
    <img src="https://img.shields.io/badge/docs-wiki-blue.svg" alt="Documentation">
  </a>
  <a href="LICENSE">
    <img src="https://img.shields.io/badge/license-MIT-green.svg" alt="MIT License">
  </a>
</div>

---

## Overview

Loupe provides runtime debugging tools for SwiftUI applications. Visualize render cycles, inspect layout bounds, track positions, and overlay precision grids—all with minimal setup.

**[Read the full documentation →](https://github.com/Aeastr/Loupe/wiki)**

---

## Installation

### Swift Package Manager

```
https://github.com/Aeastr/Loupe.git
```

Add via Xcode: **File → Add Packages** and paste the URL above.

---

## Quick Start

### Render Debugging

See when views re-render or re-compute:

```swift
import Loupe

Text("Count: \(count)")
    .debugRender()      // Shows re-renders with colored backgrounds
    .debugCompute()     // Shows re-computations with red flashes
```

**[Learn more about render debugging →](https://github.com/Aeastr/Loupe/wiki/Render-Debugging)**

---

### Layout Inspection

Display bounds, safe area insets, and dimensions:

```swift
ZStack {
    Color.blue
        .overlay {
            VisualLayoutGuide("Content Area")
        }
}
```

Enable dragging and persistence:

```swift
VisualLayoutGuide("Debug View")
    .visualLayoutGuideInteractions(dragEnabled: true, persistenceEnabled: true)
```

**[Learn more about layout guides →](https://github.com/Aeastr/Loupe/wiki/Visual-Layout-Guide)**

---

### Position Tracking

Monitor coordinates with draggable overlays:

```swift
DraggablePositionView("Tracker")
    .draggablePositionViewInteractions(dragEnabled: true)
```

**[Learn more about position tracking →](https://github.com/Aeastr/Loupe/wiki/Draggable-Position-View)**

---

### Grid Overlays

Add precision alignment grids:

```swift
VisualGridGuide("8pt Grid", squareSize: 8, fit: .exact)
    .ignoresSafeArea()
```

**[Learn more about grid guides →](https://github.com/Aeastr/Loupe/wiki/Visual-Grid-Guide)**

---

## Features

**Render Debugging**
- `.debugRender()` - Visualize re-renders
- `.debugCompute()` - Visualize re-computations
- `RenderCheck` - Batch debugging wrapper

**Layout Inspection**
- `VisualLayoutGuide` - Bounds, insets, and dimensions
- `DraggablePositionView` - Coordinate tracking
- `VisualGridGuide` - Alignment grids

**Container Shapes (iOS 26+)**
- `VisualCornerInsetGuide` - ConcentricRectangle visualization

**[View all features →](https://github.com/Aeastr/Loupe/wiki)**

---

## Production Builds

All debugging tools are conditionally compiled with `#if DEBUG`. They are automatically excluded from release builds—no manual cleanup required.

---

## Documentation

- **[Wiki Home](https://github.com/Aeastr/Loupe/wiki)** - Complete documentation
- **[Render Debugging](https://github.com/Aeastr/Loupe/wiki/Render-Debugging)** - debugRender(), debugCompute(), RenderCheck
- **[Visual Layout Guide](https://github.com/Aeastr/Loupe/wiki/Visual-Layout-Guide)** - Bounds and inset inspection
- **[Draggable Position View](https://github.com/Aeastr/Loupe/wiki/Draggable-Position-View)** - Position tracking
- **[Visual Grid Guide](https://github.com/Aeastr/Loupe/wiki/Visual-Grid-Guide)** - Grid overlays
- **[API Reference](https://github.com/Aeastr/Loupe/wiki/API-Reference)** - Complete API documentation

---

## License

MIT License. See [LICENSE](LICENSE) for details.

---

<p align="center">by <a href="https://github.com/Aeastr">Aether</a></p>
