//
//  RenderCheck.swift
//  RenderMeThis
//
//  Created by Aether on 12/03/2025.
//

import SwiftUI

/// A convenience view that applies the rendering debug wrapper to each subview.
/// (basically, it wraps every subview with the modifier that detects when it re-renders)
@available(macOS 15, *)
@available(iOS 18.0, *)
// only available on iOS 18+ macOS 15+ (because it uses new SwiftUI APIs)
public struct RenderCheck<Content: View>: View {
    @ViewBuilder let content: Content
    // `@ViewBuilder` lets you pass multiple views as `content`
    // (so you can just throw a bunch of views inside `RenderCheck` without explicitly grouping them)
    
    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    public var body: some View {
        Group(subviews: content) { subviewsCollection in
            subviewsCollection
            // This is just passing the subviews along untouched (I hope??)
            // (the real work happens in `.checkForRender()`)
        }
        .checkForRender()
        // Highlights views that re-render (that's the whole point of this tool)
    }
}
