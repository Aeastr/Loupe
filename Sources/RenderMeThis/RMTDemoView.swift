//
//  RMTDemoView.swift
//  RenderMeThis
//
//  Created by Aether on 12/03/2025.
//

import SwiftUI

@available(iOS 18.0, *)
@available(macOS 15, *)
struct RMTDemoView: View {
    @State private var counter = 0
    
    var body: some View {
        NavigationStack {
            ScrollView {
                
                VStack(alignment: .leading, spacing: 12) {
                    // Entire content you're checking is wrapped in RenderCheck.
                    RenderCheck {
                        Text("Main Content")
                            .font(.headline)
                        
                        Text("Counter: \(counter)")
                            .font(.subheadline)
                        
                        Button(action: {
                            counter += 1
                        }) {
                            Label("Increment", systemImage: "plus.circle.fill")
                        }
                        
                        Divider()
                        
                        Text("Separate Section")
                            .font(.headline)
                        
                        RMTSubDemoView() // iOS 18 version of the subview.
                    }
                }
            }
            .padding()
            .navigationTitle("RenderMeThis")
        }
    }
}

@available(iOS 18.0, *)
@available(macOS 15, *)
struct RMTSubDemoView: View {
    @State private var counter = 0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            RenderCheck {
                
                Text("Counter: \(counter)")
                    .font(.subheadline)
                
                Button(action: {
                    counter += 1
                }) {
                    Label("Increment", systemImage: "plus.circle.fill")
                }
            }
        }
    }
}


struct RMTDemoView_Pre18: View {
    @State private var counter = 0

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {

                VStack(spacing: 12) {
                    Text("Main Content")
                        .font(.headline)
                        .checkForRender()

                    Text("Counter: \(counter)")
                        .font(.subheadline)
                        .checkForRender()

                    Button(action: {
                        counter += 1
                    }) {
                        HStack {
                            Text("Increment")
                            if #available(iOS 13.0, macOS 11.0, *) {
                                Image(systemName: "plus.circle.fill")
                            }
                        }
                    }

                    .checkForRender()

                    Divider()
                        .checkForRender()

                    Text("Separate Section")
                        .font(.headline)
                        .checkForRender()

                    RMTSubDemoView_Pre18()
                        .checkForRender()
                }
            }
            .padding()
        }
    }
}

struct RMTSubDemoView_Pre18: View {
    @State private var counter = 0

    var body: some View {
        VStack(spacing: 12) {
            Text("Counter: \(counter)")
                .font(.subheadline)
                .checkForRender()

            Button(action: {
                counter += 1
            }) {
                HStack{
                    Text("Increment")
                    if #available(iOS 13.0, macOS 11.0, *) {
                        Image(systemName: "plus.circle.fill")
                    }
                }
            }
            .checkForRender()
        }
    }
}

@available(iOS 18.0, *)
@available(macOS 15, *)
#Preview("Wrapper") {
    RMTDemoView()
}

#Preview("Modifier") {
    RMTDemoView_Pre18()
}
