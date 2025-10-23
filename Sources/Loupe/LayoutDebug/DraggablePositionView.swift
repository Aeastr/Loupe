//
//  DraggablePositionView.swift
//  Loupe
//
//  Created by Aether on 10/17/25.
//

import SwiftUI

// MARK: - Coordinate Space Configuration

/// Defines the coordinate space for position reporting in DraggablePositionView.
public enum DraggablePositionCoordinateSpace: Equatable, Sendable {
    /// Position relative to the immediate parent container
    case local
    /// Position relative to a named coordinate space
    case named(String)
    /// Position relative to the global screen coordinate space
    case global
}

// MARK: - Drag Constraints

/// Defines constraints for dragging behavior.
public struct DragConstraints: Equatable, Sendable {
    /// Optional horizontal range for dragging (nil = unconstrained)
    public var horizontalRange: ClosedRange<CGFloat>?

    /// Optional vertical range for dragging (nil = unconstrained)
    public var verticalRange: ClosedRange<CGFloat>?

    /// Whether to constrain dragging to horizontal axis only
    public var horizontalOnly: Bool

    /// Whether to constrain dragging to vertical axis only
    public var verticalOnly: Bool

    public init(
        horizontalRange: ClosedRange<CGFloat>? = nil,
        verticalRange: ClosedRange<CGFloat>? = nil,
        horizontalOnly: Bool = false,
        verticalOnly: Bool = false
    ) {
        self.horizontalRange = horizontalRange
        self.verticalRange = verticalRange
        self.horizontalOnly = horizontalOnly
        self.verticalOnly = verticalOnly
    }

    /// No constraints - free dragging in all directions
    public static let none = DragConstraints()

    /// Constrain to horizontal axis only
    public static let horizontal = DragConstraints(horizontalOnly: true)

    /// Constrain to vertical axis only
    public static let vertical = DragConstraints(verticalOnly: true)
}

// MARK: - Environment Configuration

/// Interactivity options for DraggablePositionView.
public struct DraggablePositionViewInteractionsConfiguration: Equatable {
    public var dragEnabled: Bool
    public var persistenceEnabled: Bool
    public var persistenceNamespace: String?

    public init(dragEnabled: Bool = false, persistenceEnabled: Bool = false, persistenceNamespace: String? = nil) {
        self.dragEnabled = dragEnabled
        self.persistenceEnabled = persistenceEnabled
        self.persistenceNamespace = persistenceNamespace
    }
}

private struct DraggablePositionViewInteractionsKey: EnvironmentKey {
    nonisolated(unsafe) static let defaultValue = DraggablePositionViewInteractionsConfiguration()
}

public extension EnvironmentValues {
    var draggablePositionViewInteractions: DraggablePositionViewInteractionsConfiguration {
        get { self[DraggablePositionViewInteractionsKey.self] }
        set { self[DraggablePositionViewInteractionsKey.self] = newValue }
    }
}

public extension View {
    /// Enables or disables dragging/persistence for DraggablePositionView within the view hierarchy.
    func draggablePositionViewInteractions(dragEnabled: Bool, persistenceEnabled: Bool = false, persistenceNamespace: String? = nil) -> some View {
        environment(
            \.draggablePositionViewInteractions,
             DraggablePositionViewInteractionsConfiguration(
                dragEnabled: dragEnabled,
                persistenceEnabled: persistenceEnabled,
                persistenceNamespace: persistenceNamespace
             )
        )
    }
}

/// Configuration for DraggablePositionView drag constraints.
public struct DraggablePositionViewConstraintsConfiguration: Equatable {
    public var constraints: DragConstraints

    public init(constraints: DragConstraints = .none) {
        self.constraints = constraints
    }
}

private struct DraggablePositionViewConstraintsKey: EnvironmentKey {
    nonisolated(unsafe) static let defaultValue = DraggablePositionViewConstraintsConfiguration()
}

public extension EnvironmentValues {
    var draggablePositionViewConstraints: DraggablePositionViewConstraintsConfiguration {
        get { self[DraggablePositionViewConstraintsKey.self] }
        set { self[DraggablePositionViewConstraintsKey.self] = newValue }
    }
}

public extension View {
    /// Configures drag constraints for DraggablePositionView within the view hierarchy.
    func draggablePositionViewConstraints(_ constraints: DragConstraints) -> some View {
        environment(\.draggablePositionViewConstraints, DraggablePositionViewConstraintsConfiguration(constraints: constraints))
    }
}

// MARK: - DraggablePositionView

