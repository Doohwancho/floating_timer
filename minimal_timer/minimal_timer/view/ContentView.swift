import SwiftUI
import AppKit

struct ContentView: View {
    @ObservedObject var timerModel: TimerModel
    @ObservedObject var accumulatedTimeModel: AccumulatedTimeModel
    @Environment(\.scenePhase) private var scenePhase //observer to check whether app is active
    
    // Enum to track which UI is active
    enum ActiveView {
        case todoList
        case minimalTimer
        case transparentTimer
        case calendar
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
            case .todoList:
                TodoListView(
                    activeView: $activeView,
                    shouldResizeWindow: $shouldResizeWindow,
                    inputText: $inputText
                )
                    .frame(
                        width: ViewDimensions.todoList(numberOfTodos: TodoListState.shared.todos.count, todos: TodoListState.shared.todos).size.width,
                        height: ViewDimensions.todoList(numberOfTodos: TodoListState.shared.todos.count, todos: TodoListState.shared.todos).size.height
                    )
            case .minimalTimer:
                // MARK: - 주석 처리된 기존 ResultView 분기 로직
                /*
                if timerModel.showResult {
                    ResultView(
                        timerModel: timerModel,
                        activeView: $activeView
                    ).frame(width: ViewDimensions.minimalTimerWithResult.size.width,
                             height: ViewDimensions.minimalTimerWithResult.size.height)
                } else {
                */
                    MinimalTimerView(
                        timerModel: self.timerModel,
                        accumulatedTimeModel: self.accumulatedTimeModel,
                        activeView: $activeView,
                        inputText: $inputText
                    ).frame(width: ViewDimensions.minimalTimer.size.width, height: ViewDimensions.minimalTimer.size.height)
                // }
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
            }
        }
        // MARK: - 주석 처리된 기존 onChange(of: timerModel.showResult)
        /*
        .onChange(of: timerModel.showResult) { _, _ in
            DispatchQueue.main.async {
                if let window = NSApplication.shared.windows.first {
                    configureWindow(window)
                }
            }
        }
        */
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
                    case 19: // Command + 2
                        activeView = .transparentTimer
                        accumulatedTimeModel.checkForDateChange()
                        DispatchQueue.main.async {
                            if let window = NSApplication.shared.windows.first {
                                configureWindow(window)
                            }
                        }
                    case 20: // Command + 3
                        activeView = .calendar
                        accumulatedTimeModel.checkForDateChange()
                        DispatchQueue.main.async {
                            if let window = NSApplication.shared.windows.first {
                                configureWindow(window)
                            }
                        }
                    case 13: // Command + W
                        NSApplication.shared.terminate(self)
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
        window.contentView?.layer?.cornerRadius = 18
        
        positionWindow(window)
    }
    
    private func positionWindow(_ window: NSWindow) {
        let size = getWindowSize()
        window.setContentSize(size)
        
        if let screen = window.screen {
            let screenWidth = screen.visibleFrame.width
            let screenHeight = screen.visibleFrame.height
            
            let newOriginX = screenWidth - size.width - 5
            let newOriginY = screenHeight - size.height - 37
            
            window.setFrameOrigin(NSPoint(x: newOriginX, y: newOriginY))
        }
    }
    
    private func getWindowSize() -> CGSize {
        switch activeView {
        case .minimalTimer:
            // MARK: - 변경된 코드 (showResult 조건 제거)
            return ViewDimensions.minimalTimer.size
            /*
            return timerModel.showResult ?
                ViewDimensions.minimalTimerWithResult.size :
                ViewDimensions.minimalTimer.size
            */
        case .transparentTimer:
            return ViewDimensions.transparentTimer.size
        case .calendar:
            return ViewDimensions.calendar.size
        case .todoList:
            return ViewDimensions.todoList(
                numberOfTodos: TodoListState.shared.todos.count,
                todos: TodoListState.shared.todos
            ).size
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
