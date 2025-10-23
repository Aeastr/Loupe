//
//  VisualGridGuide.swift
//  Loupe
//
//  Created by Aether on 10/16/25.
//

import SwiftUI

/// A visual debugging overlay that renders a square grid fitted to the view's size.
///
/// By default the grid calculates the largest possible square dimension that divides both the
/// width and height without remainder, allowing you to reason about layout using the grid as a
/// coordinate system. Optionally provide a preferred `squareSize` with a `.preferred` fit mode to
/// prioritise a specific spacing while still keeping the grid centered and readable. Grid metrics
/// are displayed in the corner for quick reference.
public struct VisualGridGuide: View {
    /// Optional label rendered above the grid metrics.
    private let label: String?

    /// Width of the grid lines. Automatically adjusted for display scale.
    private let lineWidth: CGFloat

    /// Optional explicit square size. When provided, the grid attempts to honor it while still
    /// fitting perfectly within the available space.
    private let squareSize: CGFloat?

    /// Determines how the requested square size should be reconciled with the available space.
    private let fit: VisualGridGuideFit

    /// Cached metrics computed from the latest geometry change.
    @State private var metrics: GridMetrics?

    /// Creates a grid overlay using the provided label and tint.
    ///
    /// - Parameters:
    ///   - label: Optional caption displayed with the metrics overlay.
    ///   - lineWidth: Logical (unscaled) stroke width for grid lines (default `1`).
    ///   - squareSize: Preferred square side-length in points. When provided, combine with
    ///     `fit: .preferred` to favour this size while the grid stays centered.
    ///   - fit: Strategy for reconciling the preferred square size with the available dimensions
    ///     (default `.exact`).
    public init(
        _ label: String? = nil,
        lineWidth: CGFloat = 1,
        squareSize: CGFloat? = nil,
        fit: VisualGridGuideFit = .exact
    ) {
        self.label = label
        self.lineWidth = lineWidth
        self.squareSize = squareSize
        self.fit = fit
    }

    public var body: some View {
        ZStack(alignment: .topLeading) {
            GridCanvas(lineWidth: lineWidth, squareSize: squareSize, fit: fit)

            if let metrics {
                MetricsOverlay(label: label, metrics: metrics)
                    .padding(8)
            }
        }
        .onGeometryChange(for: CGSize.self) { proxy in
            proxy.size
        } action: { newSize in
            metrics = calculateGridMetrics(for: newSize, squareSize: squareSize, fit: fit)
        }
        .accessibilityLabel("Visual grid guide")
        .accessibilityValue(metricsDescription)
    }

    private var metricsDescription: String {
        guard let metrics else { return "Awaiting layout" }

        let formattedSize = String(format: "%.2f", metrics.squareSize)
        var base = "\(metrics.columns) columns, \(metrics.rows) rows, square size \(formattedSize) points"

        if metrics.fitMode == .preferred {
            let horizontal = metrics.horizontalRemainder
            let vertical = metrics.verticalRemainder

            if horizontal > 0.05 || vertical > 0.05 {
                base += " (preferred fit, remainder W: \(String(format: "%.2f", horizontal)), H: \(String(format: "%.2f", vertical)))"
            } else {
                base += " (preferred fit)"
            }
        }

        return base
    }
}

// MARK: - Metrics Overlay

private struct MetricsOverlay: View {
    let label: String?
    let metrics: GridMetrics


    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if let label {
                Text(label)
                    .font(.system(size: 11, weight: .semibold, design: .monospaced))
                    .foregroundStyle(.primary)
            }

            Text("square: \(String(format: "%.2f", metrics.squareSize))pt")
                .font(.system(size: 10, weight: .regular, design: .monospaced))
                .foregroundColor(.secondary)

            Text("grid: \(metrics.columns) × \(metrics.rows)")
                .font(.system(size: 10, weight: .regular, design: .monospaced))
                .foregroundColor(.secondary)

            if metrics.fitMode == .preferred {
                let horizontal = metrics.horizontalRemainder
                let vertical = metrics.verticalRemainder

                if horizontal > 0.05 || vertical > 0.05 {
                    Text("remainder: W \(String(format: "%.2f", horizontal)) / H \(String(format: "%.2f", vertical))")
                        .font(.system(size: 10, weight: .regular, design: .monospaced))
                        .foregroundColor(.secondary)
                } else {
                    Text("preferred fit")
                        .font(.system(size: 10, weight: .regular, design: .monospaced))
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(.thinMaterial, in: .rect(cornerRadius: 8))
    }
}

// MARK: - Canvas Renderer

private struct GridCanvas: View {
    let lineWidth: CGFloat
    let squareSize: CGFloat?
    let fit: VisualGridGuideFit

    @Environment(\.displayScale) private var displayScale

    var body: some View {
        Canvas { context, size in
            guard let metrics = calculateGridMetrics(for: size, squareSize: squareSize, fit: fit) else { return }

            var gridPath = Path()

            let startX = metrics.originOffset.x
            let startY = metrics.originOffset.y
            let endY = startY + metrics.contentSize.height
            let endX = startX + metrics.contentSize.width

            // Vertical lines
            for column in 0...metrics.columns {
                let x = min(endX, startX + CGFloat(column) * metrics.squareSize)
                gridPath.move(to: CGPoint(x: x, y: startY))
                gridPath.addLine(to: CGPoint(x: x, y: endY))
            }

            // Horizontal lines
            for row in 0...metrics.rows {
                let y = min(endY, startY + CGFloat(row) * metrics.squareSize)
                gridPath.move(to: CGPoint(x: startX, y: y))
                gridPath.addLine(to: CGPoint(x: endX, y: y))
            }

            context.stroke(gridPath, with: .style(.primary), lineWidth: lineWidth / displayScale)
        }
    }
}

// MARK: - Metrics Helpers

private struct GridMetrics: Equatable {
    let squareSize: CGFloat
    let columns: Int
    let rows: Int
    let originOffset: CGPoint
    let contentSize: CGSize
    let fitMode: VisualGridGuideFit
    let viewSize: CGSize
}

private extension GridMetrics {
    var horizontalRemainder: CGFloat { max(0, viewSize.width - contentSize.width) }
    var verticalRemainder: CGFloat { max(0, viewSize.height - contentSize.height) }
}

public enum VisualGridGuideFit: Equatable {
    /// Preserves a perfect tiling of the available space.
    case exact

