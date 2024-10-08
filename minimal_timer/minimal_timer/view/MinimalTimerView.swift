import Foundation
import SwiftUI

struct MinimalTimerView: View {
    @ObservedObject var timerModel:TimerModel
    @ObservedObject var accumulatedTimeModel:AccumulatedTimeModel
    @Binding var inputText: String

    var body: some View {
        ZStack{
            //1. 할일 적기 (pressing 'i' as insert mode)
            Text(inputText)
                .font(.caption)
                .foregroundColor(.white)
                .padding(.bottom, 35)
                .padding(.leading, 17)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .zIndex(1) // This ensures the text is on top
            //2. timer
            Text(timerModel.formatTime(timerModel.timeRemaining))
                .font(.largeTitle)
                .frame(width: ViewDimensions.minimalTimer.size.width, height: ViewDimensions.minimalTimer.size.height)
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
            //3. accumulated time
            Text(accumulatedTimeModel.getTotalAccumulatedTime() + " / " 
                 + accumulatedTimeModel.getTodayAccumulatedTime())
                .font(.caption)
                .padding(.top, 35)
                .padding(.trailing, 10)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .bottomTrailing)
        }
    }
 }
