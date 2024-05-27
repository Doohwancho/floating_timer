import SwiftUI
import Foundation


struct FirstTimerView: View {
    @ObservedObject var timerModel = TimerModel()

    var body: some View {
        VStack {
            HStack {
                ZStack {
                    HStack(spacing: 1) {
                        ForEach(0..<121) { index in
                            Rectangle()
                                .fill(timerModel.getTimeIndexInMinutes() == index ? Color.black : Color(white: 0.95))
                                .frame(width: 1, height: 20)
                                .onTapGesture {
                                    timerModel.setTimer(with: index) //TODO: vertical bar 사이 공간 클릭하면 인식 못하는 문제 해결 필요 
                                }
                        }
                    }
                    .frame(height:30)
                }
                .padding(.top, 0) 
            }

            HStack {
                Button(action: {
                    timerModel.setTimer(with: 5)
                    // timerModel.startTimerDecrease()
                }) {
                    Text("5m")
                }
                .buttonStyle(PlainButtonStyle()) // Makes the button borderless and background colorless
                .padding(.leading)
                
                Button(action: {
                    timerModel.setTimer(with: 10)
                }) {
                    Text("10m")
                }
                .buttonStyle(PlainButtonStyle()) // Makes the button borderless and background colorless
                .padding(.leading)
                
                Button(action: {
                    timerModel.setTimer(with: 25)
                }) {
                    Text("25m")
                }
                .buttonStyle(PlainButtonStyle()) // Makes the button borderless and background colorless
                .padding(.leading)
                
                Spacer()
                
                Text("...")
                .padding(.trailing)
            }
            .padding(.bottom, 1)

            HStack {
                Button(action: {
                    if timerModel.isRunning {
                        timerModel.pauseTimer()
                    } else {
                        timerModel.startTimerDecrease()
                    }
                }) {
                    Text(timerModel.isRunning ? "pause" : "start")
                    .padding(.trailing)
                }
                .buttonStyle(PlainButtonStyle()) // Makes the button borderless and background colorless
                .padding(0)
                .padding(.leading)
                
                Spacer()
                
                Text(timerModel.formatTime(timerModel.getTimeRemaining()))
                    .font(.system(size: 32)) 
                    .padding(.trailing)
            }
        }
        .frame(width: 250, height: 100) 
    }
}
