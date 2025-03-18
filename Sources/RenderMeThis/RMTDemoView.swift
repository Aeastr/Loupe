import SwiftUI

@available(iOS 18.0, *)
@available(macOS 15, *)
struct RMTDemoView: View {
    @State private var counter = 0
    @State private var selectedTab = 0
    @State private var searchText = ""
    @State private var isShowingSheet = false
    
    private let tabs = ["Basic", "Controls", "Lists"]
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Custom segmented control
                HStack {
                    ForEach(Array(tabs.enumerated()), id: \.element) { index, tab in
                        Button(action: {
                            selectedTab = index
                        }) {
                            Text(tab)
                                .fontWeight(selectedTab == index ? .bold : .regular)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 16)
                                .background(
                                    selectedTab == index ?
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.accentColor.opacity(0.15)) :
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.clear)
                                )
                        }
                        .buttonStyle(.plain)
                        .animation(.spring(), value: selectedTab)
                    }
                }
                .padding(.horizontal)
                
                .checkForRender()
                .padding(.bottom, 8)
                
                Divider()
                
                .checkForRender()
                
                TabView(selection: $selectedTab) {
                    basicExamplesView
                        .tag(0)
                    
                    controlsExamplesView
                        .tag(1)
                    
                    listsExampleView
                        .tag(2)
                }
                .ignoresSafeArea()
                #if os(iOS)
                .tabViewStyle(.page(indexDisplayMode: .never))
                #endif
            }
            .searchable(text: $searchText, prompt: "Search")
            .navigationTitle("RenderMeThis")
            .toolbar {
                #if os(iOS)
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        isShowingSheet.toggle()
                    }) {
                        Image(systemName: "info.circle")
                    }
                }
                #else
                ToolbarItem(placement: .primaryAction) {
                    Button(action: {
                        isShowingSheet.toggle()
                    }) {
                        Image(systemName: "info.circle")
                    }
                }
                #endif
            }
            .sheet(isPresented: $isShowingSheet) {
                aboutView
            }
            
        }
    }
    
    private var basicExamplesView: some View {
        ScrollView {
            VStack(spacing: 24) {
                demoCard("Simple State Update") {
                    RenderCheck {
                        Text("This view will flash when counter changes")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        Text("Counter: \(counter)")
                            .font(.title)
                            .fontWeight(.bold)
                            .padding(.vertical, 4)
                        
                        Button(action: {
                            counter += 1
                        }) {
                            Label("Increment", systemImage: "plus.circle.fill")
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Color.accentColor.opacity(0.1))
                                .cornerRadius(12)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .checkForRender()
                
                demoCard("Subview State") {
                    Text("This subview manages its own state")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .checkForRender()
                    
                    RMTSubDemoView()
                        .checkForRender()
                }
                .checkForRender()
                
                
                demoCard("Slider Example") {
                    
                    RenderCheck {
                        Text("Slider position: \(Int(sliderValue * 100))")
                            .font(.subheadline)
                        
                        Slider(value: $sliderValue)
                            .padding(.vertical, 8)
                            .tint(.accentColor)
                    }
                }
                .checkForRender()
                
                
                RMTSubDemoSliderView()
                .checkForRender()
                
                demoCard("Parent-Child Relationship") {
                    RenderCheck {
                        Text("Parent view with counter: \(counter)")
                            .font(.subheadline)
                        
                        Divider()
                            .padding(.vertical, 8)
                        
                        RenderCheck {
                            Text("Child view (renders with parent)")
                                .font(.subheadline)
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                    }
                }
                .checkForRender()
            }
            .padding()
        }
    }
    
        @State var sliderValue: Double = 0.5
    
    private var controlsExamplesView: some View {
        ScrollView {
            VStack(spacing: 24) {
                demoCard("Toggle Example") {
                    @State var toggleState = false
                    
                    RenderCheck {
                        Text("Toggle updates trigger renders")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        Toggle("Toggle State: \(toggleState ? "On" : "Off")", isOn: $toggleState)
                            .padding(.vertical, 8)
                    }
                }
                
                demoCard("Text Input") {
                    @State var textInput = ""
                    
                    RenderCheck {
                        Text("Each keystroke causes a render")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        TextField("Type something...", text: $textInput)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                    }
                }
                
                demoCard("Date Picker") {
                    @State var selectedDate = Date()
                    
                    RenderCheck {
                        Text("Date updates cause renders")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        DatePicker("Select date", selection: $selectedDate, displayedComponents: .date)
                            .datePickerStyle(.compact)
                            .padding(.vertical, 8)
                    }
                }
            }
            .padding()
        }
    }
    
    private var listsExampleView: some View {
        ScrollView {
            VStack(spacing: 24) {
                demoCard("List Selection") {
                    @State var selectedItem: Int? = nil
                    let items = Array(1...5)
                    
                    RenderCheck {
                        Text("List selection causes renders")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        ForEach(items, id: \.self) { item in
                            Button(action: {
                                selectedItem = item
                            }) {
                                HStack {
                                    Text("Item \(item)")
                                    Spacer()
                                    if selectedItem == item {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.accentColor)
                                    }
                                }
                                .padding(.vertical, 8)
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                            
                            if item != items.last {
                                Divider()
                            }
                        }
                    }
                }
                
                demoCard("ForEach with ID") {
                    @State var items = ["Apple", "Banana", "Cherry"]
                    @State var newItem = ""
                    
                    RenderCheck {
                        Text("Adding items causes renders")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        HStack {
                            TextField("New item", text: $newItem)
                                .padding(8)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(8)
                            
                            Button(action: {
                                if !newItem.isEmpty {
                                    items.append(newItem)
                                    newItem = ""
                                }
                            }) {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(.accentColor)
                            }
                        }
                        
                        ForEach(items, id: \.self) { item in
                            HStack {
                                Text(item)
                                Spacer()
                                Button(action: {
                                    items.removeAll { $0 == item }
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.red.opacity(0.7))
                                }
                            }
                            .padding(.vertical, 8)
                            
                            if item != items.last {
                                Divider()
                            }
                        }
                    }
                }
            }
            .padding()
        }
    }
    
    private var aboutView: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text("About RenderMeThis")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button(action: {
                    isShowingSheet = false
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title3)
                        .foregroundColor(.gray)
                }
            }
            
            Text("RenderMeThis is a SwiftUI debugging tool that visualizes exactly when views re-render. Each re-render is highlighted with a subtle flash effect.")
                .foregroundStyle(.secondary)
            
            VStack(alignment: .leading, spacing: 8) {
                Label("Identify unnecessary renders", systemImage: "eye")
                Label("Optimize performance", systemImage: "bolt")
                Label("Debug state updates", systemImage: "wrench.and.screwdriver")
                Label("Learn SwiftUI's rendering behavior", systemImage: "graduationcap")
            }
            .padding(.vertical)
            
            Spacer()
        }
        .padding()
        .presentationDetents([.medium])
    }
    
    private func demoCard<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            
            Text(title)
                .font(.headline)
                .padding(.bottom, 4)
            
            .checkForRender()
            
            content()
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray.opacity(0.1), lineWidth: 1)
        )
    }
}

