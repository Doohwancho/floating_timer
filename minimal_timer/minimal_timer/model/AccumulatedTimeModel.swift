import Foundation
import SwiftUI

class AccumulatedTimeModel: ObservableObject {
    /**
     A. variables
    */
    //1. 총 기록한 시간 저장 & 로드
    @Published private var totalAccumulatedTime: Int = 0 {
        didSet {
            saveTotalAccumulatedTime()
        }
    }
    var accumulatedTime: Int {
        get { totalAccumulatedTime }
        set {
            objectWillChange.send()
            totalAccumulatedTime = newValue
            updateDailyAccumulatedTime()
        }
    }
    
    //2. 일일별 기록한 시간 저장 & 로드
    @Published private var dailyAccumulatedTimes: [String: Int] = [:] {
        didSet {
            saveDailyAccumulatedTimes()
        }
    }
    //3. 오늘 추가된 시간
    @Published private(set) var todayAccumulatedTime: Int = 0
    private let calendar = Calendar.current
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    

    /**
     B. init
    */
    init() {
        loadTotalAccumulatedTime()
        loadDailyAccumulatedTimes()
        initializeTodayAccumulatedTime()
    }

    /**
     C. variable related methods
    */
    //1. 총 기록한 시간 저장 & 로드
    private func saveTotalAccumulatedTime() {
        UserDefaults.standard.set(totalAccumulatedTime, forKey: "totalAccumulatedTime")
    }

    private func loadTotalAccumulatedTime() {
        if let savedTime = UserDefaults.standard.value(forKey: "totalAccumulatedTime") as? Int {
            totalAccumulatedTime = savedTime
        }
    }
    
    //2. 일일별 기록한 시간 저장 & 로드 & 업데이트
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
        let today = dateFormatter.string(from: Date())
        todayAccumulatedTime += 1
        dailyAccumulatedTimes[today] = todayAccumulatedTime
    }
    
    //3. 오늘 추가된 시간 초기화
    private func initializeTodayAccumulatedTime() {
        let today = dateFormatter.string(from: Date())
        todayAccumulatedTime = dailyAccumulatedTimes[today] ?? 0
    }
    
    /**
     D. getters
    */
    func getTotalAccumulatedTime() -> String {
        return formatAccumulatedTime(totalAccumulatedTime)
    }

    func getTodayAccumulatedTime() -> String {
        return formatAccumulatedTime(todayAccumulatedTime)
    }
    
    func getDailyAccumulatedTimes() -> [String: Int] {
        return dailyAccumulatedTimes
    }
    
    func getFormattedDailyAccumulatedTimes() -> [String: String] {
        return dailyAccumulatedTimes.mapValues { formatAccumulatedTime($0) }
    }
    
    /**
     E. formatter
    */
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
}
