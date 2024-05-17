import Foundation

class TimerModel: ObservableObject { 
    @Published var timeRemaining: Int = 300
    @Published var isRunning = false
    var timer: Timer?

    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            if let self = self, self.timeRemaining > 0 {
                self.timeRemaining -= 1
            } else {
                self?.stopTimer()
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

    func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%02d:%02d", minutes, remainingSeconds)
    }
}
