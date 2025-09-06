//
//  RenderDebugView.swift
//  RenderMeThis
//
//  Created by Aether on 12/03/2025.
//

import SwiftUI

@available(iOS 15.0, *)
/// A debugging wrapper that highlights when a view is redrawn.
/// Uses a background Canvas with a random color on actual redraw.
struct DebugRender<Content: View>: View {
    let content: Content
    let enabled: Bool
    
    init(content: Content, enabled: Bool = true) {
        self.content = content
        self.enabled = enabled
    }
    
    var body: some View {
        content
            .background(
                Group {
                    if enabled {
                        Canvas { context, size in
                            // Generate a random Hue, keeping Sat/Bri high
                            let randomHue = Double.random(in: 0...1)
                            let saturation = Double.random(in: 0.7...1.0)
                            let brightness = Double.random(in: 0.8...1.0)
                            let distinctColor = Color(
                                hue: randomHue,
                                saturation: saturation,
                                brightness: brightness
                            )
                            let finalOpacity = 0.4
                            
                            context.fill(
                                Path(CGRect(origin: .zero, size: size)),
                                with: .color(distinctColor.opacity(finalOpacity))
                            )
                        }
                        .allowsHitTesting(false)
                    }
                }
            )
    }
}
    

@available(iOS 15.0, *)
public extension View {
    /// Wraps the view in a debug wrapper that shows redraw updates.
    func debugRender(enabled: Bool = true) -> some View {
#if DEBUG
        DebugRender(content: self, enabled: enabled)
        
#else
        self
#endif
    }
}
