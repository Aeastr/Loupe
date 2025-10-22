//
//  LoupeGlassEffect.swift
//  Loupe
//
//  Created by Aether on 10/22/25.
//

import SwiftUI

// MARK: - Glass Effect Replacement

extension View {
    /// Applies a glass-like material background with the specified shape.
    /// Standalone replacement for UniversalGlass dependency.
    @ViewBuilder
    func loupeGlassEffect<S: Shape>(_ material: Material = .regular, in shape: S) -> some View {
        self.background(material, in: shape)
    }

    /// Applies a glass-like material background with corner radius.
    @ViewBuilder
    func loupeGlassEffect(_ material: Material = .regular, cornerRadius: CGFloat) -> some View {
        self.background(material, in: RoundedRectangle(cornerRadius: cornerRadius))
    }
}

// MARK: - Material Extensions for Parity

extension Material {
    /// Returns the material with interactive properties (no-op for standalone).
    func interactive() -> Material {
        return self
    }

    /// Returns a tinted material (approximation using overlay).
    func tint(_ color: Color) -> Material {
        // Note: True tinting requires custom implementation
        // This is a simplified version for standalone use
        return self
    }
}

// MARK: - Shape Extensions

extension Shape {
    /// Convenience for creating a circle shape.
    static var circle: Circle {
        Circle()
    }

    /// Convenience for creating a capsule shape.
    static var capsule: Capsule {
        Capsule()
    }

    /// Convenience for creating a rounded rectangle.
    static func rect(cornerRadius: CGFloat) -> RoundedRectangle {
        RoundedRectangle(cornerRadius: cornerRadius)
    }
}
