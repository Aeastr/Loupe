# API Reference

Complete API documentation for Loupe.

## Table of Contents

- [Render Debugging](#render-debugging)
  - [debugRender()](#debugrender)
  - [debugCompute()](#debugcompute)
  - [RenderCheck](#rendercheck)
- [Layout Inspection](#layout-inspection)
  - [VisualLayoutGuide](#visuallayoutguide)
  - [DraggablePositionView](#draggablepositionview)
  - [VisualGridGuide](#visualgridguide)
  - [VisualCornerInsetGuide](#visualcornerinsetguide-ios-26)
- [Supporting Types](#supporting-types)
  - [ConcentricRectangle](#concentricrectangle)
  - [LoupeGlassEffect](#loupeglasseffect)
- [Environment Keys](#environment-keys)

---

## Render Debugging

### debugRender()

```swift
@available(iOS 15.0, *)
public extension View {
    func debugRender(enabled: Bool = true) -> some View
}
```

Wraps the view in a debug wrapper that shows redraw updates with colored backgrounds.

**Parameters:**
- `enabled: Bool` - Toggle debug visualization (default: `true`)

**Behavior:**
- Only included in DEBUG builds (`#if DEBUG`)
- Generates a random color on each render
- 40% opacity overlay
- Doesn't block touch events

**Example:**
```swift
Text("Count: \(count)")
    .debugRender()
```

**See:** [Render Debugging Guide](Render-Debugging#debugrender)

---

### debugCompute()

```swift
public extension View {
    func debugCompute(enabled: Bool = true) -> some View
}
```

Wraps the view in a debug wrapper that highlights view re-initialization with red flashes.

**Parameters:**
- `enabled: Bool` - Toggle debug visualization (default: `true`)

**Behavior:**
- Only included in DEBUG builds (`#if DEBUG`)
- Red overlay (30% opacity) on initialization
- Fades out over 0.3 seconds after 0.4 second delay
- Doesn't block touch events

**Example:**
```swift
Text("Count: \(count)")
    .debugCompute()
```

**See:** [Render Debugging Guide](Render-Debugging#debugcompute)

---

### RenderCheck

```swift
@available(iOS 15.0, *)
public struct RenderCheck<Content: View>: View {
    public init(@ViewBuilder content: () -> Content)
    public var body: some View
}
```

A convenience view that applies `.debugRender()` to all subviews.

**Parameters:**
- `content: @ViewBuilder () -> Content` - The views to debug

**Behavior:**
- Uses `Group(subviews:)` on iOS 18+ / macOS 15+ / visionOS 2+ / tvOS 18+ / watchOS 11+
- Falls back to `_VariadicView.Tree` on earlier platforms
- Applies `.debugRender()` to each child view

**Example:**
```swift
RenderCheck {
    Text("A")
    Text("B")
    Text("C")
}
```

**See:** [Render Debugging Guide](Render-Debugging#rendercheck)

---

## Layout Inspection

### VisualLayoutGuide

```swift
public struct VisualLayoutGuide: View {
    public init(
        _ label: String? = nil,
        alignment: Alignment = .center,
        shape: VisualLayoutGuideShape = .rectangle,
        persistenceKey: String? = nil
    )
    public var body: some View
}
```

A visual debugging tool that displays layout bounds, safe area insets, and size information.

**Parameters:**
- `label: String?` - Optional text label for identification
- `alignment: Alignment` - Position of info overlay (default: `.center`)
- `shape: VisualLayoutGuideShape` - Shape style (default: `.rectangle`)
- `persistenceKey: String?` - Optional key for persisting manual offsets

**Features:**
- Displays bounds with semi-transparent overlay (20% opacity)
- Shows width, height, and safe area insets
- Automatic collision detection and label stacking
- Optional drag gestures and persistence
- Choice of rectangle or concentric rectangle (iOS 26+)

**Example:**
```swift
VisualLayoutGuide("Content Area")
```

**See:** [Visual Layout Guide Documentation](Visual-Layout-Guide)

#### VisualLayoutGuideShape

```swift
public enum VisualLayoutGuideShape {
    case rectangle
    @available(iOS 26.0, macOS 26.0, tvOS 26.0, watchOS 26.0, *)
    case concentricRectangle
}
```

Shape style for the layout guide visualization.

#### visualLayoutGuideInteractions

```swift
public extension View {
    func visualLayoutGuideInteractions(
        dragEnabled: Bool,
        persistenceEnabled: Bool,
        persistenceNamespace: String? = nil
    ) -> some View
}
```

Enables or disables dragging/persistence for visual layout guides.

**Parameters:**
- `dragEnabled: Bool` - Enable drag gestures
- `persistenceEnabled: Bool` - Save positions to UserDefaults
- `persistenceNamespace: String?` - Namespace for persistence keys (default: `"VisualLayoutGuide"`)

**Example:**
```swift
VisualLayoutGuide("Draggable", persistenceKey: "main-guide")
    .visualLayoutGuideInteractions(
        dragEnabled: true,
        persistenceEnabled: true,
        persistenceNamespace: "debug"
    )
```

#### visualLayoutGuidePositioning

```swift
public extension View {
    func visualLayoutGuidePositioning(
        _ mode: VisualLayoutGuidePositioningMode
    ) -> some View
}
```

Controls automatic collision detection and label stacking.

**Parameters:**
- `mode: VisualLayoutGuidePositioningMode` - Positioning mode

```swift
public enum VisualLayoutGuidePositioningMode {
    case auto     // Enable collision detection (default)
    case disabled // Disable collision detection
}
```

**Example:**
```swift
VStack {
    VisualLayoutGuide("A")
    VisualLayoutGuide("B")
}
.visualLayoutGuidePositioning(.disabled)
```

---

### DraggablePositionView

```swift
public struct DraggablePositionView: View {
    public init(
        _ label: String? = nil,
        coordinateSpace: DraggablePositionCoordinateSpace = .local,
        startPosition: CGSize = .zero,
        persistenceKey: String? = nil
    )
    public var body: some View
}
```

A visual debugging tool that displays position and allows dragging.

**Parameters:**
- `label: String?` - Optional text label
- `coordinateSpace: DraggablePositionCoordinateSpace` - Coordinate space for position (default: `.local`)
- `startPosition: CGSize` - Initial offset (default: `.zero`)
- `persistenceKey: String?` - Optional key for persisting offsets

**Features:**
- Displays x, y coordinates
- Optional drag gestures
- Constraint system for limiting drag
- Persistent positions across launches
- Smart label positioning (flips when near screen edge)

**Example:**
```swift
DraggablePositionView("Tracker")
    .draggablePositionViewInteractions(dragEnabled: true)
```

**See:** [Draggable Position View Documentation](Draggable-Position-View)

#### DraggablePositionCoordinateSpace

```swift
public enum DraggablePositionCoordinateSpace: Equatable, Sendable {
    case local
    case named(String)
    case global
}
```

Coordinate space for position reporting.

**Example:**
```swift
DraggablePositionView("Global", coordinateSpace: .global)
```

#### DragConstraints

```swift
public struct DragConstraints: Equatable, Sendable {
    public var horizontalRange: ClosedRange<CGFloat>?
    public var verticalRange: ClosedRange<CGFloat>?
    public var horizontalOnly: Bool
    public var verticalOnly: Bool

    public init(
        horizontalRange: ClosedRange<CGFloat>? = nil,
        verticalRange: ClosedRange<CGFloat>? = nil,
        horizontalOnly: Bool = false,
        verticalOnly: Bool = false
    )

    public static let none: DragConstraints
    public static let horizontal: DragConstraints
    public static let vertical: DragConstraints
}
```

Constraints for dragging behavior.

**Example:**
```swift
DraggablePositionView("Constrained")
    .draggablePositionViewInteractions(dragEnabled: true)
    .draggablePositionViewConstraints(.horizontal)
```

#### draggablePositionViewInteractions

```swift
public extension View {
    func draggablePositionViewInteractions(
        dragEnabled: Bool,
        persistenceEnabled: Bool = false,
        persistenceNamespace: String? = nil
    ) -> some View
}
```

Enables or disables dragging/persistence for draggable position views.

**Parameters:**
- `dragEnabled: Bool` - Enable drag gestures
- `persistenceEnabled: Bool` - Save positions to UserDefaults (default: `false`)
- `persistenceNamespace: String?` - Namespace for persistence keys (default: `"DraggablePositionView"`)

**Example:**
```swift
DraggablePositionView("Point A", persistenceKey: "point-a")
    .draggablePositionViewInteractions(dragEnabled: true, persistenceEnabled: true)
```

#### draggablePositionViewConstraints

```swift
public extension View {
    func draggablePositionViewConstraints(
        _ constraints: DragConstraints
    ) -> some View
}
```

Configures drag constraints.

**Example:**
```swift
DraggablePositionView("Horizontal Only")
    .draggablePositionViewConstraints(.horizontal)
```

---

### VisualGridGuide

```swift
public struct VisualGridGuide: View {
    public init(
        _ label: String? = nil,
        lineWidth: CGFloat = 1,
        squareSize: CGFloat? = nil,
        fit: VisualGridGuideFit = .exact
    )
    public var body: some View
}
```

A visual debugging overlay that renders a square grid.

**Parameters:**
- `label: String?` - Optional caption for the metrics overlay
- `lineWidth: CGFloat` - Stroke width for grid lines (default: `1`, auto-adjusted for display scale)
- `squareSize: CGFloat?` - Preferred square side-length (default: `nil`, auto-calculate)
- `fit: VisualGridGuideFit` - Fit strategy (default: `.exact`)

**Features:**
- Automatic GCD-based square calculation
- Custom square sizes with exact or preferred fit
- Displays grid metrics (columns, rows, square size, remainder)
- Scales line width for retina displays

**Example:**
```swift
VisualGridGuide("8pt Grid", squareSize: 8, fit: .exact)
```

**See:** [Visual Grid Guide Documentation](Visual-Grid-Guide)

#### VisualGridGuideFit

```swift
public enum VisualGridGuideFit: Equatable {
    case exact     // Perfect tiling, no remainder
    case preferred // Prioritize square size, allow gutters
}
```

Strategy for reconciling square size with available dimensions.

**Example:**
```swift
VisualGridGuide("Preferred 12", squareSize: 12, fit: .preferred)
```

---

### VisualCornerInsetGuide (iOS 26+)

```swift
@available(iOS 26.0, macOS 26.0, *)
public struct VisualCornerInsetGuide: View {
    public init(_ label: String? = nil)
    public var body: some View
}
```

A visual debugging overlay that shows container shapes and dimensions.

**Parameters:**
- `label: String?` - Optional caption for the metrics overlay

**Features:**
- Renders `ConcentricRectangle` (50% opacity)
- Respects container shape modifiers
- Displays view size (width × height)
- Perfect for testing `containerShape()` and presentation corner radius

**Example:**
```swift
if #available(iOS 26.0, *) {
    VisualCornerInsetGuide("Container")
        .containerShape(RoundedRectangle(cornerRadius: 24))
}
```

**See:** [Visual Corner Inset Guide Documentation](Visual-Corner-Inset-Guide)

---

## Supporting Types

### ConcentricRectangle

```swift
@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
public struct ConcentricRectangle: Shape, InsettableShape {
    public init()
    public func path(in rect: CGRect) -> Path
    public func inset(by amount: CGFloat) -> some InsettableShape
}
```

A rectangle shape that respects the container's shape and corner radius.

**Features:**
- Conforms to `Shape` and `InsettableShape`
- On iOS 26+, uses native `ConcentricRectangle` behavior
- On earlier platforms, falls back to standard rectangle
- Supports stroke, fill, and inset operations

**Example:**
```swift
ConcentricRectangle()
    .fill(.blue.opacity(0.2))
```

**See:** [Visual Corner Inset Guide - ConcentricRectangle Details](Visual-Corner-Inset-Guide#concentricrectangle-details)

---

### LoupeGlassEffect

```swift
extension View {
    func loupeGlassEffect<S: Shape>(_ material: Material = .regular, in shape: S) -> some View
    func loupeGlassEffect(_ material: Material = .regular, cornerRadius: CGFloat) -> some View
}
```

Applies a glass-like material background with the specified shape or corner radius.

**Parameters:**
- `material: Material` - The material style (default: `.regular`)
- `shape: S` - Shape to apply material to
- `cornerRadius: CGFloat` - Corner radius for rounded rectangle

**Example:**
```swift
Text("Hello")
    .padding()
    .loupeGlassEffect(.thin, cornerRadius: 12)
```

**Internal Use:**
Used by `VisualLayoutGuide` and `DraggablePositionView` for info overlays.

---

## Environment Keys

### overlayCoordinator

```swift
extension EnvironmentValues {
    var overlayCoordinator: OverlayPositionCoordinator
}
```

The coordinator that manages overlay positioning for `VisualLayoutGuide`.

**Default:** Shared global coordinator

**Usage:**
```swift
.environment(\.overlayCoordinator, OverlayPositionCoordinator())
```

Inject a custom coordinator to isolate collision detection to a specific view hierarchy.

---

### visualLayoutGuidePositioning

```swift
extension EnvironmentValues {
    var visualLayoutGuidePositioning: VisualLayoutGuidePositioningMode
}
```

Controls automatic collision detection for `VisualLayoutGuide`.

**Default:** `.auto`

**Usage:**
```swift
.environment(\.visualLayoutGuidePositioning, .disabled)
```

---

### visualLayoutGuideInteractions

```swift
extension EnvironmentValues {
    var visualLayoutGuideInteractions: VisualLayoutGuideInteractionsConfiguration
}
```

Configuration for dragging and persistence behavior.

**Default:** `VisualLayoutGuideInteractionsConfiguration()` (all disabled)

**Usage:**
```swift
.environment(
    \.visualLayoutGuideInteractions,
    VisualLayoutGuideInteractionsConfiguration(
        dragEnabled: true,
        persistenceEnabled: true,
        persistenceNamespace: "debug"
    )
)
```

---

### draggablePositionViewInteractions

```swift
extension EnvironmentValues {
    var draggablePositionViewInteractions: DraggablePositionViewInteractionsConfiguration
}
```

Configuration for dragging and persistence behavior for `DraggablePositionView`.

**Default:** `DraggablePositionViewInteractionsConfiguration()` (all disabled)

**Usage:**
```swift
.environment(
    \.draggablePositionViewInteractions,
    DraggablePositionViewInteractionsConfiguration(
        dragEnabled: true,
        persistenceEnabled: true,
        persistenceNamespace: "tracking"
    )
)
```

---

### draggablePositionViewConstraints

```swift
extension EnvironmentValues {
    var draggablePositionViewConstraints: DraggablePositionViewConstraintsConfiguration
}
```

Configuration for drag constraints.

**Default:** `DraggablePositionViewConstraintsConfiguration()` (no constraints)

**Usage:**
```swift
.environment(
    \.draggablePositionViewConstraints,
    DraggablePositionViewConstraintsConfiguration(constraints: .horizontal)
)
```

---

## Internal Types

The following types are used internally and are not part of the public API:

- `DebugRender` - Internal wrapper for `.debugRender()`
- `DebugCompute` - Internal wrapper for `.debugCompute()`
- `LocalRenderManager` - Manages animation state for `.debugCompute()`
- `OverlayPositionCoordinator` - Manages collision detection for `VisualLayoutGuide`

---

## Platform Availability

| Feature | Minimum Version |
|---------|----------------|
| debugRender() | iOS 15, macOS 12, tvOS 15, watchOS 8 |
| debugCompute() | iOS 13, macOS 10.15, tvOS 13, watchOS 6 |
| RenderCheck | iOS 15, macOS 12, tvOS 15, watchOS 8 |
| VisualLayoutGuide | iOS 17, macOS 14, tvOS 17, watchOS 10 |
| DraggablePositionView | iOS 17, macOS 14, tvOS 17, watchOS 10 |
| VisualGridGuide | iOS 17, macOS 14, tvOS 17, watchOS 10 |
| VisualCornerInsetGuide | iOS 26, macOS 26, tvOS 26, watchOS 26 |
| ConcentricRectangle | iOS 15, macOS 12, tvOS 15, watchOS 8 |

---

## Production Builds

All debugging tools are conditionally compiled with `#if DEBUG`. They are automatically excluded from release builds, ensuring zero performance impact and no code size increase.

---

## Related Documentation

- [Home](Home) - Overview and quick start
- [Render Debugging](Render-Debugging) - Detailed render debugging guide
- [Visual Layout Guide](Visual-Layout-Guide) - Layout guide documentation
- [Draggable Position View](Draggable-Position-View) - Position tracking documentation
- [Visual Grid Guide](Visual-Grid-Guide) - Grid overlay documentation
- [Visual Corner Inset Guide](Visual-Corner-Inset-Guide) - Container shape documentation
