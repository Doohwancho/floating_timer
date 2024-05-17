import SwiftUI
import Cocoa

@main
struct minimal_timerApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        let timerModel = TimerModel() // Create an instance of TimerModel
        WindowGroup {
            ContentView(timerModel: timerModel)
                .frame(width: 250, height: 100)
                .edgesIgnoringSafeArea(.all) // Optional: to make the content edge-to-edge
        }
        .windowStyle(HiddenTitleBarWindowStyle()) // Hides the title(navigation) bar
        .windowToolbarStyle(UnifiedCompactWindowToolbarStyle())
        .commands {
            // Additional commands here
        }
    }

}
