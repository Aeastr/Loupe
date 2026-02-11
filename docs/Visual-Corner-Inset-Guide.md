# Visual Corner Inset Guide

A visual debugging overlay that shows container shapes and view dimensions.

**File:** `Sources/Loupe/VisualCornerInsetGuide.swift:15`

**Availability:** iOS 26+, macOS 26+, tvOS 26+, watchOS 26+

## Overview

`VisualCornerInsetGuide` renders a `ConcentricRectangle` that responds to the container's shape, along with an info panel showing view size. This is perfect for testing and debugging SwiftUI's `containerShape()` modifier.

The guide helps you:
- Visualize container shapes and corner radius
- Test `ConcentricRectangle` behavior
- Debug `containerShape()` modifiers
- Verify presentation corner radius (sheets, popovers)

## Basic Usage

```swift
import Loupe

@available(iOS 26.0, *)
struct ContentView: View {
    var body: some View {
        VisualCornerInsetGuide("Container Shape")
            .padding(20)
            .frame(width: 220, height: 160)
            .background(.regularMaterial, in: ConcentricRectangle())
    }
}
```

This displays a semi-transparent `ConcentricRectangle` with a metrics panel showing the view's width and height.

## Features

### Container Shape Visualization

Renders a `ConcentricRectangle` (50% opacity) that automatically adapts to the container's shape:

```swift
ConcentricRectangle()
    .opacity(0.5)
```

The shape will respect:
- `.containerShape()` modifiers
- Presentation corner radius (sheets, popovers)
- Rounded rectangle corners
- Uneven rounded rectangles

### Metrics Display

Shows the view's exact dimensions:

```swift
MetricsSummary(label: label, size: viewSize)
```

Displays:
- Optional label
- Width × Height in points

## Initialization

```swift
@available(iOS 26.0, macOS 26.0, *)
public init(_ label: String? = nil)
```

### Parameters

- **`label`** - Optional caption rendered in the metrics summary overlay

## Common Use Cases

### Testing containerShape()

```swift
@available(iOS 26.0, *)
struct ContainerShapeExample: View {
    var body: some View {
        VStack(spacing: 40) {
            // Default rectangle
            VisualCornerInsetGuide("Default")
                .frame(width: 220, height: 160)
                .background(.blue.opacity(0.3), in: ConcentricRectangle())

            // Rounded rectangle
            VisualCornerInsetGuide("Rounded")
                .frame(width: 220, height: 160)
                .background(.green.opacity(0.3), in: ConcentricRectangle())
                .containerShape(RoundedRectangle(cornerRadius: 32, style: .continuous))

            // Uneven corners
            VisualCornerInsetGuide("Uneven")
                .frame(width: 220, height: 160)
                .background(.purple.opacity(0.3), in: ConcentricRectangle())
                .containerShape(
                    UnevenRoundedRectangle(
                        topLeadingRadius: 60,
                        bottomLeadingRadius: 12,
                        bottomTrailingRadius: 44,
                        topTrailingRadius: 12
                    )
                )
        }
    }
}
```

Each guide will show how `ConcentricRectangle` adapts to the container shape.

### Testing Presentation Corner Radius

```swift
@available(iOS 26.0, *)
struct SheetExample: View {
    @State private var showSheet = true

    var body: some View {
        VStack {
            Button("Show Sheet") {
                showSheet = true
            }
        }
        .sheet(isPresented: $showSheet) {
            VisualCornerInsetGuide("Sheet")
                .padding(16)
                .presentationCornerRadius(24)
                .ignoresSafeArea()
        }
    }
}
```

The guide will visualize the sheet's corner radius.

### Fullscreen Container

```swift
@available(iOS 26.0, *)
VisualCornerInsetGuide("Fullscreen")
    .foregroundStyle(.red)
    .padding(5)
    .ignoresSafeArea()
```

Test how container shapes behave at fullscreen.

### Comparing Shapes

```swift
@available(iOS 26.0, *)
HStack(spacing: 20) {
    VisualCornerInsetGuide("Circle")
        .frame(width: 150, height: 150)
        .background(.blue.opacity(0.2), in: ConcentricRectangle())
        .containerShape(Circle())

    VisualCornerInsetGuide("Capsule")
        .frame(width: 150, height: 100)
        .background(.green.opacity(0.2), in: ConcentricRectangle())
        .containerShape(Capsule())
}
```

## How It Works

### ConcentricRectangle

`ConcentricRectangle` is a `Shape` that respects the container's corner radius:

