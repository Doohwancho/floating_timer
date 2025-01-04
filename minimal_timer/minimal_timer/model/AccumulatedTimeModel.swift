import Foundation
import SwiftUI

class AccumulatedTimeModel: ObservableObject {
    /**
     A. variables
    */
    //0. timezone = asia/seoul
    private let timeZone = TimeZone(identifier: "Asia/Seoul")!
    
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
    
    private let calendar: Calendar = {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(identifier: "Asia/Seoul")!
        return calendar
    }()
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
//        formatter.timeZone = TimeZone(identifier: "Asia/Seoul") //쓰고 안쓰고 차이가 없었다. 아마 default_timezone 설정해서 그런듯?
        return formatter
    }()
    
    private let dateFormatter_detailed: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
//        formatter.timeZone = TimeZone(identifier: "Asia/Seoul") //쓰고 안쓰고 차이가 없었다. 아마 default_timezone 설정해서 그런듯?
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
        lastActiveDate = loadLastActiveDate() ?? getCurrentDate()
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
        //방법1) encode 하고 저장하기
        //이렇게 데이터가 저장됨
//        "dailyAccumulatedTimes" => {length = 178, bytes = 0x7b223230 32342d31 302d3037 223a3732 ... 223a3133 3732327d }
        
        //Q. how to see data?
        //plutil -p /Users/cho-cho/Library/Containers/com.cho.minimal-timer/Data/Library/Preferences/com.cho.minimal-timer.plist
        
        //Q. why encode when save?
        //1. Compatibility: UserDefaults is designed to store property list types (String, Number, Date, Data, Array, or Dictionary). A complex dictionary like [String: Int] is not directly supported, so it needs to be converted to Data.
        //2. Efficiency: Encoding to Data can be more efficient for storage and retrieval, especially for larger datasets.

//        let encoder = JSONEncoder()
//        if let encoded = try? encoder.encode(dailyAccumulatedTimes) {
//            UserDefaults.standard.set(encoded, forKey: "dailyAccumulatedTimes_ver1")
//        }
//        
        
        //방법2) encode 안하고 그냥 저장하기
        //이렇게 데이터가 저장됨
