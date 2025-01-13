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
    
    
    private var currentDimensions: ViewDimensions {
        timerModel.showResult ? .minimalTimerWithResult : .minimalTimer
    }

    var body: some View {
        ZStack{
            //1. 할일 적기 (pressing 'i' as insert mode)
            if !timerModel.isGameMode {
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
                            handleInsertModeChange(newValue: true)
                        }
                        // Handle focus changes more gracefully
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
        .onChange(of: isInsertMode) { oldValue, newValue in
            isFocused = newValue //TODO - handleInsertModeChange(newValue: newValue)로 바꿀까?
//            print("------ onChange -------")
//            print("oldValue: ", oldValue)
//            print("newValue: ", newValue)
//            print("isInsertMode: ", isInsertMode)
//            print("isFocused: ", isFocused)
        }
        .onChange(of: activeView) { oldValue, newValue in
            if newValue != .minimalTimer {
                cleanupEventMonitor()
            }
        }
        .onAppear {
            // Clean up any existing monitor first
            cleanupEventMonitor()
            
            // Reset states
            handleInsertModeChange(newValue: false) 
            
//            print("------ onAppear -------")
//            print("isInsertMode: ", isInsertMode)
//            print("isFocused: ", isFocused)
            
            NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
                // Only handle events when this view is active
                guard activeView == .minimalTimer && !timerModel.showResult else { return event }
            
                
                let isTypingMode = isInsertMode || isFocused
                if !isTypingMode {
//                    print("---- right now, its NOT insertMode! ----")
//                    print("isInsertMode: ", isInsertMode)
//                    print("isFocused: ", isFocused)
                
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
                       if self.timerModel.isRunning {
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
                    if !timerModel.isGameMode && event.modifierFlags.contains(.command) {
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
                    if !timerModel.isGameMode {
                        if event.keyCode == 34  { // 34: 'i' key
                            handleInsertModeChange(newValue: true)
                            return nil
                        } else if isInsertMode && (event.keyCode == 53 || event.keyCode == 36) { // 53: Esc key, 36: Enter key
                            handleInsertModeChange(newValue: false)
                            return nil
                        }
                    }
                }
                
                return event
            }
        }
        .onDisappear {
            cleanupEventMonitor()
            handleInsertModeChange(newValue: false)
        }
    }
    
    private func cleanupEventMonitor() {
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
            eventMonitor = nil
            print("Event monitor cleaned up - MinimalTimerView")
        }
    }
    
    private func handleInsertModeChange(newValue: Bool) {
        if newValue {
            // Entering insert mode
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.03) {
                isInsertMode = true
                isFocused = true
            }
        } else {
            // Exiting insert mode
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.03) {
                isInsertMode = false
                isFocused = false
            }
        }
        
//        print("------ handleInsertModeChange -------")
//        print("newValue: ", newValue)
//        print("isInsertMode: ", isInsertMode)
//        print("isFocused: ", isFocused)
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