    /// Prioritises the requested square size, allowing small gutters while keeping squares flushed.
    case preferred
}

private func calculateGridMetrics(
    for size: CGSize,
    squareSize requestedSquareSize: CGFloat?,
    fit: VisualGridGuideFit
) -> GridMetrics? {
    let width = max(size.width, 0)
    let height = max(size.height, 0)

    guard width > .zero, height > .zero else { return nil }

    if let requestedSquareSize, requestedSquareSize > 0, fit == .preferred {
        let columns = max(1, Int((width / requestedSquareSize).rounded()))
        let rows = max(1, Int((height / requestedSquareSize).rounded()))

        let squareSize = min(width / CGFloat(columns), height / CGFloat(rows))
        let contentSize = CGSize(width: squareSize * CGFloat(columns), height: squareSize * CGFloat(rows))
        let originOffset = CGPoint(
            x: max(0, (width - contentSize.width) / 2),
            y: max(0, (height - contentSize.height) / 2)
        )

        return GridMetrics(
            squareSize: squareSize,
            columns: columns,
            rows: rows,
            originOffset: originOffset,
            contentSize: contentSize,
            fitMode: .preferred,
            viewSize: size
        )
    }

    // Scale to preserve three decimal places when finding gcd.
    let precisionScale: CGFloat = 1000
    let widthUnits = max(1, Int(round(width * precisionScale)))
    let heightUnits = max(1, Int(round(height * precisionScale)))

    let gcdUnits = greatestCommonDivisor(widthUnits, heightUnits)
    guard gcdUnits > 0 else { return nil }

    let baseSquareSize = CGFloat(gcdUnits) / precisionScale
    let widthCount = widthUnits / gcdUnits
    let heightCount = heightUnits / gcdUnits

    if let requestedSquareSize, requestedSquareSize > 0, fit == .exact {
        let tolerance: CGFloat = 0.01
        let columnsExact = width / requestedSquareSize
        let rowsExact = height / requestedSquareSize
        let columnsRounded = round(columnsExact)
        let rowsRounded = round(rowsExact)

        if abs(columnsExact - columnsRounded) <= tolerance && abs(rowsExact - rowsRounded) <= tolerance {
            let columns = max(1, Int(columnsRounded))
            let rows = max(1, Int(rowsRounded))
            let contentSize = CGSize(
                width: CGFloat(columns) * requestedSquareSize,
                height: CGFloat(rows) * requestedSquareSize
            )

            return GridMetrics(
                squareSize: requestedSquareSize,
                columns: columns,
                rows: rows,
                originOffset: .zero,
                contentSize: contentSize,
                fitMode: .exact,
                viewSize: size
            )
        }

        // Fallback to the largest exact square not exceeding the requested value.
        let maxUnits = min(widthCount, heightCount)
        let requestedUnits = max(1, Int(floor(requestedSquareSize / baseSquareSize)))

        for units in stride(from: min(requestedUnits, maxUnits), through: 1, by: -1) {
            if widthCount % units == 0 && heightCount % units == 0 {
                let candidateSquare = baseSquareSize * CGFloat(units)
                let columns = widthCount / units
                let rows = heightCount / units
                let contentSize = CGSize(
                    width: CGFloat(columns) * candidateSquare,
                    height: CGFloat(rows) * candidateSquare
                )

                return GridMetrics(
                    squareSize: candidateSquare,
                    columns: columns,
                    rows: rows,
                    originOffset: .zero,
                    contentSize: contentSize,
                    fitMode: .exact,
                    viewSize: size
                )
            }
        }
    }

    let contentSize = CGSize(
        width: CGFloat(widthCount) * baseSquareSize,
        height: CGFloat(heightCount) * baseSquareSize
    )

    return GridMetrics(
        squareSize: baseSquareSize,
        columns: widthCount,
        rows: heightCount,
        originOffset: .zero,
        contentSize: contentSize,
        fitMode: .exact,
        viewSize: size
    )
}

private func greatestCommonDivisor(_ lhs: Int, _ rhs: Int) -> Int {
    var a = abs(lhs)
    var b = abs(rhs)

    while b != 0 {
        let remainder = a % b
        a = b
        b = remainder
    }

    return a
}

#Preview("Samples") {
    VStack(spacing: 24) {
        VisualGridGuide("Default")
            .foregroundStyle(.blue)
            .frame(width: 240, height: 180)

        VisualGridGuide("Preferred 12", squareSize: 12, fit: .preferred)
            .foregroundStyle(.purple)
            .frame(width: 312, height: 168)

        VisualGridGuide("Preferred 6", squareSize: 6, fit: .preferred)
            .foregroundStyle(.red)
            .frame(width: 180, height: 300)
    }
    .padding(32)
    .background(Color.gray.opacity(0.15))
}

#Preview("Fullscreen") {
    VisualGridGuide("Fullscreen", squareSize: 8, fit: .preferred)
        .ignoresSafeArea()
}
