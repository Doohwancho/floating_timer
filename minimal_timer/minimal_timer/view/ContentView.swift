import SwiftUI

struct ContentView: View {
    @ObservedObject var timerModel: TimerModel
     @ObservedObject var accumulatedTimeModel: AccumulatedTimeModel

    @State private var isFirstUIVisible = true
    @State private var firstUIWindow: NSWindow?
    @State private var accumulatedNumber: String = ""
    @State private var isInsertMode = false
    private let MAX_CHAR_LIMIT = 14
    @State private var inputText = ""
    // Korean to English mapping
    let koreanToEnglish: [Character: Character] = [
        "ㅁ": "a", "ㅠ": "b", "ㅊ": "c", "ㅇ": "d", "ㄷ": "e", "ㄹ": "f", "ㅎ": "g",
        "ㅗ": "h", "ㅑ": "i", "ㅓ": "j", "ㅏ": "k", "ㅣ": "l", "ㅡ": "m", "ㅜ": "n",
        "ㅐ": "o", "ㅔ": "p", "ㅂ": "q", "ㄱ": "r", "ㄴ": "s", "ㅅ": "t", "ㅕ": "u",
        "ㅍ": "v", "ㅈ": "w", "ㅌ": "x", "ㅛ": "y", "ㅋ": "z"
    ]

    var body: some View {
        Group {
            if isFirstUIVisible {
                FirstTimerView(timerModel: self.timerModel)
                .fixedSize()
                .onAppear {
                    let window1 = NSApplication.shared.windows.first
                    window1?.titleVisibility = .hidden
                    window1?.titlebarAppearsTransparent = true
                    window1?.styleMask.insert(.borderless) // Make window borderless to enable dragging
                    window1?.isMovableByWindowBackground = true // Allow the window to be moved by dragging its background
                    window1?.styleMask.remove(.titled)
                    // window1?.styleMask.remove(.closable)
                    window1?.styleMask.remove(.miniaturizable)
                    window1?.styleMask.remove(.resizable) 
                    // window1?.styleMask.remove(.fullSizeContentView)
                    window1?.isOpaque = false
                    window1?.backgroundColor = NSColor.clear
                    window1?.contentView?.wantsLayer = true
                    window1?.contentView?.layer?.cornerRadius = 10
                    window1?.contentView?.layer?.masksToBounds = true
                    window1?.level = .floating

                    // Adjust the window size to fit the content
                    // window1?.setContentSize(window1?.contentView?.fittingSize ?? .zero)
                    window1?.setContentSize(NSSize(width: 250, height: 100))

                    // Align window to the top right corner of the screen
                    if let screen = window1?.screen {
                        let screenWidth = screen.visibleFrame.width
                        let screenHeight = screen.visibleFrame.height
                        let newOriginX = screenWidth - 250 // window width
                        let newOriginY = screenHeight - 100 // window height
                        window1?.setFrameOrigin(NSPoint(x: newOriginX, y: newOriginY))
                    }
                }
            } else {
                SecondTimerView(timerModel: self.timerModel, accumulatedTimeModel: self.accumulatedTimeModel, inputText: $inputText)
                .fixedSize()
                .onAppear {
                    let window2 = NSApplication.shared.windows.first
                    window2?.titleVisibility = .hidden
                    window2?.titlebarAppearsTransparent = true
                    window2?.styleMask.insert(.borderless) // Make window borderless to enable dragging
                    window2?.isMovableByWindowBackground = true // Allow the window to be moved by dragging its background
                    window2?.styleMask.remove(.titled)
                    // window2?.styleMask.remove(.closable)
                    window2?.styleMask.remove(.miniaturizable)
                    window2?.styleMask.remove(.resizable)
                    // window2?.styleMask.remove(.fullSizeContentView) 
                    window2?.isOpaque = false
                    window2?.backgroundColor = NSColor.clear
                    window2?.contentView?.wantsLayer = true
                    window2?.contentView?.layer?.cornerRadius = 10
                    window2?.contentView?.layer?.masksToBounds = true
                    window2?.level = .floating 

                    // Adjust the window size to fit the content
                    // window2?.setContentSize(window2?.contentView?.fittingSize ?? .zero)
                    window2?.setContentSize(NSSize(width: 100, height: 50))

                    // Align window to the right side of the screen
                    if let screen = window2?.screen {
                        let screenWidth = screen.visibleFrame.width
                        let screenHeight = screen.visibleFrame.height
                        let newOriginX = screenWidth - 100 // window width
                        let newOriginY = screenHeight - 50 // vertically center
                        window2?.setFrameOrigin(NSPoint(x: newOriginX, y: newOriginY))
                    }
                }
            }
        }
        .onAppear {
            NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
                //TODO - disable caplocks key during insert mode
                
                if event.modifierFlags.contains(.command) {
                    switch event.keyCode {
                    case 18: // Command + 1
                        isFirstUIVisible = true
                        return nil
                    case 19: // Command + 2
                        isFirstUIVisible = false
                        return nil
                    case 1: // Command + S
                        if self.timerModel.isRunning {
                            self.timerModel.pauseTimer()
                        } else {
                            self.timerModel.startTimerIncrease()
                        }
                        return nil
                    case 13: // Command + W
                        NSApplication.shared.terminate(self)
                        return nil
                    default:
                        break
                    }
                }
                
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
                
                if event.keyCode == 49 { // Spacebar
                    if self.timerModel.isRunning {
                        self.timerModel.pauseTimer()
                    } else {
                        self.timerModel.startTimerDecrease()
                    }
                    return nil
                }
                
                // Handle number input
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

// #Preview {
    // ContentView()
// }
