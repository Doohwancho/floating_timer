import Foundation
import SwiftUI

struct SecondTimerView: View {
    @ObservedObject var timerModel = TimerModel()

    var body: some View {
        Text(timerModel.formatTime(timerModel.timeRemaining))
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
}
