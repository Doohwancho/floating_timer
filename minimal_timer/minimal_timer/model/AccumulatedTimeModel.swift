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
    @Published private var dailyAccumulatedTimes: [String: Int] = [:] {
        didSet {
            saveDailyAccumulatedTimes()
        }
    }

    var accumulatedTime: Int {
        get { storedAccumulatedTime }
        set {
            objectWillChange.send()
            storedAccumulatedTime = newValue
            accumulatedTimeSinceAppStarted = accumulatedTime - initialAccumulatedTime
            updateDailyAccumulatedTime()
        }
    }

    init() {
        loadAccumulatedTime()
        loadDailyAccumulatedTimes()
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
    
    private func saveDailyAccumulatedTimes() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(dailyAccumulatedTimes) {
            UserDefaults.standard.set(encoded, forKey: "dailyAccumulatedTimes")
        }
    }

    private func loadDailyAccumulatedTimes() {
        if let savedDailyTimes = UserDefaults.standard.data(forKey: "dailyAccumulatedTimes") {
            let decoder = JSONDecoder()
            if let loadedDailyTimes = try? decoder.decode([String: Int].self, from: savedDailyTimes) {
                dailyAccumulatedTimes = loadedDailyTimes
            }
        }
    }
    
    private func updateDailyAccumulatedTime() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let today = dateFormatter.string(from: Date())
        
        if let existingTime = dailyAccumulatedTimes[today] {
            dailyAccumulatedTimes[today] = existingTime + 1
        } else {
            dailyAccumulatedTimes[today] = 1
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
//            let remainingSeconds = seconds % 60
            return String(format: "%02d:%02d", hours, minutes) // Show hours:minutes
        }
    }
    
    func getDailyAccumulatedTimes() -> [String: Int] {
        return dailyAccumulatedTimes
    }
    
    func getFormattedDailyAccumulatedTimes() -> [String: String] {
        return dailyAccumulatedTimes.mapValues { formatAccumulatedTime($0) }
    }
}
