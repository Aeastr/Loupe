<div align="center">
  <img width="360" height="314.65" src="/assets/icon2.png" alt="RenderMeThis Logo">
  <h1><b>RenderMeThis</b></h1>
  <p>
    A simple SwiftUI debugging tool that reveals exactly when your views re‑render.
    <br>
    <i>Compatible with iOS 13.0 and later, macOS 10.15 and later</i>
  </p>
</div>

<div align="center">
  <a href="https://swift.org">
    <img src="https://img.shields.io/badge/Swift-5.9%20%7C%206-orange.svg" alt="Swift Version">
  </a>
  <a href="https://www.apple.com/ios/">
    <img src="https://img.shields.io/badge/iOS-13%2B-blue.svg" alt="iOS">
  </a>
  <a href="https://www.apple.com/macos/">
    <img src="https://img.shields.io/badge/macOS-10.15%2B-blue.svg" alt="macOS">
  </a>
  <a href="LICENSE">
    <img src="https://img.shields.io/badge/License-MIT-green.svg" alt="License: MIT">
  </a>
</div>

---

## **Overview**

RenderMeThis is a SwiftUI debugging utility that helps you pinpoint exactly when your views re‑render. By integrating RenderMeThis into your project, each re‑render is highlighted by a brief red flash, making it easier to track down unnecessary view updates and optimize performance. Designed for iOS 13.0 and later, RenderMeThis offers both a modifier-based method and a wrapper-based method for flexible integration into your SwiftUI views.

>### **How SwiftUI Rendering Works**
>SwiftUI re-computes a view’s `body` whenever its state changes, but that doesn’t mean it rebuilds the entire UI. Instead, SwiftUI uses a diffing system to compare the new view hierarchy with the old one, updating only the parts that have actually changed. If you break your UI into separate structs and a subview (like a text field) has no state change, it won’t be re-rendered at all—achieving re-render behavior similar to UIKit.

> As of now this works by wrapping your code, or using a modifier, but I'm cooking something a bit more cool for later

![Example](/assets/example.gif)

---

## **Installation**

### Swift Package Manager

1. In Xcode, navigate to **File > Add Packages...**
2. Enter the repository URL:  
   `https://github.com/Aeastr/RenderMeThis`
3. Follow the prompts to add the package to your project.

---


## **Usage**

Below are two sets of examples demonstrating how to use RenderMeThis. The first set leverages the **wrapper method** (using `RenderCheck`), available on iOS 13+; the second uses the **modifier method** (using `checkForRender()`) for iOS 13+.

### **Debugging vs. Production**
> Important: RenderMeThis is a development utility intended solely for debugging purposes. The debug overlay—which highlights view re‑renders with a red flash—is conditionally compiled using Swift’s `#if DEBUG` directive. This means that in production builds, the debugging code is automatically excluded, ensuring that your app remains lean without any unintended visual effects or performance overhead.

> Please ensure that your project’s build settings correctly define the DEBUG flag for development configurations. This will guarantee that the render debugging features are active only during development and testing.

### **Wrapper Method**

Wrap your entire view hierarchy with `RenderCheck` to automatically apply render debugging to every subview:

```swift
import SwiftUI
struct ContentView: View {
    @State private var counter = 0
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    // Entire content is wrapped in RenderCheck.
                    RenderCheck {
                        Text("Main Content")
                            .font(.headline)
                        
                        Text("Counter: \(counter)")
                            .font(.subheadline)
                        
                        Button(action: {
                            counter += 1
                        }) {
                            Label("Increment", systemImage: "plus.circle.fill")
                                .padding()
                                .background(Color.blue.opacity(0.2))
                                .cornerRadius(8)
                        }
                        
                        Divider()
                        
                        Text("Separate Section")
                            .font(.headline)
                        
                        ContentSubView()
                    }
                }
            }
            .padding()
            .navigationTitle("RenderMeThis")
        }
    }
}

struct ContentSubView: View {
    @State private var counter = 0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            RenderCheck {
                Text("Counter: \(counter)")
                    .font(.subheadline)
                
                Button(action: {
                    counter += 1
                }) {
                    Label("Increment", systemImage: "plus.circle.fill")
                        .padding()
                        .background(Color.green.opacity(0.2))
                        .cornerRadius(8)
                }
            }
        }
    }
}
```


