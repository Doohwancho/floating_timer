import Foundation
import SwiftUI

class AccumulatedTimeModel: ObservableObject {
    @Published private var storedAccumulatedTime: Int = 0 {
        didSet {
            saveAccumulatedTime()
        }
    }
    
    var accumulatedTime: Int {
        get { storedAccumulatedTime }
        set {
            objectWillChange.send()
            storedAccumulatedTime = newValue
        }
    }
    
    init() {
        loadAccumulatedTime()
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
    
    func formatAccumulatedTime(_ seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        let seconds = seconds % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}
