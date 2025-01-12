import SwiftUI
import Foundation


struct TransparentTimerView: View {
    @ObservedObject var timerModel:TimerModel
    @ObservedObject var accumulatedTimeModel: AccumulatedTimeModel
    @State private var accumulatedNumber: String = ""

    var body: some View {
        VStack {
            HStack {
                ZStack {
                    HStack(spacing: 1) {
                        ForEach(0..<121) { index in
                            Rectangle()
                                .fill(timerModel.getTimeIndexInMinutes() == index ? Color.black : Color(white: 0.88))
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
        .frame(width: ViewDimensions.transparentTimer.size.width, height: ViewDimensions.transparentTimer.size.height)
        .background(Color(white:0.95))
        .onAppear {
            NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
                //feat1: set time
                if !event.modifierFlags.contains(.command) && !self.timerModel.isGameMode {
                    if let characters = event.characters {
                        for character in characters {
                            if character.isNumber {
                                self.accumulatedNumber.append(character)
                                self.finalizeInput()
                                return nil
                            }
                        }
                    }
                }
                
                //feat2: decremental timer
                if event.keyCode == 49 { // Spacebar
                    // If we're showing results, reset to timer view
                    if self.timerModel.showResult {
                        self.timerModel.showResult = false
                        self.timerModel.isGameMode = false
                        // Reset to default timer state or keep last time
                        self.timerModel.timeRemaining = 600 // default time
                    }
                    else if self.timerModel.isRunning {
                        // Stop timer (either game mode or normal mode)
                        if self.timerModel.isGameMode {
                            self.timerModel.stopGameMode()
                        } else {
                            self.timerModel.pauseTimer()
                        }
                    } else {
                        // Start game mode
                        self.timerModel.startGameMode()
                    }
                    return nil
                }
                
                //feat3: incremental timer
                if event.modifierFlags.contains(.command) {
                    switch event.keyCode {
                    case 1: // Command + S
                        if self.timerModel.isRunning {
                            self.timerModel.pauseTimer()
                        } else {
                            self.timerModel.startTimerIncrease()
                        }
                        return nil
                    default:
                        break
                    }
                }
                
                return event
            }
        }
    }
    private func finalizeInput() {
        if let finalNumber = Int(self.accumulatedNumber) {
            self.timerModel.setTimer(with: finalNumber)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.accumulatedNumber = "" // Reset for next input
        }
    }
}
