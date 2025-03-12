//
//  RenderCheck.swift
//  RenderMeThis
//
//  Created by Aether on 12/03/2025.
//


import SwiftUI

/// A convenience view that applies the rendering debug wrapper to each subview.
/// [basically, it wraps every subview with the modifier that detects when it re-renders]
@available(iOS 18.0, *)
// only available on ios 18+ (bc it uses new swiftui apis introduced in ios 18)
struct RenderCheck<Content: View>: View {
    @ViewBuilder let content: Content
    // `@ViewBuilder` lets you pass multiple views as `content`
    // (so you can just throw a bunch of views inside `RenderCheck` without explicitly grouping them)
    var body: some View {
        Group(subviews: content) { subviewsCollection in
            subviewsCollection
            // this is just passing the subviews along untouched (i hope??)
            // (the real work happens in `.checkForRender()`)
        }
        .checkForRender()
        // highlights views that re-render (that's the whole point of this tool)
    }
}
