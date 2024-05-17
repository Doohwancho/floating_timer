import Foundation
import SwiftUI

struct FloatingTimerView: View {
    @ObservedObject var timerModel: TimerModel

    var body: some View {
        Text(String(timerModel.timeRemaining))
            .font(.largeTitle)
            .frame(width: 100, height: 100)
            .background(Color.black)
            .foregroundColor(.white)
            .clipShape(Circle())
            .onTapGesture {
                if timerModel.isRunning {
                    timerModel.stopTimer()
                } else {
                    timerModel.startTimer()
                }
            }
    }
}
