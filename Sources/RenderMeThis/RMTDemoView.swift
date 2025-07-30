//
//  RenderDebugDemoView.swift
//  RenderMeThis
//
//  Created by Aether on 25/04/2025.
//

import SwiftUI

@available(iOS 15.0, *)
public struct RenderDebugDemoView: View {
    @State private var counter = 0
    @State private var text = ""
    @State private var showExtraView = false
    @Environment(\.colorScheme) private var colorScheme
    
    public init() {}
    
    public var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                headerSection
                
                // Info
                infoSection
                
                // Main content
                VStack(spacing: 16) {
                    renderDebugSection
                    computeDebugSectionNE
                    computeDebugSection
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .background(
            LinearGradient(
                gradient: backgroundGradient,
                startPoint: .top,
                endPoint: .bottom
            )
            .modifier(ConditionalIgnoresSafeAreaModifier())
        )
    }
    
    // MARK: - UI Components
    
    private var backgroundGradient: Gradient {
        #if os(macOS)
        let topColor = colorScheme == .dark ? Color.black : Color(NSColor.controlBackgroundColor)
        let bottomColor = colorScheme == .dark ? Color(NSColor.controlBackgroundColor) : Color(NSColor.windowBackgroundColor)
        #elseif os(tvOS)
        let topColor = colorScheme == .dark ? Color.black : Color.gray.opacity(0.3)
        let bottomColor = colorScheme == .dark ? Color.gray.opacity(0.3) : Color.black
        #elseif os(watchOS)
        let topColor = colorScheme == .dark ? Color.black : Color.gray.opacity(0.2)
        let bottomColor = colorScheme == .dark ? Color.gray.opacity(0.1) : Color.black
        #else
        let topColor = colorScheme == .dark ? Color.black : Color(uiColor: .systemGray6)
        let bottomColor = colorScheme == .dark ? Color(uiColor: .systemGray6) : Color(uiColor: .systemBackground)
        #endif
        return Gradient(colors: [topColor, bottomColor])
    }
    
    private var headerSection: some View {
        VStack(spacing: 8) {
            #if os(macOS)
            if #available(macOS 11.0, *) {
                Image(systemName: "viewfinder")
                    .font(.system(size: 40))
                    .foregroundColor(.purple)
                    .padding(.bottom, 4)
                    .debugCompute()
            } else {
                Text("(icon)")
                    .foregroundColor(.purple)
                    .padding(.bottom, 4)
                    .debugCompute()
            }
            #else
            Image(systemName: "viewfinder")
                .font(.system(size: 40))
                .foregroundColor(.purple)
                .padding(.bottom, 4)
                .debugCompute()
            #endif
            
            Text("Render Debug Demo")
                .font(.title)
                .fontWeight(.bold)
                .debugCompute()
            
            Text("Visualize when SwiftUI updates your views")
                .font(.caption)
                .modifier(SecondaryForegroundStyleModifier())
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
                .debugCompute()
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(sectionBackgroundColor)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        )
        .padding(.horizontal)
        .debugCompute()
    }
    
    private var infoSection: some View {
        VStack {
            Text("Interact with controls to see visual updates")
                .font(.caption)
                .modifier(SecondaryForegroundStyleModifier())
                .debugCompute()
        }
        .padding()
    }
    
    // MARK: - Debug Sections
    
    private var renderDebugSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("debugRender()")
                .debugCompute()
                .font(.headline)
                .padding(.bottom, 4)
                .debugRender()
            
            Text("Shows redraws with a colored background")
                .font(.caption)
                .debugCompute()
                .modifier(SecondaryForegroundStyleModifier())
                .padding(.bottom, 8)
                .debugRender()
            
            // This view will show a colored background when redrawn
            VStack {
                Text("This text shows counter: \(counter)")
                    .debugCompute()
                    .padding()
                    .debugRender()
            }
            .frame(maxWidth: .infinity)
            .background(Color.white.opacity(0.1))
            .cornerRadius(12)
            
            Button(action: {
                counter += 1
            }) {
                HStack {
                    Text("Increment Counter")
                    Spacer()
                    Image(systemName: "arrow.clockwise")
                }
                .padding()
                .foregroundColor(.white)
                .background(Color.purple)
                .cornerRadius(8)
            }
            .buttonStyle(BounceButtonStyle())
            .padding(5)
            .debugRender()
            .debugCompute()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(sectionBackgroundColor)
                .shadow(color: Color.black.opacity(0.06), radius: 7, x: 0, y: 2)
        )
        .debugRender()
        .debugCompute()
    }
    
    private var computeDebugSectionNE: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("debugCompute() - Non Nested Example")
                .font(.headline)
                .padding(.bottom, 4)
                .debugCompute()
            
            Text("Shows when views are reinitialized with a red flash, this one isn't nested, try it out and see how the whole view flashes red, not just this card..")
                .font(.caption)
                .modifier(SecondaryForegroundStyleModifier())
                .padding(.bottom, 8)
                .debugCompute()
            
            // This TextField will recreate on each character typed
            TextField("Type to see recompute", text: $text)
                .background(Color.white.opacity(0.1))
                .cornerRadius(8)
                .debugCompute()
            
                
            Text("It's not ALL bad though, these are just recomputes/initalizatons, not redraws")
                .font(.caption)
                .foregroundColor(.secondary)
                .debugCompute()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(sectionBackgroundColor)
                .shadow(color: Color.black.opacity(0.06), radius: 7, x: 0, y: 2)
        )
        .debugCompute()
    }
    
    private var computeDebugSection: some View {
        NestedComputeExample(externalText: $text)
        .debugCompute()
    }
    
    // Helper computed property for section background colors
    private var sectionBackgroundColor: Color {
        #if os(macOS)
        return colorScheme == .dark ? Color(NSColor.darkGray) : Color(NSColor.windowBackgroundColor)
        #elseif os(tvOS)
        return colorScheme == .dark ? Color.gray.opacity(0.2) : Color.black.opacity(0.1)
        #elseif os(watchOS)
        return colorScheme == .dark ? Color.gray.opacity(0.2) : Color.gray.opacity(0.05)
        #else
        return colorScheme == .dark ? Color(uiColor: .systemGray5) : Color(uiColor: .systemBackground)
        #endif
    }
}

