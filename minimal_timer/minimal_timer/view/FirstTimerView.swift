import SwiftUI
import Foundation

struct FirstTimerView: View {
    @ObservedObject var timerModel = TimerModel()
    @State private var selectedIndex: Int?

    var body: some View {
        VStack {
            HStack {
                ZStack {
                    HStack(spacing: 1) {
                        ForEach(0..<121) { index in
                            Rectangle()
                                .fill(selectedIndex == index ? Color.black : Color(white: 0.95))
                                .frame(width: 1, height: 20)
                                .onTapGesture {
                                    selectedIndex = index
                                }
                        }
                    }
                    .onChange(of: timerModel.timeRemaining) {  //TODO: esc로 ui 바꾼 후, 1초간 렌더링 안되는 문제가 있다. 
                        newTimeRemaining in
                        selectedIndex = newTimeRemaining / 60 // Assuming timeRemaining is in seconds and you want to convert it to minutes
                    }
                    .frame(height:30)
                }
                .padding(.top, 0) 
            }

            HStack {
                Button(action: {
                    timerModel.setTimer(with: 5)
                    // timerModel.startTimer()
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
                        timerModel.startTimer()
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