### **Modifier Method**

Apply the render debugging effect to individual views using the `checkForRender()` modifier:

```swift
import SwiftUI
struct ContentView: View {
    @State private var counter = 0

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                VStack(spacing: 12) {
                    Text("Main Content")
                        .font(.headline)
                        .checkForRender()

                    Text("Counter: \(counter)")
                        .font(.subheadline)
                        .checkForRender()

                    Button(action: {
                        counter += 1
                    }) {
                        HStack {
                            Text("Increment")
                            Image(systemName: "plus.circle.fill")
                        }
                        .padding()
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(8)
                    }
                    .checkForRender()

                    Divider()
                        .checkForRender()

                    Text("Separate Section")
                        .font(.headline)
                        .checkForRender()

                    ContentSubView()
                        .checkForRender()
                }
            }
            .padding()
        }
    }
}

struct ContentSubView: View {
    @State private var counter = 0

    var body: some View {
        VStack(spacing: 12) {
            Text("Counter: \(counter)")
                .font(.subheadline)
                .checkForRender()

            Button(action: {
                counter += 1
            }) {
                HStack {
                    Text("Increment")
                    Image(systemName: "plus.circle.fill")
                }
                .padding()
                .background(Color.green.opacity(0.2))
                .cornerRadius(8)
            }
            .checkForRender()
        }
    }
}
```

---

## **Key Components**

- **RenderDebugView**  
  A SwiftUI wrapper that overlays its content with a brief red flash each time the view is re‑initialized. This flash indicates that the view has re‑rendered.

- **RenderCheck**  
  A convenience wrapper that applies the render debugging effect to multiple subviews. By using `@ViewBuilder`, it accepts and wraps multiple views with the render detection modifier.

- **LocalRenderManager**  
  An internal utility responsible for managing the flash state. It triggers a temporary red flash by setting a Boolean flag that controls the overlay’s opacity.

- **Modifier Method**  
  An extension on `View` called `checkForRender()` which wraps any view in a `RenderDebugView`, allowing for quick and simple integration of the render debugging effect.

---

## **How It Works**

RenderMeThis leverages SwiftUI’s view refresh cycle to visually indicate when views re‑render. Here’s a breakdown of how the different components work together:

### **RenderDebugView**

- **Initialization Trigger:**  
  When a view is wrapped in `RenderDebugView`, its initializer is called. This creates a new instance of `LocalRenderManager` and immediately triggers the render flash.
  
- **Flash Overlay:**  
  The view content is overlaid with a red color whose opacity is determined by the `rendered` state from `LocalRenderManager`. When `rendered` is true, a semi‑transparent red tint (30% opacity) appears and then fades out with an ease‑out animation over 0.3 seconds.

### **LocalRenderManager**

- **State Management:**  
  This manager maintains a Boolean `rendered` property that controls the overlay’s visibility.
  
- **Triggering and Reset:**  
  When `triggerRender()` is called, `rendered` is set to true, causing the red flash. A scheduled task resets `rendered` to false after 0.3 seconds, ensuring that the flash is temporary.

### **RenderCheck**

- **Convenience Wrapper:**  
  `RenderCheck` uses SwiftUI’s `@ViewBuilder` to accept multiple subviews. It groups them together and applies the `checkForRender()` modifier, thereby enabling re‑render detection across an entire view hierarchy without modifying each individual subview.

### **Modifier Extension**

- **Simplified Integration:**  
  The extension method `checkForRender()` on `View` wraps any view in a `RenderDebugView`. This allows you to integrate render detection quickly by simply appending the modifier to your view.

Together, these components allow you to monitor your SwiftUI views for unnecessary or unexpected re‑renders

> RenderMeThis is intended for debugging and development purposes. The visual overlay indicating view re‑renders should be disabled or removed in production builds.

---

## **License**

RenderMeThis is available under the MIT license. See the [LICENSE](LICENSE) file for more information.
