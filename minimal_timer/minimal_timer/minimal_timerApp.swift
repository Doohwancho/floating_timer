import SwiftUI
import Cocoa

@main
struct minimal_timerApp: App {
    var accumulatedTimeModel = AccumulatedTimeModel()

    var body: some Scene {  
        let timerModel = TimerModel(accumulatedTimeModel: accumulatedTimeModel)
        
        WindowGroup {
            ContentView(timerModel: timerModel, accumulatedTimeModel: accumulatedTimeModel)
        }
    }
}

