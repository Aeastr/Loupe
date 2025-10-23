//
//  VisualCornerInsetGuide.swift
//  Loupe
//
//  Created by Codex on 10/16/25.
//

import SwiftUI

/// A visual debugging overlay that shows the container shape and view dimensions.
///
/// The guide renders a ConcentricRectangle that responds to the container shape,
/// along with an info panel showing the view size.
@available(iOS 26.0, macOS 26.0, *)
public struct VisualCornerInsetGuide: View {
    /// Optional caption displayed in the metrics summary panel.
    private let label: String?

    /// Latest known size of the hosting view.
    @State private var viewSize: CGSize = .zero

    /// Creates a visual guide for container shapes.
    ///
    /// - Parameters:
    ///   - label: Optional caption rendered in the metrics summary overlay.
    public init(_ label: String? = nil) {
        self.label = label
    }

    public var body: some View {
        ZStack {
            ConcentricRectangle()
                .opacity(0.5)
            MetricsSummary(label: label, size: viewSize)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(.quinary.opacity(0.1))
        }
        .onGeometryChange(for: CGSize.self) { proxy in
            proxy.size
        } action: { newSize in
            viewSize = newSize
        }
        .accessibilityLabel("Visual container shape guide")
        .accessibilityValue("\(String(format: "%.0f", viewSize.width)) by \(String(format: "%.0f", viewSize.height)) points")
    }
}

// MARK: - Metrics Summary
@available(iOS 26.0, macOS 26.0, *)
private struct MetricsSummary: View {
    let label: String?
    let size: CGSize

    var body: some View {
        VStack(spacing: 6) {
            if let label {
                Text(label)
                    .font(.system(size: 11, weight: .semibold, design: .monospaced))
                    .foregroundStyle(.primary)
            }

            Text("\(String(format: "%.0f", size.width)) × \(String(format: "%.0f", size.height))")
                .font(.system(size: 10, weight: .regular, design: .monospaced))
                .foregroundStyle(.primary.opacity(0.9))
        }
    }
}

// MARK: - Previews
@available(iOS 26.0, macOS 26.0, *)
#Preview("VisualCornerInsetGuide") {
    VStack(spacing: 40) {
        VisualCornerInsetGuide("None")
            .padding(20)
            .frame(width: 220, height: 160)
            .background(.regularMaterial, in: ConcentricRectangle())

        VisualCornerInsetGuide("RoundedRectangle")
            .padding(20)
            .frame(width: 220, height: 160)
            .background(.regularMaterial, in: ConcentricRectangle())
            .containerShape(RoundedRectangle(cornerRadius: 72, style: .continuous))

        VisualCornerInsetGuide("UnevenRoundedRectangle")
            .padding(20)
            .frame(width: 220, height: 160)
            .background(.regularMaterial, in: ConcentricRectangle())
            .containerShape(
                UnevenRoundedRectangle(
                    topLeadingRadius: 60,
                    bottomLeadingRadius: 12,
                    bottomTrailingRadius: 44,
                    topTrailingRadius: 12
                )
            )
    }
}

@available(iOS 26.0, macOS 26.0, *)
#Preview{
    VisualCornerInsetGuide("Fullscreen")
        .foregroundStyle(.red)
        .padding(5)
        .ignoresSafeArea()
}

@available(iOS 26.0, macOS 26.0, *)
private struct SimpleSheetHost: View {
    @State private var show = true
    var body: some View {
        VStack {
            Button("Show Sheet") { show = true }
        }
        .sheet(isPresented: $show) {
            VisualCornerInsetGuide("Sheet Example")
                .padding(16)
                .presentationCornerRadius(24)
                .ignoresSafeArea()
        }
    }
}

@available(iOS 26.0, macOS 26.0, *)
#Preview("Simple Sheet") {
    SimpleSheetHost()
}
