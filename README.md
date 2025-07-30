<div align="center">
  <img width="360" height="314.65" src="/assets/icon2.png" alt="RenderMeThis Logo">
  <h1><b>RenderMeThis</b></h1>
  <p>
    A simple SwiftUI debugging tool that reveals exactly when your views re-render/compute.
    <br>
    <i>Compatible with iOS 15.0 and later, macOS 12 and later</i>
  </p>
</div>

<div align="center">
  <a href="https://swift.org">
    <img src="https://img.shields.io/badge/Swift-5.9%20%7C%206-orange.svg" alt="Swift Version">
  </a>
  <a href="https://www.apple.com/ios/">
    <img src="https://img.shields.io/badge/iOS-15%2B-blue.svg" alt="iOS">
  </a>
  <a href="https://www.apple.com/macos/">
    <img src="https://img.shields.io/badge/macOS-12%2B-blue.svg" alt="tvOS">
  </a>
  <a href="https://www.apple.com/tvos/">
    <img src="https://img.shields.io/badge/tvOS-15%2B-blue.svg" alt="macOS">
  </a>
  <a href="LICENSE">
    <img src="https://img.shields.io/badge/License-MIT-green.svg" alt="License: MIT">
  </a>
</div>

---

## **Overview**

RenderMeThis is a SwiftUI debugging utility that helps you pinpoint exactly when your views re-render or re-compute.

SwiftUI **re-computes a view’s `body` whenever its state changes**, but that **doesn’t mean it rebuilds the entire UI**. Instead, SwiftUI uses a diffing system to compare the new view hierarchy with the old one, updating only the parts that have actually changed. 

RenderMeThis let's you see re-computes (aka re-initalizations) as well as actual re-renders, where the UI is rebuilt

---

## **Installation**

### Swift Package Manager

1. In Xcode, navigate to **File > Add Packages...**
2. Enter the repository URL:  
   `https://github.com/Aeastr/RenderMeThis.git`
3. Follow the prompts to add the package to your project.

---

## **Usage**

### **Debugging vs. Production**
> Important: RenderMeThis is a development utility intended solely for **debugging purposes**. The debug tools are conditionally compiled using Swift’s `#if DEBUG` directive. This means that in production builds, the debugging code is automatically excluded, ensuring that your app remains lean without any unintended visual effects or performance overhead.

> Please ensure that your project’s build settings correctly define the DEBUG flag for development configurations. This will guarantee that the render debugging features are active only during development and testing.

### debugRender()

The `debugRender()` modifier visualizes when SwiftUI re-renders a view by applying a random colored background that changes on each re-render. This is incredibly useful for identifying which parts of your UI are being re-rendered when state changes.

#### Basic Usage

```swift
Text("Hello World")
    .padding()
    .debugRender()
```

This applies a semi-transparent colored background to the text. The key is that this color will change whenever the view is re-rendered.

#### With State Changes

When state changes cause a view to re-render, the color will change, making it immediately obvious which views are affected:

```swift
struct CounterView: View {
    @State private var count = 0
    
    var body: some View {
        VStack {
            // This text will show a changing background color whenever count changes
            Text("Count: \(count)")
                .padding()
                .debugRender()
            
            Button("Increment") {
                count += 1
            }
        }
    }
}
```

In this example, every time the button is tapped, the Text view's background color will change because it depends on `count`.

#### Selective Debugging

You can apply the modifier to specific views to see exactly which ones are being re-rendered:

```swift
VStack {
    Text("This will re-render: \(count)")
        .debugRender() // This background will change color
    
    Text("Static text")
        .debugRender() // This background will NOT change color
    
    Button("Increment") {
        count += 1
    }
    .debugRender() // This only changes when the button itself re-renders
}
```

#### Wrapper Approach

The wrapper version only applies to the container, not its children:

```swift
// Only the VStack container gets the colored background
DebugRender {
    VStack {
        Text("Last updated: \(Date().formatted())")
        Text("Current count: \(count)")
        Button("Reset") { count = 0 }
    }
}
```

To debug every element individually, apply the modifier to each component:

```swift
VStack {
    Text("Updated: \(Date().formatted())")
        .debugRender() // Gets its own color
    
    Text("Count: \(count)")
        .debugRender() // Gets a different color
    
    Button("Reset") { count = 0 }
        .debugRender() // Button gets its own color
}
```

