//
//  RenderDebugView.swift
//  RenderMeThis
//
//  Created by Aether on 12/03/2025.
//

import SwiftUI

/// A debugging wrapper that highlights when a view is re‑initialized.
/// Because SwiftUI views are value types and are recreated on refresh,
/// the initializer triggers the visual effect each time.
struct RenderDebugView<Content: View>: View {
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
    func checkForRender() -> some View {
        #if DEBUG
        return RenderDebugView(content: self)
        #else
        return self
        #endif
    }
}

@available(iOS 18.0, *)
@available(macOS 15, *)
#Preview("Wrapper") {
    RMTDemoView()
}
