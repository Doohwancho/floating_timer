import SwiftUI

struct ContentView: View {
    @ObservedObject var timerModel: TimerModel
    @State private var isFirstUIVisible = true
    @State private var firstUIWindow: NSWindow?
    @State private var accumulatedNumber: String = ""

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
                SecondTimerView(timerModel: timerModel)
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
                if event.keyCode == 53 {  //esc = 53 of keyCode
                    isFirstUIVisible.toggle() 
                    // withAnimation {
                    //     isFirstUIVisible.toggle()
                    // }
                    return nil
                }
                return event
            }

            NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
                if event.keyCode == 49 { //spacebar = 49 of keyCode
                    if self.timerModel.isRunning {
                        self.timerModel.pauseTimer()
                    } else {
                        self.timerModel.startTimer()
                    }
                    return nil
                }
                return event
            }

            NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            if event.modifierFlags.contains(.command) {
                switch event.keyCode {
                    case 18: // keyCode for 1
                        if(self.timerModel.isRunning) {
                            self.timerModel.stopTimer()
                        }
                        self.timerModel.setTimer(with: 5)
                        return nil
                    case 19: // keyCode for 2
                        if(self.timerModel.isRunning) {
                            self.timerModel.stopTimer()
                        }
                        self.timerModel.setTimer(with: 10)
                        return nil
                    case 20: // keyCode for 3
                        if(self.timerModel.isRunning) {
                            self.timerModel.stopTimer()
                        }
                        self.timerModel.setTimer(with: 25)
                        return nil
                    default:
                        break
                    }
                }
                return event
            }
            
            NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
                if event.modifierFlags.contains(.command) {
                    return event
                }
                    if let characters = event.characters {
                        for character in characters {
                        if character.isNumber {
                            self.accumulatedNumber.append(character)
                            self.finalizeInput()
                            return nil
                        }
                    }
                }
                return event
            }

            NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
                if event.modifierFlags.contains(.command) && event.keyCode == 13 { // keyCode for 'W' is 13
                    NSApplication.shared.terminate(self)
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
}

// #Preview {
    // ContentView()
// }
