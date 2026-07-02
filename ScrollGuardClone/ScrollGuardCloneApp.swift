import SwiftUI

@main
struct ScrollGuardCloneApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onOpenURL { _ in
                    // scrollguard:// — opened by the Shortcuts automation.
                    // Launching/foregrounding the app is all Phase 0 needs;
                    // deep-link routing can come later if we ever need it.
                }
        }
    }
}
