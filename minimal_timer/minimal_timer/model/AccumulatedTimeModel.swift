import Foundation
import SwiftUI

class AccumulatedTimeModel: ObservableObject {
    @Published private var storedAccumulatedTime: Int = 0 {
        didSet {
            saveAccumulatedTime()
        }
    }
    
    @Published private(set) var initialAccumulatedTime: Int = 0 
    @Published private(set) var accumulatedTimeSinceAppStarted : Int = 0


    var accumulatedTime: Int {
        get { storedAccumulatedTime }
        set {
            objectWillChange.send()
            storedAccumulatedTime = newValue
            accumulatedTimeSinceAppStarted = accumulatedTime - initialAccumulatedTime
        }
    }

    init() {
        loadAccumulatedTime()
        initialAccumulatedTime = storedAccumulatedTime
    }

    private func saveAccumulatedTime() {
        UserDefaults.standard.set(storedAccumulatedTime, forKey: "accumulatedTime")
    }

    private func loadAccumulatedTime() {
        if let savedTime = UserDefaults.standard.value(forKey: "accumulatedTime") as? Int {
            storedAccumulatedTime = savedTime
        }
    }

    func getAccumulatedTime() -> String {
        return formatAccumulatedTime(storedAccumulatedTime)
    }

    func getAccumulatedTimeSinceAppStarted() -> String {
        return formatAccumulatedTime(accumulatedTimeSinceAppStarted)
    }
    
    func formatAccumulatedTime(_ seconds: Int) -> String {
        if seconds < 60 {
            return String(format: "%02d", seconds) // Show only seconds
        } else if seconds < 3600 {
            let minutes = seconds / 60
            let remainingSeconds = seconds % 60
            return String(format: "%02d:%02d", minutes, remainingSeconds) // Show minutes:seconds
        } else {
            let hours = seconds / 3600
            let minutes = (seconds % 3600) / 60
            let remainingSeconds = seconds % 60
            return String(format: "%02d:%02d:%02d", hours, minutes, remainingSeconds) // Show hours:minutes:seconds
        }
    }
}