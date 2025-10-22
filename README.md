<div align="center">
  <img width="270" height="270" src="/assets/icon.png" alt="Loupe Logo">
  <h1><b>Loupe</b></h1>
  <p>
    A comprehensive SwiftUI debugging toolkit for visualizing renders, layouts, and measurements.
  </p>
</div>

<div align="center">
  <a href="https://swift.org">
    <img src="https://img.shields.io/badge/Swift-6-orange.svg" alt="Swift Version">
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
  <a href="LICENSE">
    <img src="https://img.shields.io/badge/License-MIT-green.svg" alt="License: MIT">
  </a>
</div>

---

## **Overview**

**Loupe** is a SwiftUI debugging toolkit that helps you inspect, measure, and understand your UI at runtime. Like looking through a jeweler's loupe, it provides precise visibility into layout behavior, rendering patterns, and view geometry.

### What Can Loupe Do?

- 🎨 **Visualize render cycles** - See exactly when SwiftUI re-renders or re-computes views
- 📐 **Measure layouts** - Display bounds, safe area insets, and precise dimensions
- 📍 **Track positions** - Monitor coordinate positions with draggable overlays
- 🔲 **Analyze grids** - Overlay perfect square grids for alignment checking
- 🎯 **Debug container shapes** - Visualize ConcentricRectangle behavior (iOS 26+)

---

## **Installation**

### Swift Package Manager

1. In Xcode, navigate to **File > Add Packages...**
2. Enter the repository URL:
   `https://github.com/Aeastr/SwiftUI-Loupe.git`
3. Follow the prompts to add the package to your project.

---

## **Features**

### 🎨 Render Debugging

#### `.debugRender()` - Visualize Re-renders

Shows when SwiftUI re-renders a view by applying a random colored background that changes on each re-render.

```swift
Text("Count: \(count)")
    .debugRender()
```

SwiftUI **re-computes a view's `body` whenever its state changes**, but that **doesn't mean it rebuilds the entire UI**. SwiftUI uses a diffing system to compare the new view hierarchy with the old one, updating only the parts that have actually changed.

#### `.debugCompute()` - Visualize Re-computations

Shows when SwiftUI recreates/reinitializes a view by briefly flashing it red.

```swift
TextField("Search...", text: $searchText)
    .debugCompute()
```

The view flashes because SwiftUI creates a new view instance for each state change.

#### `RenderCheck` - Batch Render Debugging

Applies render debugging to all subviews automatically.

```swift
RenderCheck {
    VStack {
        Text("View 1")
        Text("View 2")
        Text("View 3")
    }
}
```

---

### 📐 Layout Inspection

#### `VisualLayoutGuide` - Complete Layout Information

A comprehensive debugging overlay showing bounds, safe area insets, and dimensions.

```swift
ZStack {
    Color.blue
        .overlay {
            VisualLayoutGuide("Content Area")
        }
}
```

**Features:**
- Visual bounds with semi-transparent overlay
- Real-time size display (width × height)
- Safe area inset visualization
- Configurable alignment
- Automatic collision avoidance for multiple guides
- Draggable with persistence support

**Advanced Usage:**

```swift
// Multiple guides with automatic stacking
ZStack {
    VisualLayoutGuide("View 1")
    VisualLayoutGuide("View 2")
    VisualLayoutGuide("View 3")
}

// Enable dragging and persistence
VStack {
    VisualLayoutGuide("Primary", persistenceKey: "primary-guide")
}
.visualLayoutGuideInteractions(dragEnabled: true, persistenceEnabled: true)

// Test safe area behavior
ZStack {
    VisualLayoutGuide("In Safe Area")

    VisualLayoutGuide("Ignoring Safe Area")
        .ignoresSafeArea()
}
```

---

### 📍 Position Tracking

#### `DraggablePositionView` - Coordinate Monitoring

A draggable overlay that displays precise x/y coordinates and can be repositioned for testing.

```swift
ZStack {
    Color.blue
        .overlay {
            DraggablePositionView("Position Tracker")
        }
}
.draggablePositionViewInteractions(dragEnabled: true)
```

**Features:**
- Real-time coordinate display
- Drag gesture support
- Coordinate space options (local, named, global)
- Constraint system (horizontal/vertical only)
- Persistence via UserDefaults

**Advanced Usage:**