/// A visual debugging tool that displays a draggable overlay showing position and size information.
///
/// `DraggablePositionView` is designed for development and debugging, providing a semi-transparent overlay
/// that shows the view's exact position and size, with optional drag functionality to test layout behavior.
///
/// ## Features
///
/// - **Visual Bounds**: Semi-transparent shape showing the view's exact boundaries
/// - **Position Display**: Real-time x and y coordinates in the specified coordinate space
/// - **Size Display**: Real-time width and height measurements
/// - **Draggable**: Optional drag gesture for manual repositioning
/// - **Constraint System**: Limit dragging to specific axes or ranges
/// - **Coordinate Space Options**: Report position relative to local, named, or global space
///
/// ## Basic Usage
///
/// ```swift
/// ZStack {
///     Color.blue
///         .overlay {
///             DraggablePositionView("Content Area")
///         }
/// }
/// ```
///
/// ## With Dragging
///
/// ```swift
/// ZStack {
///     Color.blue
///         .overlay {
///             DraggablePositionView("Drag Me")
///         }
/// }
/// .draggablePositionViewInteractions(dragEnabled: true)
/// ```
///
/// ## Custom Coordinate Space
///
/// ```swift
/// DraggablePositionView(
///     "Global Position",
///     coordinateSpace: .global
/// )
/// ```
///
/// ## With Constraints
///
/// ```swift
/// DraggablePositionView("Horizontal Only")
///     .draggablePositionViewInteractions(dragEnabled: true)
///     .draggablePositionViewConstraints(.horizontal)
/// ```
///
/// ## Position Change Callback
///
/// ```swift
/// DraggablePositionView("Track Position") { position, size in
///     print("Position: \(position), Size: \(size)")
/// }
/// .draggablePositionViewInteractions(dragEnabled: true)
/// ```
///
/// ## Start Position
///
/// ```swift
/// DraggablePositionView(
///     "Offset Label",
///     startPosition: CGSize(width: 100, height: 50)
/// )
/// ```
public struct DraggablePositionView: View {
    @State private var viewPosition: CGPoint = .zero
    @State private var overlaySize: CGSize = .zero
    @State private var screenBounds: CGRect = .zero
    @State private var persistedManualOffset: CGSize = .zero
    @State private var activeDragOffset: CGSize = .zero
    @State private var lastLoadedPersistenceKey: String?

    @Environment(\.draggablePositionViewInteractions) private var interactions
    @Environment(\.draggablePositionViewConstraints) private var constraintsConfig

    var label: String?
    var coordinateSpace: DraggablePositionCoordinateSpace
    var startPosition: CGSize
    private let persistenceIdentifier: String?
    var onChange: ((CGPoint, CGSize) -> Void)?

    /// Creates a draggable position view with optional label and configuration.
    ///
    /// - Parameters:
    ///   - label: Optional text label to display in the info overlay
    ///   - coordinateSpace: Coordinate space for position reporting (default: `.local`)
    ///   - startPosition: Initial offset from the natural position (default: `.zero`)
    ///   - persistenceKey: Optional stable identifier used when persisting manual offsets
    ///   - onChange: Optional callback when position changes
    ///
    /// ## Example
    ///
    /// ```swift
    /// DraggablePositionView("Content", persistenceKey: "content-position")
    /// ```
    public init(
        _ label: String? = nil,
        coordinateSpace: DraggablePositionCoordinateSpace = .local,
        startPosition: CGSize = .zero,
        persistenceKey: String? = nil
    ) {
        self.label = label
        self.coordinateSpace = coordinateSpace
        self.startPosition = startPosition
        self.persistenceIdentifier = persistenceKey ?? label
    }

    public var body: some View {
        Circle()
            .opacity(0.0)
            .background(.thinMaterial, in: .circle)
            .overlay {
                ZStack{
                    Rectangle()
                        .frame(width: 1)
                    Rectangle()
                        .frame(height: 1)
                    Circle()
                        .foregroundStyle(.black)
                        .frame(width: 1)
                }
            }
            .onGeometryChange(for: CGPoint.self) { proxy in
                let frame = proxy.frame(in: coordinateSpaceValue)
                return frame.origin
            } action: { newValue in
                print("\(newValue)")
                viewPosition = newValue
            }
            .overlay(alignment: .bottom){
                overlayContent
                    .fixedSize()
                    .onGeometryChange(for: CGSize.self) { proxy in
                        proxy.size
                    } action: { newValue in
                        overlaySize = newValue
                    }
                    .offset(y: overlayYOffset)
            }
            .background {
                GeometryReader { proxy in
                    Color.clear
                        .onAppear {
                            screenBounds = proxy.frame(in: .global)
                        }
                        .onChange(of: proxy.frame(in: .global)) { _, newValue in
                            screenBounds = newValue
                        }
                }
            }
            .gesture(interactions.dragEnabled ? dragGesture : nil)


            .offset(
                x: startPosition.width + manualOffset.width,
                y: startPosition.height + manualOffset.height
            )
            .onChange(of: interactions) { _ in
                handleInteractionChange()
            }
            .onChange(of: persistenceStorageKey) { _ in
                let restored = restorePersistedOffsetIfNeeded(force: true)
                if !restored {
                    persistManualOffset()
                }
            }
            .onAppear {
                if isPersistenceEnabled {
                    restorePersistedOffsetIfNeeded(force: false)
                } else {
                    persistedManualOffset = .zero
                }
            }
    }

