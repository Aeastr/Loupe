//
//  VisualLayoutGuide.swift
//  Loupe
//
//  Created by Aether on 10/16/25.
//

import SwiftUI

// MARK: - Environment Toggle

/// Defines strategy options for visual layout guide positioning.
public enum VisualLayoutGuidePositioningMode {
    case auto
    case disabled
}

private struct VisualLayoutGuidePositioningKey: EnvironmentKey {
    nonisolated(unsafe) static let defaultValue: VisualLayoutGuidePositioningMode = .auto
}

public extension EnvironmentValues {
    var visualLayoutGuidePositioning: VisualLayoutGuidePositioningMode {
        get { self[VisualLayoutGuidePositioningKey.self] }
        set { self[VisualLayoutGuidePositioningKey.self] = newValue }
    }
}

public extension View {
    /// Controls whether visual layout guides avoid overlapping information overlays.
    func visualLayoutGuidePositioning(_ mode: VisualLayoutGuidePositioningMode) -> some View {
        environment(\.visualLayoutGuidePositioning, mode)
    }
}

/// Interactivity options for manipulating and persisting visual layout guides.
public struct VisualLayoutGuideInteractionsConfiguration: Equatable {
    public var dragEnabled: Bool
    public var persistenceEnabled: Bool
    public var persistenceNamespace: String?

    public init(dragEnabled: Bool = false, persistenceEnabled: Bool = false, persistenceNamespace: String? = nil) {
        self.dragEnabled = dragEnabled
        self.persistenceEnabled = persistenceEnabled
        self.persistenceNamespace = persistenceNamespace
    }
}

private struct VisualLayoutGuideInteractionsKey: EnvironmentKey {
    nonisolated(unsafe) static let defaultValue = VisualLayoutGuideInteractionsConfiguration()
}

public extension EnvironmentValues {
    var visualLayoutGuideInteractions: VisualLayoutGuideInteractionsConfiguration {
        get { self[VisualLayoutGuideInteractionsKey.self] }
        set { self[VisualLayoutGuideInteractionsKey.self] = newValue }
    }
}

public extension View {
    /// Enables or disables dragging/persistence for visual layout guides within the view hierarchy.
    func visualLayoutGuideInteractions(dragEnabled: Bool, persistenceEnabled: Bool, persistenceNamespace: String? = nil) -> some View {
        environment(
            \.visualLayoutGuideInteractions,
            VisualLayoutGuideInteractionsConfiguration(
                dragEnabled: dragEnabled,
                persistenceEnabled: persistenceEnabled,
                persistenceNamespace: persistenceNamespace
            )
        )
    }
}

// MARK: - Overlay Position Coordinator

/// A coordinator that manages the positioning of multiple overlay labels to prevent overlaps.
///
/// This coordinator tracks the frames and positions of all overlay labels in a view hierarchy,
/// calculating vertical offsets to ensure overlapping labels are stacked cleanly with proper spacing.
///
/// The coordinator maintains:
/// - Frame information for each overlay
/// - Insertion order to determine stacking priority
/// - Cached offsets for efficient recalculation
///
/// ## Usage
///
/// A default coordinator is automatically provided, enabling collision detection by default.
/// Optionally inject a custom coordinator to isolate collision detection to specific view hierarchies:
///
/// ```swift
/// ZStack {
///     VisualLayoutGuide("Label 1")
///     VisualLayoutGuide("Label 2")
/// }
/// .environment(\.overlayCoordinator, OverlayPositionCoordinator()) // Optional
/// ```
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
@Observable
class OverlayPositionCoordinator {
    /// Dictionary mapping overlay IDs to their frame rectangles in global coordinates.
    private var overlayFrames: [UUID: CGRect] = [:]

    /// Array tracking the order in which overlays were registered.
    /// Earlier overlays have priority and later ones will be offset if they overlap.
    private var insertionOrder: [UUID] = []

    /// Cache of calculated vertical offsets for each overlay.
    private var cachedOffsets: [UUID: CGFloat] = [:]

    /// Monotonically increasing revision used to notify listeners of recomputed offsets.
    var offsetsRevision: Int = 0

    private let spacing: CGFloat = 8
    private var autoPositioningDisabledOverlays: Set<UUID> = []
    private var manualOffsets: [UUID: CGSize] = [:]

