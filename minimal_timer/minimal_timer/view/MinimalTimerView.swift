import Foundation
import SwiftUI

struct MinimalTimerView: View {
    @ObservedObject var timerModel:TimerModel
    @ObservedObject var accumulatedTimeModel:AccumulatedTimeModel
    @Binding var inputText: String
    
    private var currentDimensions: ViewDimensions {
        timerModel.showResult ? .minimalTimerWithResult : .minimalTimer
    }

    var body: some View {
        ZStack{
            //1. 할일 적기 (pressing 'i' as insert mode)
            if !timerModel.isGameMode {
                Text(inputText)
                    .font(.caption)
                    .foregroundColor(.white)
                //                        .padding(.bottom, 35)
                    .padding(.leading, 17)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .zIndex(1)
            }
            //2. timer
            if timerModel.isGameMode {
                Text("?")
                    .font(.largeTitle)
                    .frame(width: ViewDimensions.minimalTimer.size.width, height: ViewDimensions.minimalTimer.size.height)
                    .foregroundColor(.white)
            } else {
                Text(timerModel.formatTime(timerModel.timeRemaining))
                    .font(.largeTitle)
                    .frame(width: ViewDimensions.minimalTimer.size.width, height: ViewDimensions.minimalTimer.size.height)
                    .foregroundColor(.white)
                    .onTapGesture {
                        if timerModel.isRunning {
                            timerModel.stopTimer()
                        } else {
                            timerModel.startTimerDecrease()
                        }
                    }
                
                //3. accumulated time (only show when not in result view)
                if !timerModel.isGameMode {
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
        .background(Color.black)
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }
 }
