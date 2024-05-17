import SwiftUI
import Foundation

struct MinimalTimerView: View {
    @Binding var timeRemaining: Int

    var body: some View {
        Text(formatTime(timeRemaining))
            .font(.system(size: 14, weight: .bold))
            .foregroundColor(.white)
            .frame(width: 50, height: 30)
            .background(Color.black)
            .cornerRadius(5)
    }

    private func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%02d:%02d", minutes, remainingSeconds)
    }
}