    // MARK: - Shape View

    @ViewBuilder
    private var shapeView: some View {
        Rectangle()
            .fill(.clear)
    }

    // MARK: - Overlay Content

    @ViewBuilder
    private var overlayContent: some View {
        VStack(spacing: 6) {
            if let label {
                Text(label)
                    .font(.caption.weight(.semibold))
            }

            VStack(spacing: 2) {
                Text("x: \(adjustedPosition.x, specifier: "%.1f")  y: \(adjustedPosition.y, specifier: "%.1f")")
                    .font(.caption2.monospacedDigit())
            }
            .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(.thinMaterial, in: .rect(cornerRadius: 20))
    }

    // MARK: - Drag Gesture

    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 1, coordinateSpace: .global)
            .onChanged { value in
                guard interactions.dragEnabled else { return }
                activeDragOffset = value.translation
            }
            .onEnded { value in
                guard interactions.dragEnabled else { return }
                persistedManualOffset.width += value.translation.width
                persistedManualOffset.height += value.translation.height
                activeDragOffset = .zero
                persistManualOffset()
            }
    }

    // MARK: - Helpers

    private var coordinateSpaceValue: CoordinateSpace {
        switch coordinateSpace {
        case .local:
            return .local
        case .named(let name):
            return .named(name)
        case .global:
            return .global
        }
    }

    private var manualOffset: CGSize {
        CGSize(
            width: persistedManualOffset.width + activeDragOffset.width,
            height: persistedManualOffset.height + activeDragOffset.height
        )
    }

    private var isPersistenceEnabled: Bool {
        persistenceStorageKey != nil
    }

    private var persistenceStorageKey: String? {
        guard interactions.persistenceEnabled else { return nil }
        guard let identifier = persistenceIdentifier ?? label else { return nil }

        let sanitizedComponents = identifier.components(separatedBy: CharacterSet.alphanumerics.inverted).filter { !$0.isEmpty }
        let base = sanitizedComponents.joined(separator: "_")
        guard !base.isEmpty else { return nil }
        let namespace = (interactions.persistenceNamespace?.isEmpty ?? true) ? "DraggablePositionView" : interactions.persistenceNamespace!
        return "\(namespace).\(base)"
    }

    private func persistManualOffset() {
        guard isPersistenceEnabled, let key = persistenceStorageKey else { return }
        UserDefaults.standard.set(
            [Double(persistedManualOffset.width), Double(persistedManualOffset.height)],
            forKey: key
        )
    }

    @discardableResult
    private func restorePersistedOffsetIfNeeded(force: Bool) -> Bool {
        guard let key = persistenceStorageKey else {
            if force {
                lastLoadedPersistenceKey = nil
            }
            return false
        }

        if !force, lastLoadedPersistenceKey == key { return true }
        lastLoadedPersistenceKey = key

        guard let stored = UserDefaults.standard.array(forKey: key) as? [Double], stored.count == 2 else {
            return false
        }

        let restoredOffset = CGSize(width: CGFloat(stored[0]), height: CGFloat(stored[1]))
        if restoredOffset != persistedManualOffset {
            persistedManualOffset = restoredOffset
        }
        return true
    }

    private func handleInteractionChange() {
        if !interactions.dragEnabled {
            activeDragOffset = .zero
        }

        if isPersistenceEnabled {
            let restored = restorePersistedOffsetIfNeeded(force: true)
            if !restored {
                persistManualOffset()
            }
        } else {
            lastLoadedPersistenceKey = nil
            persistedManualOffset = .zero
        }
    }

    private var adjustedPosition: CGPoint {
        CGPoint(
            x: viewPosition.x + startPosition.width + manualOffset.width,
            y: viewPosition.y + startPosition.height + manualOffset.height
        )
    }

    private var overlayYOffset: CGFloat {
        let defaultOffset = (overlaySize.height) + 8

        // Calculate the bottom edge of the overlay in global coordinates
        let circleBottomY = viewPosition.y + startPosition.height + manualOffset.height
        let overlayBottomY = circleBottomY + defaultOffset + (overlaySize.height / 2)
        #if canImport(UIKit)
        // Get screen height from global bounds
        let screenHeight = UIScreen.main.bounds.height
        // If overlay would go off screen, flip it above the circle
        if overlayBottomY > screenHeight {
            return -(((overlaySize.height) / 2) + 8)
        }

#endif // TEMP FIX

        return defaultOffset
    }

}


// MARK: - Preview

#Preview("DraggablePositionView") {
    ZStack {
        LinearGradient(
            colors: [.blue.opacity(0.3), .purple.opacity(0.3)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()

        ZStack(alignment: .topLeading) {
            DraggablePositionView("Drag Me")
                .frame(width: 15)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        .draggablePositionViewInteractions(dragEnabled: true, persistenceEnabled: true, persistenceNamespace: "demo")
    }
    .ignoresSafeArea()
}
