import Foundation
import SwiftUI

struct MinimalTimerView: View {
    @ObservedObject var timerModel:TimerModel
    @ObservedObject var accumulatedTimeModel:AccumulatedTimeModel
    
    @Binding var activeView: ContentView.ActiveView
    
    @Binding var inputText: String
    @State private var isInsertMode = false
    private let MAX_CHAR_LIMIT = 14
    
    @State private var accumulatedNumber: String = ""
    
    // Korean to English mapping
    let koreanToEnglish: [Character: Character] = [
        "ㅁ": "a", "ㅠ": "b", "ㅊ": "c", "ㅇ": "d", "ㄷ": "e", "ㄹ": "f", "ㅎ": "g",
        "ㅗ": "h", "ㅑ": "i", "ㅓ": "j", "ㅏ": "k", "ㅣ": "l", "ㅡ": "m", "ㅜ": "n",
        "ㅐ": "o", "ㅔ": "p", "ㅂ": "q", "ㄱ": "r", "ㄴ": "s", "ㅅ": "t", "ㅕ": "u",
        "ㅍ": "v", "ㅈ": "w", "ㅌ": "x", "ㅛ": "y", "ㅋ": "z"
    ]
    
    
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
        .onAppear {
            NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
                // Only handle events when this view is active
                guard activeView == .minimalTimer else { return event }

                
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
                if !isInsertMode && event.keyCode == 49 { // Spacebar
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
                if !isInsertMode && event.modifierFlags.contains(.command) {
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
                if !isInsertMode && event.keyCode == 34  { // 34: 'i' key
                    isInsertMode = true
                    return nil
                } else if isInsertMode && (event.keyCode == 53 || event.keyCode == 36) { // 53: Esc key, 36: Enter key
                    if isInsertMode {
                        isInsertMode = false
                    }
                    return nil
                }
                
                if isInsertMode {
                    if event.keyCode == 51 { // Backspace key
                        if event.modifierFlags.contains(.command) {
                            // Command + Backspace: clear all text
                            inputText = ""
                        } else if event.modifierFlags.contains(.option) {
                            // Option + Backspace: delete last word
                            inputText = deleteLastWord(from: inputText)
                        } else if !inputText.isEmpty {
                            // Regular Backspace: remove last character
                            inputText.removeLast()
                        }
                    } else if let inputChar = event.characters?.first, inputText.count < MAX_CHAR_LIMIT {
                        let mappedChar = mapKoreanToEnglish(inputChar)
                        inputText += String(mappedChar)
                    } else {
                        // Add feedback when limit is reached
                        NSSound.beep()
                    }
                    return nil
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
    
    private func mapKoreanToEnglish(_ char: Character) -> Character {
        if let englishChar = koreanToEnglish[char] {
            return englishChar
        } else if char.isASCII && char.isLetter {
            return char.lowercased().first!
        } else {
            return char
        }
    }
    
    private func deleteLastWord(from text: String) -> String {
        guard !text.isEmpty else { return text }
        
        var newText = text
        
        // First, remove trailing spaces
        while newText.last?.isWhitespace == true {
            newText.removeLast()
        }
        
        // Then remove the last word
        while !newText.isEmpty && !newText.last!.isWhitespace {
            newText.removeLast()
        }
        
        return newText
    }
 }