```swift
@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
public struct ConcentricRectangle: Shape {
    public func path(in rect: CGRect) -> Path {
        if #available(iOS 26.0, macOS 26.0, tvOS 26.0, watchOS 26.0, *) {
            // Uses actual ConcentricRectangle behavior
            return Path(rect)
        } else {
            // Fallback to regular rectangle
            return Path(rect)
        }
    }
}
```

**Note:** The current implementation is a standalone version. On iOS 26+, it uses the platform's native `ConcentricRectangle` behavior.

### Metrics Summary

The overlay displays size information:

```swift
VStack(spacing: 6) {
    if let label {
        Text(label)
            .font(.system(size: 11, weight: .semibold, design: .monospaced))
    }

    Text("\(Int(width)) × \(Int(height))")
        .font(.system(size: 10, weight: .regular, design: .monospaced))
}
```

### Dynamic Size Tracking

Uses `onGeometryChange` to monitor size changes:

```swift
.onGeometryChange(for: CGSize.self) { proxy in
    proxy.size
} action: { newSize in
    viewSize = newSize
}
```

### Accessibility

Includes accessibility labels for VoiceOver:

```swift
.accessibilityLabel("Visual container shape guide")
.accessibilityValue("\(Int(width)) by \(Int(height)) points")
```

## ConcentricRectangle Details

`ConcentricRectangle` conforms to `InsettableShape`, allowing stroke and inset operations:

```swift
extension ConcentricRectangle: InsettableShape {
    public func inset(by amount: CGFloat) -> some InsettableShape {
        _Inset(amount: amount)
    }
}
```

This enables usage like:

```swift
ConcentricRectangle()
    .stroke(.blue, lineWidth: 3)
    .padding(10)
```

## Platform Compatibility

### iOS 26+ Features

On iOS 26 and later:
- Native `ConcentricRectangle` behavior
- Full container shape support
- Presentation corner radius
- Uneven rounded rectangles

### Earlier Platforms

On earlier platforms:
- Falls back to standard `Rectangle`
- Still useful for size visualization
- Container shape modifiers not available

## Advanced Usage

### Nested Container Shapes

```swift
@available(iOS 26.0, *)
ZStack {
    VisualCornerInsetGuide("Outer")
        .padding(40)
        .background(.blue.opacity(0.2), in: ConcentricRectangle())
        .containerShape(RoundedRectangle(cornerRadius: 40))

    VisualCornerInsetGuide("Inner")
        .padding(80)
        .background(.green.opacity(0.2), in: ConcentricRectangle())
        .containerShape(RoundedRectangle(cornerRadius: 20))
}
```

### Custom Materials

```swift
@available(iOS 26.0, *)
VisualCornerInsetGuide("Material")
    .padding(20)
    .frame(width: 200, height: 150)
    .background(.ultraThinMaterial, in: ConcentricRectangle())
    .containerShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
```

### Color Overlay

```swift
@available(iOS 26.0, *)
VisualCornerInsetGuide("Color")
    .foregroundStyle(.blue) // Colors the ConcentricRectangle
    .padding(20)
    .frame(width: 200, height: 150)
```

### Safe Area Testing

```swift
@available(iOS 26.0, *)
VStack {
    VisualCornerInsetGuide("Respects Safe Area")
        .foregroundStyle(.blue)

    VisualCornerInsetGuide("Ignores Safe Area")
        .foregroundStyle(.red)
        .ignoresSafeArea()
}
```

## Troubleshooting

### Shape Not Visible

Make sure you're applying a background or foreground style:

```swift
VisualCornerInsetGuide("Visible")
    .foregroundStyle(.red) // Makes the shape visible
```

### Container Shape Not Working

Ensure you're on iOS 26+ and using the correct modifier:

```swift
if #available(iOS 26.0, *) {
    VisualCornerInsetGuide("Shape")
        .containerShape(RoundedRectangle(cornerRadius: 24))
} else {
    Text("Requires iOS 26+")
}
```

### Metrics Not Showing

Check that the view has a defined size:

```swift
VisualCornerInsetGuide("Sized")
    .frame(width: 200, height: 150) // Explicit size
```

## Performance Considerations

- Lightweight rendering (single shape + text overlay)
- Size tracking via efficient `onGeometryChange`
- No expensive computations
- Suitable for real-time debugging

## Related Documentation

- [Visual Layout Guide](Visual-Layout-Guide) - Inspect bounds and insets
- [ConcentricRectangle Shape](#concentricrectangle-details) - Shape implementation
- [API Reference](API-Reference) - Complete API documentation
