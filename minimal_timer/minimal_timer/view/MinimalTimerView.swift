import Foundation
import SwiftUI

struct MinimalTimerView: View {
    @ObservedObject var timerModel:TimerModel
    @ObservedObject var accumulatedTimeModel:AccumulatedTimeModel
    
    @Binding var activeView: ContentView.ActiveView
    
    @Binding var inputText: String
    @State private var accumulatedNumber: String = ""
    
    @State private var eventMonitor: Any?
    @FocusState private var isFocused: Bool
    @State private var isInsertMode = false
    
    // MARK: - 주석 처리된 기존 코드
    /*
    private var currentDimensions: ViewDimensions {
        timerModel.showResult ? .minimalTimerWithResult : .minimalTimer
    }
    */

    var body: some View {
        // MARK: - 변경된 코드 (배경색 동적 변경)
        let isOvertime = timerModel.timeRemaining < 0
        
        ZStack{
            //1. 할일 적기 (pressing 'i' as insert mode)
            // MARK: - 주석 처리된 기존 isGameMode 확인 로직
            // if !timerModel.isGameMode {
                if isInsertMode {
                    TextField("Enter text", text: $inputText)
                        .textFieldStyle(.plain)
                        .focused($isFocused)
                        .font(.system(size: 7))
                        .padding(3)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                        .padding(.horizontal)
                        .padding(.top, 0)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                        .zIndex(1)
                        .onSubmit {
                            handleInsertModeChange(newValue: false)
                        }
                        .onAppear {
                            DispatchQueue.main.async {
                                NSApp.activate(ignoringOtherApps: true)
                                isFocused = true
                                isInsertMode = true
                            }
                        }
                        .onChange(of: isInsertMode) { oldValue, newValue in
                            isFocused = newValue
                        }
                } else {
                    Text(inputText)
                        .font(.system(size: 7))
                        .foregroundColor(.white)
                        .padding(3)
                        .padding(.horizontal)
                        .padding(.top, 0)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .zIndex(1)
                }
            // }
            
            //2. timer
            // MARK: - 주석 처리된 기존 isGameMode 분기
            /*
            if timerModel.isGameMode {
                Text("?")
                    .font(.largeTitle)
                    .frame(width: ViewDimensions.minimalTimer.size.width, height: ViewDimensions.minimalTimer.size.height)
                    .foregroundColor(.white)
            } else {
            */
                Text(timerModel.formatTime(timerModel.timeRemaining))
                    .font(.largeTitle)
                    .frame(width: ViewDimensions.minimalTimer.size.width, height: ViewDimensions.minimalTimer.size.height)
                    .foregroundColor(.white)
                    .onTapGesture {
                        // 탭 제스처로도 타이머 제어 가능
                        timerModel.toggleTimer()
                    }
            
                //3. accumulated time
                Text(accumulatedTimeModel.getTotalAccumulatedTime() + " / "
                     + accumulatedTimeModel.getTodayAccumulatedTime())
                .font(.caption)
                .padding(.top, 35)
                .padding(.trailing, 10)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .bottomTrailing)
            // }
        }
        // MARK: - 변경된 코드 (동적 배경 및 애니메이션)
        .background(isOvertime ? Color(red: 0.5, green: 0, blue: 0) : Color.black)
        .animation(.easeInOut(duration: 1.0), value: isOvertime)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .onChange(of: isInsertMode) { oldValue, newValue in
            isFocused = newValue
        }
        .onChange(of: activeView) { oldValue, newValue in
            if newValue != .minimalTimer {
                cleanupEventMonitor()
                handleInsertModeChange(newValue: false)
            }
        }
        .onAppear {
            cleanupEventMonitor()
            handleInsertModeChange(newValue: false)
            
            eventMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
                // MARK: - 변경된 코드 (showResult 조건 제거)
                guard activeView == .minimalTimer else { return event }
            
                let isTypingMode = isInsertMode || isFocused
                if !isTypingMode {
                    //feat1: set time
                    // MARK: - 주석 처리된 기존 isGameMode 확인
                    // if !event.modifierFlags.contains(.command) && !self.timerModel.isGameMode {
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
                    
                    //feat2: decremental timer
                    if event.keyCode == 49 { // Spacebar
                        // MARK: - 변경된 코드 (toggleTimer 호출)
                        self.timerModel.toggleTimer()
                        
                        // MARK: - 주석 처리된 기존 게임모드 로직
                        /*
                        if self.timerModel.isRunning {
                            if self.timerModel.isGameMode {
                                self.timerModel.stopGameMode()
                            } else {
                                self.timerModel.pauseTimer()
                            }
                        } else {
                            self.timerModel.startGameMode()
                        }
                        */
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
                    
                    //feat4: text 적기
                    if event.keyCode == 34  { // 34: 'i' key
                        handleInsertModeChange(newValue: true)
                        return nil
                    } else if isInsertMode && (event.keyCode == 53 || event.keyCode == 36) { // 53: Esc key, 36: Enter key
                        handleInsertModeChange(newValue: false)
                        return nil
                    }
                }
                
                return event
            }
        }
        .onDisappear {
            cleanupEventMonitor()
            DispatchQueue.main.async {
                isInsertMode = false
                isFocused = false
            }
            handleInsertModeChange(newValue: false)
        }
    }
    
    private func cleanupEventMonitor() {
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
            eventMonitor = nil
        }
    }
    
    private func handleInsertModeChange(newValue: Bool) {
        withAnimation {
            isInsertMode = newValue
            isFocused = newValue
        }
        
        if newValue {
            DispatchQueue.main.async {
                NSApp.activate(ignoringOtherApps: true)
                isFocused = true
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
