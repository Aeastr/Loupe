//
//  ComputeDebugView.swift
//  Loupe
//
//  Created by Aether on 25/04/2025.
//

import SwiftUI

/// A debugging wrapper that highlights when a view is re‑initialized.
/// Because SwiftUI views are value types and are recreated on refresh,
/// the initializer triggers the visual effect each time.
struct DebugCompute<Content: View>: View {
    let content: Content
    let enabled: Bool
    @ObservedObject private var renderManager: LocalRenderManager
    
    init(content: Content, enabled: Bool = true) {
        self.content = content
        self.enabled = enabled
        self.renderManager = LocalRenderManager()
        if enabled {
            renderManager.triggerRender()
        }
    }
    
    var body: some View {
        content
            .overlay(
                Group {
                    if enabled {
                        Color.red
                            .opacity(renderManager.rendered ? 0.3 : 0.0)
                            .animation(.easeOut(duration: 0.3), value: renderManager.rendered)
                            .allowsHitTesting(false)
                    }
                }
            )
    }
}

public extension View {
    /// Wraps the view in a debug wrapper that highlights render updates.
    func debugCompute(enabled: Bool = true) -> some View {
        #if DEBUG
        return DebugCompute(content: self, enabled: enabled)
        #else
        return self
        #endif
    }
}
