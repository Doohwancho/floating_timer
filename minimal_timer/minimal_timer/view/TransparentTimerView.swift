import SwiftUI
import Foundation

struct TransparentTimerView: View {
    @ObservedObject var timerModel:TimerModel
    @ObservedObject var accumulatedTimeModel: AccumulatedTimeModel
    
    @Binding var activeView: ContentView.ActiveView
    
    @State private var accumulatedNumber: String = ""
    @State private var eventMonitor: Any? // 키보드 이벤트 모니터를 위한 상태 변수 추가

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
                                    timerModel.setTimer(with: index)
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
                }) {
                    Text("5m")
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.leading)
                
                Button(action: {
                    timerModel.setTimer(with: 10)
                }) {
                    Text("10m")
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.leading)
                
                Button(action: {
                    timerModel.setTimer(with: 25)
                }) {
                    Text("25m")
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.leading)
                
                Spacer()
                
                Text("...")
                .padding(.trailing)
            }
            .padding(.bottom, 1)

            HStack {
                Button(action: {
                    // MARK: - 변경된 코드
                    // 복잡한 분기 대신 toggleTimer()로 통일
                    timerModel.toggleTimer()
                }) {
                    Text(timerModel.isRunning ? "pause" : "start")
                    .padding(.trailing)
                }
                .buttonStyle(PlainButtonStyle())
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
            setupEventMonitor()
        }
        .onDisappear {
            cleanupEventMonitor()
        }
    }
    
    private func setupEventMonitor() {
        // 기존 모니터가 있다면 정리
        cleanupEventMonitor()
        
        eventMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            // 이 뷰가 활성화 상태일 때만 이벤트 처리
            guard activeView == .transparentTimer else { return event }
            
            // MARK: - 변경된 코드: 키보드 이벤트 로직 단순화
            
            // feat1: 숫자키로 시간 설정 (isGameMode 체크 삭제)
            if !event.modifierFlags.contains(.command) {
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
            
            // feat2: 스페이스바로 타이머 제어 (toggleTimer로 단순화)
            if event.keyCode == 49 { // Spacebar
                self.timerModel.toggleTimer()
                return nil
            }
            
            // feat3: Command + S로 증가 타이머 (기존 로직 유지)
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
    
    private func cleanupEventMonitor() {
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
            eventMonitor = nil
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