@available(iOS 18.0, *)
@available(macOS 15, *)
struct RMTSubDemoView: View {
    @State private var counter = 0
    @State private var isToggled = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            RenderCheck {
                Text("Subview counter: \(counter)")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.vertical, 4)
                
                Toggle("Toggle Test", isOn: $isToggled)
                    .padding(.vertical, 4)
                
                Button(action: {
                    counter += 1
                }) {
                    Label("Increment Subview", systemImage: "plus.circle.fill")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.accentColor.opacity(0.1))
                        .cornerRadius(12)
                }
                .buttonStyle(.plain)
            }
        }
    }
}


@available(iOS 18.0, *)
@available(macOS 15, *)
struct RMTSubDemoSliderView: View {
    @State private var counter = 0.0
    @State private var isToggled = false
    
    
    var body: some View {
        
        demoCard("Slider Subview Example") {
            
            VStack(alignment: .leading, spacing: 16) {
                RenderCheck {
                    Text("Slider position: \(Int(counter * 100))")
                        .font(.subheadline)
                    
                    Slider(value: $counter)
                        .padding(.vertical, 8)
                        .tint(.accentColor)
                }
            }
        }
    }
    
    
    
    private func demoCard<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            
            Text(title)
                .font(.headline)
                .padding(.bottom, 4)
            
            .checkForRender()
            
            content()
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray.opacity(0.1), lineWidth: 1)
        )
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
