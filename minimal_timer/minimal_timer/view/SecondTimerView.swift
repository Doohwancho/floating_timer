import Foundation
import SwiftUI

struct SecondTimerView: View {
    @ObservedObject var timerModel:TimerModel
    @ObservedObject var accumulatedTimeModel:AccumulatedTimeModel

    var body: some View {
        ZStack{
            Text(timerModel.formatTime(timerModel.timeRemaining))
                .font(.largeTitle)
                .frame(width: 100, height: 50)
                .background(Color.black)
                .foregroundColor(.white)
                .clipShape(Rectangle())
                .onTapGesture {
                    if timerModel.isRunning {
                        timerModel.stopTimer()
                    } else {
                        timerModel.startTimerDecrease()
                    }
                }
            Text(accumulatedTimeModel.getAccumulatedTime())
                .font(.caption)
                .padding(.top, 35)
                .padding(.trailing, 10)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .bottomTrailing)
        }
    }
 }