### debugCompute()

The `debugCompute()` modifier highlights when SwiftUI recreates/reinitializes a view by briefly flashing it red. This shows when a view is being re-computed/re-initailized

#### Basic Usage

```swift
Text("Hello World")
    .padding()
    .debugCompute()
```

This will flash red whenever the view is recreated (not just re-rendered).

#### Interactive UI Elements

Text fields are a particularly good example, as they re-compute on every keystroke:

```swift
@State private var searchText = ""

TextField("Search...", text: $searchText)
    .padding()
    .debugCompute() // Will flash red with EVERY keystroke
```

The text field flashes because SwiftUI creates a new view instance for each character typed.

#### Dependent Views

Views that depend on changing state will flash when that state changes:

```swift
Text("Searching for: \(searchText)")
    .padding()
    .debugCompute() // Flashes whenever searchText changes
```

#### Conditional Content

Toggling visibility creates entirely new view instances:

```swift
@State private var showDetails = false

Button("Toggle Details") {
    showDetails.toggle()
}
.debugCompute() // Flashes when tapped

if showDetails {
    VStack {
        Text("These are the details")
        Text("More information here")
    }
    .padding()
    .debugCompute() // Flashes when appearing/disappearing
}
```

#### Nested vs Non-Nested Usage

Applying to a container affects the whole container's behavior:

```swift
// The entire structure flashes on each keystroke
VStack {
    TextField("Type here", text: $searchText) 
    Text("Preview: \(searchText)")
    Button("Clear", action: { searchText = "" })
}
.debugCompute() // Entire VStack reinitializes with each keystroke
```

Versus targeting specific components:

```swift
VStack {
    // Only this component flashes with each keystroke
    TextField("Type here", text: $searchText)
        .debugCompute()
    
    // Only flashes when searchText changes
    Text("Preview: \(searchText)")
        .debugCompute()
    
    // Only flashes when tapped
    Button("Clear") { searchText = "" }
        .debugCompute()
}
```

#### Wrapper Approach

Like `debugRender()`, the wrapper only applies to the container:

```swift
DebugCompute {
    VStack {
        Text("Header")
        Text("Content: \(searchText)")
    }
} // Only the VStack container flashes red, not each child view
```

These visualizations help you understand SwiftUI's view lifecycle and optimize your code for better performance by identifying unnecessary view recreations.

---

## **Key Components**

- **DebugRender**  
  A SwiftUI wrapper that uses a Canvas background to draw a random-colored, semi-transparent overlay each time a view is re-rendered. This provides a clear visual indication of which views are actually being re-rendered by SwiftUI's rendering system.

- **DebugCompute**  
  A debugging wrapper that briefly flashes a red overlay when a view is re-computed/re-initialized (not just re-rendered).

- **Extension Methods**  
  Two extension methods on `View`:
  - `.debugRender()` - Shows re-renders with changing colored backgrounds
  - `.debugCompute()` - Shows re-computs/re-initalizations with red flashes


These components work together to provide a comprehensive visual debugging system for SwiftUI, helping developers understand both the rendering and computation aspects of SwiftUI's view lifecycle.

---

### **_VariadicView Back‑Deployment**

RenderMeThis leverages SwiftUI’s internal `_VariadicView` API to backport its render-check functionality on pre‑iOS 18 and pre‑macOS 15 systems. On iOS 18 and macOS 15 (and newer), we use SwiftUI’s native `Group(subviews:transform:)` API, but to support older OS versions we expose `_VariadicView` in the `RenderCheck` wrapper.

When running on older platforms, `RenderCheck` wraps its child views inside a `_VariadicView.Tree` with a custom `_RenderCheckGroup` layout. This layout iterates over each child view and applies the `debugRender()` modifier, ensuring that render-checking is supported even on devices running older OS versions.

> **Note:** The use of `_VariadicView` is strictly limited to pre‑iOS 18 and pre‑macOS 15 environments. On newer systems, we rely on the native APIs.

---

## **License**

RenderMeThis is available under the MIT license. See the [LICENSE](LICENSE) file for more information.

---

<p align="center">Built with 🍏🔄🕵️‍♂️ by Aether</p>