struct NestedComputeExample: View {
    @Environment(\.colorScheme) private var colorScheme
    @State private var text = ""
    @Binding var externalText: String
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("debugCompute() - Nested Example")
                .font(.headline)
                .padding(.bottom, 4)
                .debugCompute()
            
            Text("Shows when views are reinitialized with a red flash, this one **is** nested, try it out, you'll see only this card flashes, the recompute is local to this card, unless you use a binding")
                .font(.caption)
                .modifier(SecondaryForegroundStyleModifier())
                .padding(.bottom, 8)
                .debugCompute()
            
            // This TextField will recreate on each character typed
            TextField("Type to see recompute", text: $text)
                .background(Color.white.opacity(0.1))
                .cornerRadius(8)
                .debugCompute()
            
            // This TextField will recreate on each character typed
            TextField("Type to see recompute with binding", text: $externalText)
                .background(Color.white.opacity(0.1))
                .cornerRadius(8)
                .debugCompute()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(sectionBackgroundColor)
                .shadow(color: Color.black.opacity(0.06), radius: 7, x: 0, y: 2)
        )
        .debugCompute()
    }
    
    // Helper computed property for section background colors
    private var sectionBackgroundColor: Color {
        #if os(macOS)
        return colorScheme == .dark ? Color(NSColor.darkGray) : Color(NSColor.windowBackgroundColor)
        #elseif os(tvOS)
        return colorScheme == .dark ? Color.gray.opacity(0.2) : Color.black.opacity(0.1)
        #elseif os(watchOS)
        return colorScheme == .dark ? Color.gray.opacity(0.2) : Color.gray.opacity(0.05)
        #else
        return colorScheme == .dark ? Color(uiColor: .systemGray5) : Color(uiColor: .systemBackground)
        #endif
    }
}

// MARK: - Additional Components and Compatibility Modifiers

// Helper Modifier to conditionally apply ignoresSafeArea
struct ConditionalIgnoresSafeAreaModifier: ViewModifier {
    func body(content: Content) -> some View {
        #if os(macOS)
        if #available(macOS 11.0, *) {
            content.ignoresSafeArea()
        } else {
            content // No equivalent for macOS 10.15
        }
        #elseif os(iOS)
        if #available(iOS 14.0, *) {
            content.ignoresSafeArea()
        } else {
            content // Not available before iOS 14
        }
        #elseif os(tvOS)
        if #available(tvOS 14.0, *) {
            content.ignoresSafeArea()
        } else {
            content // Not available before tvOS 14
        }
        #elseif os(watchOS)
        if #available(watchOS 7.0, *) {
            content.ignoresSafeArea()
        } else {
            content // Not available before watchOS 7
        }
        #else
        content
        #endif
    }
}

// Helper Modifier for Secondary Foreground Color Compatibility
struct SecondaryForegroundStyleModifier: ViewModifier {
    func body(content: Content) -> some View {
        #if os(watchOS) // watchOS has different availability
            if #available(watchOS 8.0, *) {
                content.foregroundColor(.secondary)
            } else {
                content // No direct equivalent on watchOS 6/7?
            }
        #elseif os(macOS)
            if #available(macOS 11.0, *) {
                content.foregroundColor(.secondary)
            } else {
                // Fallback for macOS 10.15
                content.foregroundColor(Color(NSColor.secondaryLabelColor))
            }
        #else // iOS, tvOS
            if #available(iOS 15.0, tvOS 15.0, *) {
                 content.foregroundStyle(.secondary) // Use newer API where available
            } else {
                 content.foregroundColor(.secondary) // Fallback for iOS 13/14
            }
        #endif
    }
}

// Helper Modifier for Arrow Icon Foreground Color Compatibility
struct ArrowIconForegroundStyleModifier: ViewModifier {
    func body(content: Content) -> some View {
        #if os(macOS)
        if #available(macOS 12.0, *) {
            // Use tertiaryLabelColor directly where available
            content.foregroundColor(Color(nsColor: .tertiaryLabelColor))
        } else {
            // Fallback for macOS 10.15/11
            content.foregroundColor(Color(NSColor.darkGray))
        }
        #elseif os(tvOS)
        content.foregroundColor(.gray)
        #else // iOS, watchOS
        #if os(watchOS)
        content.foregroundColor(.gray)
        #else
        if #available(iOS 15.0, *) {
            content.foregroundColor(Color(uiColor: .systemGray3))
        }
        #endif
        #endif
    }
}

struct BounceButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .animation(.smooth, value: configuration.isPressed)
            .opacity(configuration.isPressed ? 0.5 : 1.0)
    }
}

// MARK: - Previews

@available(iOS 15.0, *)
struct RenderDebugDemoView_Previews: PreviewProvider {
    static var previews: some View {
        RenderDebugDemoView()
    }
}