    /// Updates or inserts an overlay with its latest frame information and returns the resolved offset.
    func updateOverlay(id: UUID, frame: CGRect, autoPositioningEnabled: Bool, manualOffset: CGSize) -> CGFloat {
        overlayFrames[id] = frame
        manualOffsets[id] = manualOffset
        if !insertionOrder.contains(id) {
            insertionOrder.append(id)
        }

        guard autoPositioningEnabled else {
            autoPositioningDisabledOverlays.insert(id)
            cachedOffsets[id] = 0
            offsetsRevision += 1
            return 0
        }

        autoPositioningDisabledOverlays.remove(id)
        recalculateOffsets()
        return cachedOffsets[id] ?? 0
    }

    /// Removes overlay and recalculates offsets for remaining overlays.
    func deregisterOverlay(id: UUID) {
        overlayFrames.removeValue(forKey: id)
        insertionOrder.removeAll { $0 == id }
        cachedOffsets.removeValue(forKey: id)
        autoPositioningDisabledOverlays.remove(id)
        manualOffsets.removeValue(forKey: id)

        recalculateOffsets()
    }

    /// Returns the current offset for a given overlay identifier.
    func offset(for id: UUID) -> CGFloat {
        if autoPositioningDisabledOverlays.contains(id) {
            return 0
        }

        return cachedOffsets[id] ?? 0
    }

    /// Recomputes all overlay offsets to ensure stable stacking when frames change.
    private func recalculateOffsets() {
        var resolvedFrames: [UUID: CGRect] = [:]
        var newOffsets: [UUID: CGFloat] = [:]

        for (currentIndex, id) in insertionOrder.enumerated() {
            guard let frame = overlayFrames[id] else { continue }
            let manualOffset = manualOffsets[id] ?? .zero
            let baseFrame = frame.offsetBy(dx: manualOffset.width, dy: manualOffset.height)

            guard !autoPositioningDisabledOverlays.contains(id) else {
                resolvedFrames[id] = baseFrame
                newOffsets[id] = 0
                continue
            }

            var offset: CGFloat = 0

            for priorIndex in 0..<currentIndex {
                let otherId = insertionOrder[priorIndex]
                guard let otherFrame = resolvedFrames[otherId] else { continue }
                guard !autoPositioningDisabledOverlays.contains(otherId) else { continue }

                let adjustedFrame = baseFrame.offsetBy(dx: 0, dy: offset)
                let horizontalOverlap = adjustedFrame.minX < otherFrame.maxX && adjustedFrame.maxX > otherFrame.minX
                let verticalOverlap = adjustedFrame.minY < otherFrame.maxY && adjustedFrame.maxY > otherFrame.minY

                if horizontalOverlap && verticalOverlap {
                    let requiredOffset = otherFrame.maxY - baseFrame.minY + spacing
                    offset = max(offset, requiredOffset)
                }
            }

            newOffsets[id] = offset
            resolvedFrames[id] = baseFrame.offsetBy(dx: 0, dy: offset)
        }

        cachedOffsets = newOffsets
        offsetsRevision += 1
    }
}

// MARK: - Environment Key for Coordinator

private struct OverlayCoordinatorKey: EnvironmentKey {
    nonisolated(unsafe) static let defaultValue = OverlayPositionCoordinator()
}

extension EnvironmentValues {
    var overlayCoordinator: OverlayPositionCoordinator {
        get { self[OverlayCoordinatorKey.self] }
        set { self[OverlayCoordinatorKey.self] = newValue }
    }
}

// MARK: - Shape Type

/// The shape style for the layout guide visualization.
public enum VisualLayoutGuideShape {
    /// Standard rectangle shape (available on all OS versions)
    case rectangle

    /// Concentric rectangle with rounded corners (iOS 26+, macOS 26+, tvOS 26+, watchOS 26+)
    @available(iOS 26.0, macOS 26.0, tvOS 26.0, watchOS 26.0, *)
    case concentricRectangle
}

// MARK: - VisualLayoutGuide

