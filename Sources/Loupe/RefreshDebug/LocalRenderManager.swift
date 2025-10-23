//
//  LocalRenderManager.swift
//  RenderMeThis
//
//  Created by Aether on 12/03/2025.
//

import SwiftUI

// swift's concurrency model is allergic to implicit cross-actor accesses
// (this just means swift gets mad if you try to update something on the main thread
// from a background thread without explicitly telling it that's okay),
// and `@Published` properties live on the main actor in observableobject anyway
// (since `@Published` is used for UI updates, swift assumes it should always be on the main thread).
// making the whole class `@MainActor` prevents data race errors
// (aka, two parts of your code accidentally changing the same thing at the same time and
// causing weird unpredictable bugs) while keeping things consistent.
@MainActor
class LocalRenderManager: ObservableObject {
    var id = UUID()
    @Published var rendered: Bool = false

    func triggerRender() {
        rendered = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            // if you don't mark the class `@MainActor`, the compiler will get mad
            // bc `self` is coming from an implicitly nonisolated context
            // (fancy way of saying: this function isn't explicitly tied to any one thread,
            // so swift isn't sure if it’s safe to let it mess with the UI)
            // while trying to mutate a main actor-bound property.
            // making this a main actor task inside the closure would be a workaround,
            // but slapping `@MainActor` on the class is the cleanest fix.
            self.rendered = false
        }
    }
}
