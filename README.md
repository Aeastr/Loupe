<div align="center">
  <img width="128" height="128" src="/resources/icon.png" alt="Loupe Icon">
  <h1><b>Loupe</b></h1>
  <p>
    A SwiftUI debugging toolkit for visualizing renders, layouts, and measurements.
  </p>
</div>

<p align="center">
  <a href="https://swift.org"><img src="https://img.shields.io/badge/Swift-6.0+-F05138?logo=swift&logoColor=white" alt="Swift 6.0+"></a>
  <a href="https://developer.apple.com"><img src="https://img.shields.io/badge/iOS-17+-000000?logo=apple" alt="iOS 17+"></a>
  <a href="https://developer.apple.com"><img src="https://img.shields.io/badge/macOS-14+-000000?logo=apple" alt="macOS 14+"></a>
  <a href="https://developer.apple.com"><img src="https://img.shields.io/badge/tvOS-17+-000000?logo=apple" alt="tvOS 17+"></a>
  <a href="https://developer.apple.com"><img src="https://img.shields.io/badge/watchOS-10+-000000?logo=apple" alt="watchOS 10+"></a>
  <a href="https://developer.apple.com"><img src="https://img.shields.io/badge/visionOS-1+-000000?logo=apple" alt="visionOS 1+"></a>
</p>


## Overview

Loupe provides runtime debugging tools for SwiftUI applications. Visualize render cycles, inspect layout bounds, track positions, and overlay precision grids—all with minimal setup and zero impact on production builds.

**Render Debugging**
- `.debugRender()` - Visualize when views re-render with colored backgrounds
- `.debugCompute()` - Visualize when views re-initialize with red flashes
- `RenderCheck` - Batch debugging wrapper for multiple views

**Layout Inspection**
- `VisualLayoutGuide` - Display bounds, safe area insets, and dimensions
- `DraggablePositionView` - Track coordinates with draggable overlays
- `VisualGridGuide` - Overlay precision alignment grids

**Container Shapes (iOS 26+)**
- `VisualCornerInsetGuide` - Visualize ConcentricRectangle and container shapes


## Installation

```swift
dependencies: [
    .package(url: "https://github.com/Aeastr/Loupe.git", from: "1.0.0")
]
```

```swift
import Loupe
```


## Usage

### Render Debugging

See when views re-render or re-compute:

```swift
Text("Count: \(count)")
    .debugRender()      // Shows re-renders with colored backgrounds
    .debugCompute()     // Shows re-computations with red flashes
```

Batch debug multiple views:

```swift
RenderCheck {
    Text("A")
    Text("B")
    Text("C")
}
```

[Full documentation →](docs/RenderDebugging.md)

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

[Full documentation →](docs/VisualLayoutGuide.md)

### Position Tracking

Monitor coordinates with draggable overlays:

```swift
DraggablePositionView("Tracker")
    .draggablePositionViewInteractions(dragEnabled: true)
```

[Full documentation →](docs/DraggablePositionView.md)

### Grid Overlays

Add precision alignment grids:

```swift
VisualGridGuide("8pt Grid", squareSize: 8, fit: .exact)
    .ignoresSafeArea()
```

[Full documentation →](docs/VisualGridGuide.md)

### Container Shapes (iOS 26+)

Visualize ConcentricRectangle and container shapes:

```swift
VisualCornerInsetGuide("Container Shape")
    .padding(20)
    .containerShape(RoundedRectangle(cornerRadius: 32))
```

[Full documentation →](docs/VisualCornerInsetGuide.md)


## How It Works

All debugging tools are conditionally compiled with `#if DEBUG`. They are automatically excluded from release builds—no manual cleanup required, no performance impact in production.

- **debugRender()** uses a `Canvas` that generates a random color on each render
- **debugCompute()** uses a `LocalRenderManager` that triggers a red flash on view initialization
- **VisualLayoutGuide** uses `onGeometryChange` for efficient size/inset tracking with automatic collision detection
- **VisualGridGuide** calculates optimal square sizes using GCD for perfect tiling

[API Reference →](docs/APIReference.md)


## Contributing

Contributions welcome. Please feel free to submit a Pull Request.


## License

MIT. See [LICENSE](LICENSE) for details.