/// A visual debugging tool that displays layout bounds, safe area insets, and size information.
///
/// `VisualLayoutGuide` is designed for development and debugging, providing a semi-transparent overlay
/// that shows the actual bounds of a view along with detailed metrics about its size and safe area insets.
///
/// ## Features
///
/// - **Visual Bounds**: Semi-transparent shape with border showing the view's exact boundaries
/// - **Size Display**: Real-time width and height measurements
/// - **Inset Information**: Top, leading, bottom, and trailing safe area insets
/// - **Automatic Label Positioning**: Configurable alignment for the info overlay
/// - **Collision Avoidance**: Automatic stacking of overlapping labels
/// - **Shape Options**: Rectangle or ConcentricRectangle (iOS 26+)
/// - **Environment Toggle**: Choose `.visualLayoutGuidePositioning(.auto)` (default) or `.disabled`
/// - **Draggable Overlays**: Opt-in with `.visualLayoutGuideInteractions(dragEnabled:persistenceEnabled:)`
/// - **Persistent Positions**: Provide a `persistenceKey` or label plus enable persistence to store manual offsets
///
/// ## Basic Usage
///
/// ```swift
/// ZStack {
///     Color.blue
///         .overlay {
///             VisualLayoutGuide("Content Area")
///         }
/// }
/// ```
///
/// Collision detection works automatically with a shared default coordinator.
///
/// ## Custom Alignment
///
/// Position the info label at different locations:
///
/// ```swift
/// VisualLayoutGuide("Top Leading", alignment: .topLeading)
/// VisualLayoutGuide("Bottom", alignment: .bottom)
/// VisualLayoutGuide("Trailing", alignment: .trailing)
/// ```
///
/// ## Shape Options
///
/// Choose between standard rectangles or concentric rectangles (iOS 26+):
///
/// ```swift
/// VisualLayoutGuide("Standard", shape: .rectangle)
///
/// if #available(iOS 26.0, *) {
///     VisualLayoutGuide("Modern", shape: .concentricRectangle)
/// }
/// ```
///
/// ## Multiple Guides
///
/// Collision detection works automatically when using multiple guides:
///
/// ```swift
/// ZStack {
///     VisualLayoutGuide("View 1")
///     VisualLayoutGuide("View 2")
///     VisualLayoutGuide("View 3")
/// }
/// ```
///
/// Labels that would overlap will automatically stack vertically with 8pt spacing.
///
/// Optionally inject a custom coordinator to isolate collision detection:
///
/// ```swift
/// // Isolated collision detection within this hierarchy
/// .environment(\.overlayCoordinator, OverlayPositionCoordinator())
/// ```
///
/// ## Positioning Mode
///
/// Disable collision avoidance inside a container:
///
/// ```swift
/// VStack {
///     VisualLayoutGuide("A")
///     VisualLayoutGuide("B")
/// }
/// .visualLayoutGuidePositioning(.disabled)
/// ```
///
/// Re-enable automatic stacking explicitly:
///
/// ```swift
/// .visualLayoutGuidePositioning(.auto)
/// ```
///
/// ## Interactivity & Persistence
///
/// Allow guides to be dragged (and optionally persisted) inside a hierarchy:
///
/// ```swift
/// VStack {
///     VisualLayoutGuide("Primary", persistenceKey: "primary-guide")
///     VisualLayoutGuide("Secondary", persistenceKey: "secondary-guide")
/// }
/// .visualLayoutGuideInteractions(dragEnabled: true, persistenceEnabled: true, persistenceNamespace: "debug")
/// ```
///
/// When persistence is enabled, offsets are stored in `UserDefaults.standard` using the provided key
/// (or the label when no key is supplied).
///
/// ## Safe Area Testing
///
/// Perfect for testing safe area behavior:
///
/// ```swift
/// ZStack {
///     VisualLayoutGuide("In Safe Area")
///
///     VisualLayoutGuide("Ignoring Safe Area")
///         .ignoresSafeArea()
/// }
/// ```
///
/// ## Important Notes
///
/// - Collision detection works automatically with the default shared coordinator
/// - Optionally inject a custom coordinator to isolate collision detection to specific hierarchies
/// - The coordinator uses insertion order to determine stacking priority
/// - Only overlays that actually collide will be offset
public struct VisualLayoutGuide: View {
    @State var viewSize: CGSize?
    @State var viewInsets: EdgeInsets?
    @State private var latestOverlayFrame: CGRect = .zero
    @State private var overlayOffset: CGFloat = 0
    @State private var persistedManualOffset: CGSize = .zero
    @State private var activeDragOffset: CGSize = .zero
    @State private var lastLoadedPersistenceKey: String?

    @Environment(\.overlayCoordinator) private var coordinator
    @Environment(\.visualLayoutGuidePositioning) private var positioningMode
    @Environment(\.visualLayoutGuideInteractions) private var interactions

    var label: String?
    var alignment: Alignment
    var shape: VisualLayoutGuideShape
    private let persistenceIdentifier: String?
    private let id = UUID()

