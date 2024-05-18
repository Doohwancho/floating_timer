import SwiftUI
import Cocoa

@main
struct minimal_timerApp: App {
    var timerModel = TimerModel()

    var body: some Scene {  
        WindowGroup {
            ContentView(timerModel: timerModel)
        }
    }
}