```swift
// Track global position
DraggablePositionView(
    "Global Coords",
    coordinateSpace: .global
)

// Constrain to horizontal axis
DraggablePositionView("Horizontal Only")
    .draggablePositionViewConstraints(.horizontal)

// With persistence
DraggablePositionView("Persistent", persistenceKey: "main-tracker")
    .draggablePositionViewInteractions(
        dragEnabled: true,
        persistenceEnabled: true,
        persistenceNamespace: "debug"
    )
```

---

### 🔲 Grid Overlay

#### `VisualGridGuide` - Alignment Grid

Renders a perfect square grid overlay with automatic size calculation.

```swift
VisualGridGuide("Layout Grid")
    .frame(width: 300, height: 200)
```

**Features:**
- Automatic GCD-based grid calculation
- Preferred square size with `.exact` or `.preferred` fit modes
- Displays grid metrics (columns, rows, square size)
- Adjustable line width

**Advanced Usage:**

```swift
// Exact fit with specific square size
VisualGridGuide("8pt Grid", squareSize: 8, fit: .exact)

// Preferred fit (allows small gutters)
VisualGridGuide("12pt Grid", squareSize: 12, fit: .preferred)

// Fullscreen grid
VisualGridGuide("Fullscreen", squareSize: 8, fit: .preferred)
    .ignoresSafeArea()
```

---

### 🎯 Container Shape Debugging (iOS 26+)

#### `VisualCornerInsetGuide` - ConcentricRectangle Visualization

Shows how ConcentricRectangle responds to container shapes.

```swift
@available(iOS 26.0, macOS 26.0, *)
VisualCornerInsetGuide("Container Shape")
    .frame(width: 220, height: 160)
    .containerShape(RoundedRectangle(cornerRadius: 24))
```

---

## **Debugging vs. Production**

> **Important:** Loupe is a development utility intended solely for **debugging purposes**. Debug tools are conditionally compiled using Swift's `#if DEBUG` directive. This means that in production builds, the debugging code is automatically excluded, ensuring that your app remains lean without any unintended visual effects or performance overhead.

> Please ensure that your project's build settings correctly define the DEBUG flag for development configurations.

---

## **Example Workflows**

### Performance Debugging

Identify unnecessary re-renders:

```swift
struct CounterView: View {
    @State private var count = 0

    var body: some View {
        VStack {
            // This will re-render on every count change
            Text("Count: \(count)")
                .debugRender()

            // This should NOT re-render
            Text("Static Label")
                .debugRender()

            Button("Increment") { count += 1 }
        }
    }
}
```

### Layout Testing

Test safe area and bounds:

```swift
ZStack {
    VisualLayoutGuide("Safe Area")
        .foregroundStyle(.blue)

    VisualLayoutGuide("Full Screen")
        .foregroundStyle(.red)
        .ignoresSafeArea()
}
.visualLayoutGuideInteractions(dragEnabled: true)
```

### Grid Alignment

Verify pixel-perfect alignment:

```swift
ZStack {
    VisualGridGuide("8pt Grid", squareSize: 8, fit: .exact)
        .foregroundStyle(.gray.opacity(0.3))

    // Your content here
    VStack(spacing: 8) {
        ForEach(0..<5) { _ in
            RoundedRectangle(cornerRadius: 8)
                .fill(.blue)
                .frame(height: 40)
        }
    }
    .padding(8)
}
```

---

## **Key Components**

### Render Debugging
- **DebugRender** - Canvas-based random color overlay on re-renders
- **DebugCompute** - Red flash animation on view re-initialization
- **RenderCheck** - Batch wrapper for subview render debugging

### Layout Inspection
- **VisualLayoutGuide** - Comprehensive bounds/inset/size visualization
- **DraggablePositionView** - Coordinate tracking with drag support
- **VisualGridGuide** - Square grid overlay with smart sizing

### Container Debugging (iOS 26+)
- **VisualCornerInsetGuide** - ConcentricRectangle shape visualization

### Infrastructure
- **OverlayPositionCoordinator** - Automatic collision avoidance for overlays
- **ConcentricRectangle** - Container-aware shape (with iOS 15+ fallback)
- **LoupeGlassEffect** - Standalone glass material backgrounds

---

## **Platform Support**

- **iOS** 17.0+
- **macOS** 14.0+
- **tvOS** 17.0+
- **watchOS** 10.0+
- **visionOS** 1.0+

---

## **License**

Loupe is available under the MIT license. See the [LICENSE](LICENSE) file for more information.

---

<p align="center">Built with 🔍 by Aether</p>