    /// Creates a visual layout guide with optional label and alignment.
    ///
    /// - Parameters:
    ///   - label: Optional text label to display in the info overlay
    ///   - alignment: Position of the info overlay within the bounds (default: `.center`)
    ///   - shape: The shape style for visualization (default: `.rectangle`)
    ///   - persistenceKey: Optional stable identifier used when persisting manual offsets
    ///
    /// ## Example
    ///
    /// ```swift
    /// VisualLayoutGuide("Content", alignment: .top)
    /// ```
    public init(
        _ label: String? = nil,
        alignment: Alignment = .center,
        shape: VisualLayoutGuideShape = .rectangle,
        persistenceKey: String? = nil
    ) {
        self.label = label
        self.alignment = alignment
        self.shape = shape
        self.persistenceIdentifier = persistenceKey ?? label
    }

    public var body: some View {
        shapeView
            .allowsHitTesting(false)
            .overlay(alignment: alignment) {
                overlayContent
                    .offset(x: manualOffset.width, y: overlayOffset + manualOffset.height)
                    .onGeometryChange(for: CGRect.self) { proxy in
                        proxy.frame(in: .global)
                    } action: { newFrame in
                        updateOverlayPosition(frame: newFrame)
                    }
            }
            .onGeometryChange(for: CGSize.self) { proxy in
                return proxy.size
            } action: { newValue in
                viewSize = newValue
            }
            .onGeometryChange(for: EdgeInsets.self) { proxy in
                return proxy.safeAreaInsets
            } action: { newValue in
                viewInsets = newValue
            }
            .onChange(of: coordinator.offsetsRevision) { _ in
                overlayOffset = coordinator.offset(for: id)
            }
            .onChange(of: positioningMode) { _ in
                refreshOverlayOffset()
            }
            .onChange(of: interactions) { _ in
                handleInteractionChange()
            }
            .onChange(of: persistedManualOffset) { _ in
                refreshOverlayOffset()
            }
            .onChange(of: activeDragOffset) { _ in
                refreshOverlayOffset()
            }
            .onChange(of: persistenceStorageKey) { _ in
                let restored = restorePersistedOffsetIfNeeded(force: true)
                if !restored {
                    persistManualOffset()
                }
            }
            .onDisappear {
                coordinator.deregisterOverlay(id: id)
            }
            .onAppear {
                restorePersistedOffsetIfNeeded(force: false)
            }
    }

    /// Updates the overlay position and registers it with the coordinator for collision detection.
    private func updateOverlayPosition(frame: CGRect) {
        latestOverlayFrame = frame
        refreshOverlayOffset()
    }

    private func refreshOverlayOffset() {
        guard latestOverlayFrame.size != .zero else { return }
        overlayOffset = coordinator.updateOverlay(
            id: id,
            frame: latestOverlayFrame,
            autoPositioningEnabled: isAutoPositioningEnabled,
            manualOffset: manualOffset
        )
    }

    private var isAutoPositioningEnabled: Bool {
        positioningMode == .auto
    }

    private var isDraggingEnabled: Bool {
        interactions.dragEnabled
    }

    private var isPersistenceEnabled: Bool {
        persistenceStorageKey != nil
    }

    private var manualOffset: CGSize {
        CGSize(
            width: persistedManualOffset.width + activeDragOffset.width,
            height: persistedManualOffset.height + activeDragOffset.height
        )
    }

