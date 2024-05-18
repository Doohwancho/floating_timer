import SwiftUI

struct ContentView: View {
    @ObservedObject var timerModel: TimerModel
    @State private var isFirstUIVisible = true
    @State private var firstUIWindow: NSWindow?

    var body: some View {
        Group {
            if isFirstUIVisible {
                FirstTimerView(timerModel: self.timerModel)
                    // .fixedSize()
                .onAppear {
                    let window1 = NSApplication.shared.windows.first
                    window1?.titleVisibility = .hidden
                    window1?.titlebarAppearsTransparent = true
                    // window1?.styleMask.remove(.titled)
                    window1?.styleMask.remove(.closable)
                    window1?.styleMask.remove(.miniaturizable)
                    window1?.styleMask.remove(.resizable) 
                    window1?.styleMask.remove(.fullSizeContentView)
                    window1?.isOpaque = false
                    window1?.backgroundColor = NSColor.clear
                    window1?.contentView?.wantsLayer = true
                    window1?.contentView?.layer?.cornerRadius = 10
                    window1?.contentView?.layer?.masksToBounds = true
                    window1?.level = .floating

                    // Adjust the window size to fit the content
                    // window1?.setContentSize(window1?.contentView?.fittingSize ?? .zero)
                    window1?.setContentSize(NSSize(width: 250, height: 100))
                }
            } else {
                SecondTimerView(timerModel: timerModel)
                .fixedSize()
                .onAppear {
                    let window2 = NSApplication.shared.windows.first
                    window2?.titleVisibility = .hidden
                    window2?.titlebarAppearsTransparent = true
                    // window2?.styleMask.remove(.titled)
                    window2?.styleMask.remove(.closable)
                    window2?.styleMask.remove(.miniaturizable)
                    window2?.styleMask.remove(.resizable)
                    window2?.styleMask.remove(.fullSizeContentView) 
                    window2?.isOpaque = false
                    window2?.backgroundColor = NSColor.clear
                    window2?.contentView?.wantsLayer = true
                    window2?.contentView?.layer?.cornerRadius = 10
                    window2?.contentView?.layer?.masksToBounds = true
                    window2?.level = .floating 

                    // Adjust the window size to fit the content
                    // window2?.setContentSize(window2?.contentView?.fittingSize ?? .zero)
                    window2?.setContentSize(NSSize(width: 100, height: 50))
                }
            }
        }
        .onAppear {
            //spacebar = 49
            //esc = 53
            NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
                if event.keyCode == 53 { 
                    isFirstUIVisible.toggle() //TODO: when toggle, delete switching sound
                    // withAnimation {
                    //     isFirstUIVisible.toggle()
                    // }
                }
                return event
            }

            NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
                if event.keyCode == 49 { // keyCode for spacebar
                    if self.timerModel.isRunning {
                        self.timerModel.pauseTimer()
                    } else {
                        self.timerModel.startTimer()
                    }
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
                        self.timerModel.timeRemaining = 300 // 5 minutes
                        // self.timerModel.startTimer()
                    case 19: // keyCode for 2
                        if(self.timerModel.isRunning) {
                            self.timerModel.stopTimer()
                        }
                        self.timerModel.timeRemaining = 600 // 10 minutes
                        // self.timerModel.startTimer()
                    case 20: // keyCode for 3
                        if(self.timerModel.isRunning) {
                            self.timerModel.stopTimer()
                        }
                        self.timerModel.timeRemaining = 1500 // 25 minutes
                        // self.timerModel.startTimer()
                    default:
                        break
                    }
                }
                return event
            }
        }
    }
}





// #Preview {
    // @ObservedObject var timerModel: TimerModel
    // ContentView(timerModel: timerModel)
// }
