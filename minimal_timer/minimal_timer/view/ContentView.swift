import SwiftUI
import AppKit

struct ContentView: View {
    @ObservedObject var timerModel: TimerModel
    @ObservedObject var accumulatedTimeModel: AccumulatedTimeModel
    
    // Enum to track which UI is active
    enum ActiveView {
        case minimalTimer
        case transparentTimer
        case calendar
    }
    @State private var activeView: ActiveView = .minimalTimer
    
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
            switch activeView {
                case .minimalTimer:
                    MinimalTimerView(timerModel: self.timerModel, accumulatedTimeModel: self.accumulatedTimeModel, inputText: $inputText)
                        .frame(width: 100, height: 50)
                case .transparentTimer:
                    TransparentTimerView(timerModel: self.timerModel)
                        .frame(width: 250, height: 100)
                case .calendar:
                    CalendarWithDailyTimeView()
                        .frame(width: 300, height: 300)
                }
            }
            .background(WindowAccessor { window in
                configureWindow(window)
            })
                .onAppear {
                    NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
                        //TODO - disable caplocks key during insert mode
                        
                        if event.modifierFlags.contains(.command) {
                            switch event.keyCode {
                                case 18: // Command + 1
                                    activeView = .minimalTimer
                                    DispatchQueue.main.async {
                                        if let window = NSApplication.shared.windows.first {
                                            configureWindow(window)
                                        }
                                    }
                                    return nil
                                case 19: // Command + 2
                                    activeView = .transparentTimer
                                    DispatchQueue.main.async {
                                        if let window = NSApplication.shared.windows.first {
                                            configureWindow(window)
                                        }
                                    }
                                    return nil
                                case 20: // Command + 3
                                    activeView = .calendar
                                    DispatchQueue.main.async {
                                        if let window = NSApplication.shared.windows.first {
                                            configureWindow(window)
                                        }
                                    }
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
    
    private func configureWindow(_ window: NSWindow?) {
        guard let window = window else { return }
        
        window.titleVisibility = .hidden
        window.titlebarAppearsTransparent = true
        window.styleMask.insert(.borderless)
        window.styleMask.remove(.titled)
        window.styleMask.remove(.closable)
        window.styleMask.remove(.miniaturizable)
        window.styleMask.remove(.resizable)
        window.isOpaque = false
        window.backgroundColor = .clear
        window.isMovableByWindowBackground = true
        window.level = .floating
        
        window.contentView?.wantsLayer = true
        window.contentView?.layer?.cornerRadius = 10
        window.contentView?.layer?.masksToBounds = true
        
        positionWindow(window)
    }
    
    private func positionWindow(_ window: NSWindow) {
        let (width, height) = getWindowSize()
        window.setContentSize(NSSize(width: width, height: height))
        
        if let screen = window.screen {
            let screenWidth = screen.visibleFrame.width
            let screenHeight = screen.visibleFrame.height
            let newOriginX = screenWidth - width
            let newOriginY = screenHeight - height
            window.setFrameOrigin(NSPoint(x: newOriginX, y: newOriginY))
        }
    }
    
    private func getWindowSize() -> (CGFloat, CGFloat) {
        switch activeView {
        case .minimalTimer:
            return (100, 50)
        case .transparentTimer:
            return (250, 100)
        case .calendar:
            return (300, 370)
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
    
    struct WindowAccessor: NSViewRepresentable {
        let callback: (NSWindow?) -> Void
        
        func makeNSView(context: Context) -> NSView {
            let view = NSView()
            DispatchQueue.main.async {
                self.callback(view.window)
            }
            return view
        }
        
        func updateNSView(_ nsView: NSView, context: Context) {}
    }
}
// #Preview {
// ContentView()
// }

