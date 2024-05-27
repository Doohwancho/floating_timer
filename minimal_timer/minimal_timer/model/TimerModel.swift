import Foundation

class TimerModel: ObservableObject { 
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

    func startTimerDecrease() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            if let self = self, self.timeRemaining > 0 {
                self.timeRemaining -= 1
            } else {
                self?.stopTimer()
            }
        }
        isRunning = true
    }
    
    func startTimerIncrease() {
        // timer?.invalidate()
        // timeRemaining = 0

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

    func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%02d:%02d", minutes, remainingSeconds)
    }
}
