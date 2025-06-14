import Foundation
import SwiftUI

class TimerModel: ObservableObject {
    
    struct TimeComponents {
        let hours: Int
        let minutes: Int
        let seconds: Int
        let totalSeconds: Double  // Keep original for decimal precision if needed
    }
    
    @ObservedObject var accumulatedTimeModel: AccumulatedTimeModel

    // Public initializer
    init(accumulatedTimeModel: AccumulatedTimeModel) {
        self.accumulatedTimeModel = accumulatedTimeModel
    }

    @Published var isRunning = false
    private var _timeRemaining: Int = 300
    var timeRemaining: Int {
        get { _timeRemaining }
        set {
            objectWillChange.send()
            _timeRemaining = newValue
        }
    }
    private var _timeIndexInMinutes: Int = 5
    var timeIndexInMinutes: Int {
        get { _timeIndexInMinutes }
        set {
            objectWillChange.send()
            _timeIndexInMinutes = newValue
        }
    }
    var timer: Timer?

    // MARK: - 주석 처리된 기존 게임 모드 코드
    /*
    // Gamification properties
    @Published var isGameMode = false
    @Published var showResult = false
    @Published var consecutiveStreaks = 0
    private var lastStreakResetDate: Date?
    @Published var initialTimeRemaining: Int = 0
    @Published var finalTimeRemaining: Int = 0
    */

    // MARK: - 변경/추가된 타이머 제어 코드
    
    /// 타이머를 시작하거나 재개합니다.
    func startTimer() {
        // 이미 타이머가 실행 중이면 중복 실행 방지
        guard !isRunning else { return }
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            // 시간이 0에 도달했을 때 알림음 한 번만 울림
            if self.timeRemaining == 1 {
                self.playAlarmSound()
            }
            
            self.timeRemaining -= 1
            self.accumulatedTimeModel.accumulatedTime += 1 // 누적 시간은 계속 증가
        }
        isRunning = true
    }
    
    /// 스페이스바를 통해 타이머를 시작/일시정지/재개하는 통합 함수
    func toggleTimer() {
        if isRunning {
            pauseTimer()
        } else {
            startTimer()
        }
    }

    func startTimerIncrease() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            if let self = self {
                self.timeRemaining += 1
            }
        }
        isRunning = true
    }

    func pauseTimer() {
        timer?.invalidate()
        timer = nil
        isRunning = false
    }

    func stopTimer() {
        timer?.invalidate()
        timer = nil
        isRunning = false
        // 타이머를 완전히 멈추고 싶을 때 기본 시간으로 리셋 (선택적)
        // timeRemaining = _timeIndexInMinutes * 60
    }

    func setTimer(with minutes: Int) {
        timeRemaining = minutes * 60
        updateSelectedIndex(with: minutes)
    }

    func getTimeRemaining() -> Int {
        return timeRemaining
    }

    func updateSelectedIndex(with minutes: Int) {
        timeIndexInMinutes = min(minutes, 120) // Cap the selectedIndex at 120
    }

    func getTimeIndexInMinutes() -> Int {
        return timeIndexInMinutes
    }

    private func secondsToTimeComponents(_ seconds: Double) -> TimeComponents {
        let totalSeconds = Int(seconds)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let remainingSeconds = totalSeconds % 60
        
        return TimeComponents(
            hours: hours,
            minutes: minutes,
            seconds: remainingSeconds,
            totalSeconds: seconds
        )
    }
    
    // MARK: - 주석 처리된 기존 게임 모드 코드
    /*
    func formatTimeDifference(_ seconds: Double) -> String {
        let time = secondsToTimeComponents(seconds)
        
        if time.hours > 0 {
            return time.minutes > 0 ? "\(time.hours)h \(time.minutes)m off" : "\(time.hours)h off"
        } else if time.minutes > 0 {
            return time.seconds > 0 ? "\(time.minutes)m \(time.seconds)s off" : "\(time.minutes)m off"
        } else {
            return String(format: "%.1fs off", time.totalSeconds)
        }
    }
    */
    
    // MARK: - 변경된 시간 포맷 함수
    /// 시간을 "분:초" 형식으로 변환합니다. 시간이 0 미만이면 "+분:초"로 표시됩니다.
    func formatTime(_ seconds: Int) -> String {
        let isOvertime = seconds < 0
        let absoluteSeconds = abs(seconds)
        let minutes = absoluteSeconds / 60
        let remainingSeconds = absoluteSeconds % 60
        
        if isOvertime {
            // 초과 시간을 + 기호와 함께 표시
            return String(format: "+%02d:%02d", minutes, remainingSeconds)
        } else {
            return String(format: "%02d:%02d", minutes, remainingSeconds)
        }
    }
    
    private func playAlarmSound() {
        NSSound.beep()
    }

    // MARK: - 주석 처리된 기존 게임 모드 코드
    /*****************************
    * gamification parts
    ***/
    /*
    func startGameMode() {
        initialTimeRemaining = timeRemaining
        isGameMode = true
        showResult = false
        startTimer() // startTimerDecrease()에서 이름 변경
        checkAndResetStreaks()
    }
    
    func stopGameMode() {
        finalTimeRemaining = timeRemaining  // Store the final time
        stopTimer()
        isGameMode = false
        showResult = true
        calculateAccuracy()
    }
    
    private func calculateAccuracy() {
        // Calculate what percentage of target time was achieved
        let percentage = (Double(initialTimeRemaining - finalTimeRemaining) / Double(initialTimeRemaining)) * 100
        
        // Increase streak only if within 80% ~ 120% range
        if percentage >= 80 && percentage <= 120 {
            consecutiveStreaks += 1
        } else {
            consecutiveStreaks = 0 //TODO - reset to zero is too harsh. change to accumulation and
        }
    }
    
    func getAccuracyPercentage() -> Double {
        // If initial time was 60s and 56s remains, that means 4s elapsed
        let elapsedTime = initialTimeRemaining - finalTimeRemaining
        // Calculate what percentage of the target time was achieved
        return (Double(elapsedTime) / Double(initialTimeRemaining)) * 100
    }

    func getTimeDifference() -> Double {
        // Return absolute difference between actual and target time
        return abs(Double(initialTimeRemaining - finalTimeRemaining))
    }
    
    private func checkAndResetStreaks() {
        let calendar = Calendar.current
        let now = Date()
        
        // Reset streak at 6 AM
        var components = calendar.dateComponents([.year, .month, .day], from: now)
        components.hour = 6
        components.minute = 0
        components.second = 0
        
        guard let resetTime = calendar.date(from: components) else { return }
        
        if let lastReset = lastStreakResetDate {
            if now >= resetTime && lastReset < resetTime {
                consecutiveStreaks = 0
            }
        }
        
        lastStreakResetDate = now
    }
    */
}
