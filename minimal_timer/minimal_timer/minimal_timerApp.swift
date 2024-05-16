import SwiftUI
import Cocoa

@main
struct minimal_timerApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(width: 250, height: 100)
                .edgesIgnoringSafeArea(.all) // Optional: to make the content edge-to-edge
        }
        .windowStyle(HiddenTitleBarWindowStyle()) // Hides the title bar
    }
}
