//
//  RenderCheck.swift
//  RenderMeThis
//
//  Created by Aether on 12/03/2025.
//

import SwiftUI

/// A convenience view that applies the rendering debug wrapper to each subview.
/// (basically, it wraps every subview with the modifier that detects when it re-renders)
@available(iOS 15.0, *)
public struct RenderCheck<Content: View>: View {
    // `@ViewBuilder` lets you pass multiple views as `content`
    // (so you can just throw a bunch of views inside `RenderCheck` without explicitly grouping them)
    @ViewBuilder let content: Content
    
    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    public var body: some View {
        // This is just passing the subviews along untouched (I hope??)
        // (the real work happens in `.debugRender()`)
        if #available(macOS 15, iOS 18, *) {
            Group(subviews: content) { subviewsCollection in
                subviewsCollection
            }
            .debugRender() // Highlights views that re-render (that's the whole point of this tool)
        } else {
            _VariadicView.Tree(_RenderCheckGroup()) {
                content
                    .debugRender()
            }
        }
    }
}

// MARK: - Back Deploy

@available(iOS 15.0, *)
fileprivate struct _RenderCheckGroup: _VariadicView_MultiViewRoot {
    func body(children: _VariadicView.Children) -> some View {
        ForEach(children) { child in
            child
                .debugRender()
        }
    }
}