    private var persistenceStorageKey: String? {
        guard interactions.persistenceEnabled else { return nil }
        guard let identifier = persistenceIdentifier ?? label else { return nil }

        let sanitizedComponents = identifier.components(separatedBy: CharacterSet.alphanumerics.inverted).filter { !$0.isEmpty }
        let base = sanitizedComponents.joined(separator: "_")
        guard !base.isEmpty else { return nil }
        let namespace = (interactions.persistenceNamespace?.isEmpty ?? true) ? "VisualLayoutGuide" : interactions.persistenceNamespace!
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
        if !isDraggingEnabled {
            activeDragOffset = .zero
        }

        if isPersistenceEnabled {
            let restored = restorePersistedOffsetIfNeeded(force: true)
            if !restored {
                persistManualOffset()
            }
        } else {
            lastLoadedPersistenceKey = nil
        }

        refreshOverlayOffset()
    }

    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 1, coordinateSpace: .global)
            .onChanged { value in
                guard isDraggingEnabled else { return }
                activeDragOffset = value.translation
            }
            .onEnded { value in
                guard isDraggingEnabled else { return }
                persistedManualOffset.width += value.translation.width
                persistedManualOffset.height += value.translation.height
                activeDragOffset = .zero
                persistManualOffset()
            }
    }

    /// The visual shape representation (rectangle or concentric rectangle).
    @ViewBuilder
    private var shapeView: some View {
        switch shape {
        case .rectangle:
            Rectangle().opacity(0.2).border(.primary, width: 3)
        case .concentricRectangle:
            if #available(iOS 26.0, macOS 26.0, tvOS 26.0, watchOS 26.0, *) {
                ConcentricRectangle().opacity(0.2).overlay(ConcentricRectangle().stroke(.primary, lineWidth: 3).padding(1.5))
            } else {
                Rectangle().opacity(0.2).border(.primary.opacity(0.5), width: 3)
            }
        }
    }
    let scale: CGFloat = 5
    /// The info overlay displaying label, size, and insets.
    @ViewBuilder
    private var overlayContent: some View {
        if isDraggingEnabled {
            overlayCoreContent.contentShape(.rect).simultaneousGesture(dragGesture)
        } else {
            overlayCoreContent
        }
    }

    private var overlayCoreContent: some View {
        ZStack {
            // Inset indicators
            if let insets = viewInsets {

                Rectangle()
                    .frame(height: insets.top / scale)
                    .opacity(0.3)
                    .overlay {
                        HStack(spacing: 5){
                            Text("to\(Int(insets.top))")
                            Image(systemName: "arrow.down")
                        }
                            .font(.system(size: 8).monospaced().weight(.black))
                            .fixedSize()
                    }

                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)


                Rectangle()
                    .frame(width: insets.leading / scale)
                    .opacity(0.3)
                    .overlay {
                        VStack(spacing: 5){
                            Text("le\(Int(insets.leading))")
                            Image(systemName: "arrow.right")
                        }
                            .font(.system(size: 8).monospaced().weight(.black))
                            .fixedSize()
                    }

                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)



                Rectangle()
                    .frame(height: insets.bottom / scale)
                    .opacity(0.3)
                    .overlay {
                        HStack(spacing: 5){
                            Text("bo\(Int(insets.bottom))")
                            Image(systemName: "arrow.up")
                        }
                            .font(.system(size: 8).monospaced().weight(.black))
                            .fixedSize()
                    }

                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)



                Rectangle()
                    .frame(width: insets.trailing / scale)
                    .opacity(0.3)
                    .overlay {
                        VStack(spacing: 5){
                            Text("tr\(Int(insets.trailing))")
                            Image(systemName: "arrow.left")
                        }
                            .font(.system(size: 8).monospaced().weight(.black))
                            .fixedSize()
                    }

                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .trailing)

            }

            ZStack{
                // Height indicator (left side)
                HStack(spacing: 3){
                    Rectangle()
                        .frame(width: 2)
                    if let viewSize {
                        Text("y\(Int(viewSize.height))")
                            .font(.system(size: 10).monospaced())
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                // Width indicator (bottom)
                VStack(spacing: 3){
                    if let viewSize {
                        Text("x\(Int(viewSize.width))")
                            .font(.system(size: 10).monospaced())
                    }
                    Rectangle()
                        .frame(height: 2)
                }
                .frame(maxHeight: .infinity, alignment: .bottom)

                if let label{
                    Text(label)
                        .font(.system(size: 10).monospaced().weight(.black))
                        .underline()
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                }
            }
            .padding(.top, ((viewInsets?.top ?? 0) / scale) + 8)
            .padding(.bottom, ((viewInsets?.bottom ?? 0) / scale) + 8)
            .padding(.leading, ((viewInsets?.leading ?? 0) / scale) + 8)
            .padding(.trailing, ((viewInsets?.trailing ?? 0) / scale) + 8)
        }
        .frame(width: 130, height: 130)
        .background(.thinMaterial, in: .rect)
    }
}

#Preview {
    ZStack{
        VisualLayoutGuide(".ignoresSafeArea")
            .foregroundStyle(.red)
            .ignoresSafeArea()

        VisualLayoutGuide("Bounds")
            .foregroundStyle(.blue)
    }
    .visualLayoutGuideInteractions(dragEnabled: true, persistenceEnabled: true)
    .visualLayoutGuidePositioning(.auto)
}



#Preview("VisualLayoutGuide - OS 26 Only") {
    ZStack{
        if #available(iOS 26.0, macOS 26.0, *) {
            VisualLayoutGuide("Blue Basic", shape: .concentricRectangle)
                .foregroundStyle(.blue)

            VisualLayoutGuide("Green Bottom Alligned", alignment: .bottom, shape: .concentricRectangle)
                .foregroundStyle(.green)

            VisualLayoutGuide("Red .ignoresSafeArea", shape: .concentricRectangle)
                .foregroundStyle(.red)
                .padding(5)
                .ignoresSafeArea()
        }
        else{
            Text("This Feature is only avaiable in OS 26")
        }
    }
}

#Preview("Blank Test"){

}
