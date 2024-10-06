import Foundation
import SwiftUI

class AccumulatedTimeModel: ObservableObject {
    /**
     A. variables
    */
    //1. 총 기록한 시간 저장 & 로드
    @Published private var totalAccumulatedTime: Int = 0 {
        didSet {
            saveTotalAccumulatedTime() //saved everytime it changes (didset {})
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
            saveDailyAccumulatedTimes() //saved everytime it changes (didset {})
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
    
    //4. app이 running 하는 상태에서 날짜가 바뀐 경우, 이전 날짜의 누적시간을 저장하고 현재 todayAccumulatedTime을 0으로 reset하기 위한 변수
    private var lastActiveDate: Date?
    
    //app이 active한지 체크하는 observer
    @Published var scenePhase: ScenePhase = .inactive {
        didSet {
            if scenePhase == .active {
                checkForDateChange()
            }
        }
    }
    
    //5. max & current streaks
    @Published private var maxConsecutiveDays: Int = 0 {
        didSet {
            saveMaxConsecutiveDays() //saved everytime it changes (didset {})
        }
    }
    @Published private(set) var currentStreak: Int = 0


    /**
     B. init
    */
    init() {
        loadTotalAccumulatedTime()
        loadDailyAccumulatedTimes()
        initializeTodayAccumulatedTime()
        loadMaxConsecutiveDays()
        calculateCurrentStreak()
        lastActiveDate = loadLastActiveDate()
    }

    deinit {
        saveLastActiveDate()
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
        checkForDateChange() // Check if the date has changed before updating
                
        let today = dateFormatter.string(from: Date())
        todayAccumulatedTime += 1
        dailyAccumulatedTimes[today] = todayAccumulatedTime
        
        saveDailyAccumulatedTimes() // Save after updating //TODO - 매 초마다 save i/o 하는건 inefficient. needs to be fixed
    }
    
    
    
    //3. 오늘 추가된 시간 관련 메서드
    private func initializeTodayAccumulatedTime() {
        let today = dateFormatter.string(from: Date())
        todayAccumulatedTime = dailyAccumulatedTimes[today] ?? 0
    }
    
    private func saveAccumulatedTime(for date: Date) {
        let dateString = dateFormatter.string(from: date)
        dailyAccumulatedTimes[dateString] = todayAccumulatedTime
        saveDailyAccumulatedTimes()
    }
    
    private func resetTodayAccumulatedTime() {
        todayAccumulatedTime = 0
        initializeTodayAccumulatedTime()
        objectWillChange.send()
    }
    
    //4. Save last active date changed
    func checkForDateChange() {
        let currentDate = Date()
        
        if let lastDate = lastActiveDate {
            if !calendar.isDate(lastDate, inSameDayAs: currentDate) {
                // Date has changed, save accumulated time for the last active date
                saveAccumulatedTime(for: lastDate)
                resetTodayAccumulatedTime()
            }
        }
        
        lastActiveDate = currentDate
        saveLastActiveDate()
    }
    
    private func saveLastActiveDate() {
        if let lastDate = lastActiveDate {
            UserDefaults.standard.set(lastDate, forKey: "lastActiveDate")
        }
    }
    
    // Load last active date
    private func loadLastActiveDate() -> Date? {
        return UserDefaults.standard.object(forKey: "lastActiveDate") as? Date
    }
    
    //5. max & current streaks 관련 메서드
    private func saveMaxConsecutiveDays() {
        UserDefaults.standard.set(maxConsecutiveDays, forKey: "maxConsecutiveDays")
    }

    private func loadMaxConsecutiveDays() {
        maxConsecutiveDays = UserDefaults.standard.integer(forKey: "maxConsecutiveDays")
    }
    
    private func calculateCurrentStreak() {
        let sortedDates = dailyAccumulatedTimes.keys.sorted(by: >)
        var streak = 0
        var currentDate = calendar.startOfDay(for: Date())

        for dateString in sortedDates {
            if let date = dateFormatter.date(from: dateString),
               let dayDifference = calendar.dateComponents([.day], from: calendar.startOfDay(for: date), to: currentDate).day {
                if dayDifference <= streak {
                    streak += 1
                    currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate)!
                } else {
                    break
                }
            }
        }

        currentStreak = streak
        if currentStreak > maxConsecutiveDays {
            maxConsecutiveDays = currentStreak
        }
    }
    
    func updateStreaks() {
        calculateCurrentStreak()
    }
    
    // Add this method to manually trigger streak calculation
    func recalculateStreaks() {
        calculateCurrentStreak()
        objectWillChange.send()
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
    
    func getMaxConsecutiveDays() -> Int {
        return maxConsecutiveDays
    }

    func getCurrentStreak() -> Int {
        return currentStreak
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
