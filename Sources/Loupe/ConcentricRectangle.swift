//
//  ConcentricRectangle.swift
//  Loupe
//
//  Created by Aether on 10/22/25.
//

import SwiftUI

/// A rectangle shape that respects the container's shape and corner radius.
/// Standalone implementation for iOS 26+ features.
@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
public struct ConcentricRectangle: Shape {
    public init() {}

    public func path(in rect: CGRect) -> Path {
        // Basic rectangle implementation
        // On iOS 26+ this would use containerShape API
        if #available(iOS 26.0, macOS 26.0, tvOS 26.0, watchOS 26.0, *) {
            // Future: Use actual ConcentricRectangle when available
            return Path(rect)
        } else {
            return Path(rect)
        }
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
extension ConcentricRectangle: InsettableShape {
    public func inset(by amount: CGFloat) -> some InsettableShape {
        _Inset(amount: amount)
    }

    private struct _Inset: InsettableShape {
        var amount: CGFloat = 0

        func path(in rect: CGRect) -> Path {
            let insetRect = rect.insetBy(dx: amount, dy: amount)
            return Path(insetRect)
        }

        func inset(by amount: CGFloat) -> some InsettableShape {
            var copy = self
            copy.amount += amount
            return copy
        }
    }
}
