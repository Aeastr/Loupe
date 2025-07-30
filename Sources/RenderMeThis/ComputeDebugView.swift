//
//  ComputeDebugView.swift
//  RenderMeThis
//
//  Created by Aether on 25/04/2025.
//

import SwiftUI

/// A debugging wrapper that highlights when a view is re‑initialized.
/// Because SwiftUI views are value types and are recreated on refresh,
/// the initializer triggers the visual effect each time.
struct DebugCompute<Content: View>: View {
    let content: Content
    @ObservedObject private var renderManager: LocalRenderManager
    
    init(content: Content) {
        self.content = content
        self.renderManager = LocalRenderManager()
        renderManager.triggerRender()
    }
    
    var body: some View {
        content
            .overlay(
                Color.red
                    .opacity(renderManager.rendered ? 0.3 : 0.0)
                    .animation(.easeOut(duration: 0.3), value: renderManager.rendered)
                    .allowsHitTesting(false)
            )
    }
}

public extension View {
    /// Wraps the view in a debug wrapper that highlights render updates.
    func debugCompute() -> some View {
        #if DEBUG
        return DebugCompute(content: self)
        #else
        return self
        #endif
    }
}
