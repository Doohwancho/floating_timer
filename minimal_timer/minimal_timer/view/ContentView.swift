import SwiftUI
import AppKit

struct ContentView: View {
    @ObservedObject var timerModel: TimerModel
    @ObservedObject var accumulatedTimeModel: AccumulatedTimeModel
    @Environment(\.scenePhase) private var scenePhase //observer to check whether app is active
    
    // Enum to track which UI is active
    enum ActiveView {
        case minimalTimer
        case transparentTimer
        case calendar
        case todoList
    }
    @State private var activeView: ActiveView = .minimalTimer
    
    @State private var accumulatedNumber: String = ""
    @State private var isInsertMode = false
    
    @State private var inputText = ""
    @State private var currentDate = Date().addingTimeInterval(TimeInterval(TimeZone(identifier: "Asia/Seoul")!.secondsFromGMT()))
    @State private var shouldResizeWindow = false
    
    var body: some View {
        Group {
            switch activeView {
            case .minimalTimer:
                if timerModel.showResult {
                    ResultView(
                        timerModel: timerModel,
                        activeView: $activeView
                    ).frame(width: ViewDimensions.minimalTimerWithResult.size.width,
                               height: ViewDimensions.minimalTimerWithResult.size.height)
                } else {
                    MinimalTimerView(
                        timerModel: self.timerModel,
                        accumulatedTimeModel: self.accumulatedTimeModel,
                        activeView: $activeView,
                        inputText: $inputText
                    ).frame(width: ViewDimensions.minimalTimer.size.width, height: ViewDimensions.minimalTimer.size.height)
                }
            case .transparentTimer:
                TransparentTimerView(
                    timerModel: self.timerModel,
                    accumulatedTimeModel: self.accumulatedTimeModel,
                    activeView: $activeView
                ).frame(width: ViewDimensions.transparentTimer.size.width, height: ViewDimensions.transparentTimer.size.height)
            case .calendar:
                CalendarWithDailyTimeView(
                    accumulatedTimeModel: self.accumulatedTimeModel,
                    currentDate: $currentDate,
                    activeView: $activeView
                ).frame(width: ViewDimensions.calendar.size.width, height: ViewDimensions.calendar.size.height)
            case .todoList:
                TodoListView(activeView: $activeView, shouldResizeWindow: $shouldResizeWindow)
                    .frame(
                        width: ViewDimensions.todoList(numberOfTodos: TodoListState.shared.todos.count).size.width,
                        height: ViewDimensions.todoList(numberOfTodos: TodoListState.shared.todos.count).size.height
                    )
            }
        }
        .onChange(of: timerModel.showResult) { _, _ in
            DispatchQueue.main.async {
                if let window = NSApplication.shared.windows.first {
                    configureWindow(window)
                }
            }
        }
        .onChange(of: scenePhase) { _, newPhase in
            accumulatedTimeModel.scenePhase = newPhase
        }
        .onChange(of: shouldResizeWindow) { newValue in
            if newValue {
                DispatchQueue.main.async {
                    if let window = NSApplication.shared.windows.first {
                        configureWindow(window)
                    }
                    shouldResizeWindow = false  // Reset the trigger
                }
            }
        }
        .background(WindowAccessor { window in
            configureWindow(window)
        })
        .onAppear {
            accumulatedTimeModel.recalculateStreaks()
            
            NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
                //switching between views
                if event.modifierFlags.contains(.command) {
                    switch event.keyCode {
                    case 50: // Command + `
                        activeView = .todoList
                        DispatchQueue.main.async {
                            if let window = NSApplication.shared.windows.first {
                                configureWindow(window)
                            }
                        }
                    case 18: // Command + 1
                        activeView = .minimalTimer
                        accumulatedTimeModel.checkForDateChange()
                        DispatchQueue.main.async {
                            if let window = NSApplication.shared.windows.first {
                                configureWindow(window)
                            }
                        }
                        //                                return nil
                    case 19: // Command + 2
                        activeView = .transparentTimer
                        accumulatedTimeModel.checkForDateChange()
                        DispatchQueue.main.async {
                            if let window = NSApplication.shared.windows.first {
                                configureWindow(window)
                            }
                        }
                        //                                return nil
                    case 20: // Command + 3
                        activeView = .calendar
                        accumulatedTimeModel.checkForDateChange()
                        DispatchQueue.main.async {
                            if let window = NSApplication.shared.windows.first {
                                configureWindow(window)
                            }
                        }
                        //                                return nil
                    case 13: // Command + W
                        NSApplication.shared.terminate(self)
                        //                                return nil
                    default:
                        break
                    }
                }
                return event
            }
        }.onDisappear { //before app terminates, update max streaks
            self.accumulatedTimeModel.updateStreaks()
        }
    }
    
    private func configureWindow(_ window: NSWindow?) {
        guard let window = window else { return }
        
        //최소화, 최대화, 닫기 창을 style을 숨기는 코드
        window.titleVisibility = .hidden
        window.titlebarAppearsTransparent = true
        window.styleMask.insert(.borderless)
        window.styleMask.remove(.titled)
        window.styleMask.remove(.closable)
        window.styleMask.remove(.miniaturizable)
        window.styleMask.remove(.resizable)
        
        /*
            style 구조
            
            1. 하나의 window가 있고,
            2. 이 window에 3개의 각개 다른 View들(MinimalTimerView, TransparentTimerView, CalendarWithDailyTimeView)가 붙는다.
            3. 각 View의 style을 바꾸려면, 부모 window의 스타일을 transparent처리한 이 후, 각 View들 내부에서 개별적 style을 수정해준다. (window style을 투명하게 안하면 자식 view들의 style 수정시, 부모 window의 style이 같이 보여서 미관상 안좋다.)
            4. 모든 View들에 공통적용되는 cornerRadius는 아래에 `window.contentView.layer.cornerRadius = 18`로 설정한다.
         */
        
        //부모 window style을 투명하게 바꿔주는 코드
        window.isOpaque = false
        window.backgroundColor = .clear
        window.isMovableByWindowBackground = true
        window.level = .floating
        
        //모든 자식 view들에게 공통적용되는 rounded corner
        window.contentView?.wantsLayer = true
        window.contentView?.layer?.cornerRadius = 18
        //window.contentView?.layer?.masksToBounds = true //내부 view가 상위 window 모양에 종속되도록 하는 코드 resource: https://stackoverflow.com/questions/1509547/giving-uiview-rounded-corners
        
        positionWindow(window)
    }
    
    private func positionWindow(_ window: NSWindow) {
        let size = getWindowSize()
        window.setContentSize(size)
        
        if let screen = window.screen {
            let screenWidth = screen.visibleFrame.width
            let screenHeight = screen.visibleFrame.height
            
            // Calculate position to maintain the same top-right corner
            let newOriginX = screenWidth - size.width - 5
            let newOriginY = screenHeight - size.height - 37
            
            window.setFrameOrigin(NSPoint(x: newOriginX, y: newOriginY))
        }
    }
    
    private func getWindowSize() -> CGSize {
       switch activeView {
       case .minimalTimer:
               return timerModel.showResult ?
                   ViewDimensions.minimalTimerWithResult.size :
                   ViewDimensions.minimalTimer.size
       case .transparentTimer:
           return ViewDimensions.transparentTimer.size
       case .calendar:
           return ViewDimensions.calendar.size
       case .todoList:
           return ViewDimensions.todoList(numberOfTodos: TodoListState.shared.todos.count).size
       }
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