//        "dailyAccumulatedTimes" => {
//            "2024-10-07" = 72;
//            "2024-10-08" = 13722;
//            // ... other dates
//        }
        //장점) debugging 하기 용이하다. + 나중에 사고나서 데이터 백업해야 할 때에도 정확히 몇일에 몇초 저장했는지 눈으로 볼 수 있어야 용이하다.
        UserDefaults.standard.set(dailyAccumulatedTimes, forKey: "dailyAccumulatedTimes_ver2_raw_format")
    }

    private func loadDailyAccumulatedTimes() {
        // 잘못된 데이터 삭제
//        removeData(for: "2024-10-10")

        // 10월 8일 데이터 수동 입력 (예: 3600초 = 1시간)
//        setData(for: "2024-10-01", seconds: 484)
//        setData(for: "2024-10-02", seconds: 5967)
//        setData(for: "2024-10-03", seconds: 7748)
//        setData(for: "2024-10-04", seconds: 5462)
//        setData(for: "2024-10-05", seconds: 1338)
//        setData(for: "2024-10-06", seconds: 13722)
//        setData(for: "2024-10-07", seconds: 7200)
//        setData(for: "2024-10-08", seconds: 8000)
//        setData(for: "2024-10-09", seconds: 4089)
//        setData(for: "2024-10-10", seconds: 3600)
//        setData(for: "2024-10-11", seconds: 0)
//        setData(for: "2024-10-12", seconds: 7200)
//        setData(for: "2024-10-13", seconds: 900)
//        setData(for: "2024-10-14", seconds: 7200)
        
        
//        //방법1) encode 하고 저장한걸 로드하기
//        if let savedDailyTimes = UserDefaults.standard.data(forKey: "dailyAccumulatedTimes") {
//            let decoder = JSONDecoder()
//            if let loadedDailyTimes = try? decoder.decode([String: Int].self, from: savedDailyTimes) {
//                UserDefaults.standard.set(loadedDailyTimes, forKey: "dailyAccumulatedTimes_ver1")
//                dailyAccumulatedTimes = loadedDailyTimes
//            }
//        }
        
        //방법2) encode 안한걸 로드하기
        //장점) debugging 하기 용이하다. + 나중에 사고나서 데이터 백업해야 할 때에도 정확히 몇일에 몇초 저장했는지 눈으로 볼 수 있어야 용이하다.
        if let loadedTimes = UserDefaults.standard.dictionary(forKey: "dailyAccumulatedTimes_ver2_raw_format") as? [String: Int] {
            dailyAccumulatedTimes = loadedTimes
        }
    }
    
    /**
        Debug purpose code
        가끔 dailyAccumulatedTime에 값이 추가로 잘못 저장되서 지워야 할 때, 저장되어야 했을 값이 저장이 안됬을 때 수동으로 값을 입력해주는 코드
     */
    // 특정 날짜의 데이터를 삭제하는 메소드
    func removeData(for date: String) {
        dailyAccumulatedTimes.removeValue(forKey: date)
        saveDailyAccumulatedTimes()
    }

    // 특정 날짜에 데이터를 수동으로 입력하는 메소드
    func setData(for date: String, seconds: Int) {
        dailyAccumulatedTimes[date] = seconds
        saveDailyAccumulatedTimes()
    }
    
    private func updateDailyAccumulatedTime() {
        checkForDateChange() // Check if the date has changed before updating
        
        /**
         실험: Date()랑 Date()에 GMT 시간 더한것 타임존에 맞는지 비교하기 + dateFormatter에 넣으면 시간이 바뀐다?
        
        //결론: 그냥 Date() 쓰면 타임존 안맞는데, dateFormatter() 씌우면 맞는 듯?
        //근데 dateFormatter_detailed.string(from: Date())) 은 타입이 string이니까,
        //현재 시각이 필요한데 Date 타입이 필요하면 getCurrentTime() 쓰자.
         
        //YYYY-MM-DD 쓸꺼면 dateFormmater.string(from: Date())가 맞다.
        //YYYY-MM-DD HH:mm:ss 쓸꺼면 getCurrentTime()가 맞다.
        
        print("Date()")
        print(Date()) //2024-10-09 10:10:01 +0000  right date, wrong time
        print("Date() not detailed")
        print(dateFormatter.string(from: Date())) //2024-10-09 right date?
        print("Date() detailed")
        print(dateFormatter_detailed.string(from: Date())) //2024-10-09T19:10:01   right date, right time
        print("getCurrentDate()")
        print(getCurrentDate()) //2024-10-09 18:42:40 +0000 right date, time
        print("getCurrentDate() not detailed")
        print(dateFormatter.string(from: getCurrentDate())) //wrong date, time
        print("getCurrentDate() detailed")
        print(dateFormatter_detailed.string(from: getCurrentDate())) //wrong date and time
         */
        
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
        let today = dateFormatter.string(from: Date())
        dailyAccumulatedTimes[today] = 0
        objectWillChange.send() //SwiftUI한테 object가 바뀔거야 알려줘서 @ObservedObject or @StateObject 달려 있는 변수 re-render한다.
    }
    
    //4. Save last active date changed
    func checkForDateChange() {
        let currentDate = getCurrentDate()
        
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
        UserDefaults.standard.set(lastActiveDate, forKey: "lastActiveDate")
    }
    
    // Load last active date
    private func loadLastActiveDate() -> Date? {
        if let date = UserDefaults.standard.object(forKey: "lastActiveDate") as? Date {
            // Ensure the loaded date is interpreted in the correct timezone
            let components = calendar.dateComponents(in: timeZone, from: date)
            return calendar.date(from: components)
        }
        return nil
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
        var currentDate = calendar.startOfDay(for: Date()) //calendar은 Date의 타임존이 맞는 듯 하다. 

        for dateString in sortedDates {
            if let date = dateFormatter.date(from: dateString),
               calendar.isDate(date, inSameDayAs: currentDate) {
                if dailyAccumulatedTimes[dateString]! > 0 {
                    streak += 1
                    currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate)!
                } else {
                    break
                }
            } else {
                break
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
    // Helper method to get current date in Seoul timezone
    func getCurrentDate() -> Date {
        return Date().addingTimeInterval(TimeInterval(timeZone.secondsFromGMT()))
    }
    
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
