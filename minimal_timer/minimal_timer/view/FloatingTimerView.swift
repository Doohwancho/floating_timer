import Foundation
import SwiftUI

struct FloatingTimerView: View {
    @ObservedObject var timerModel: TimerModel

    var body: some View {
        Text(formatTime(timerModel.timeRemaining))
            .font(.largeTitle)
            .frame(width: 100, height: 50)
            .background(Color.black)
            .foregroundColor(.white)
            .clipShape(Rectangle())
            // .clipShape(RoundedRectangle(cornerRadius: 20)) //TODO: rounded rectangle's edge is white and idk how to remove it
            .onTapGesture {
                if timerModel.isRunning {
                    timerModel.stopTimer()
                } else {
                    timerModel.startTimer()
                }
            }
    }
    private func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%02d:%02d", minutes, remainingSeconds)
    }
}
