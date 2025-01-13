import SwiftUI
import AppKit

struct TodoListView: View {
    @StateObject private var todoState = TodoListState.shared
    @State private var isInsertMode = false
    @State private var isEditMode = false
    @State private var todoText = ""
    
    @Binding var activeView: ContentView.ActiveView
    @Binding var shouldResizeWindow: Bool
    @Binding var inputText: String
    
    @FocusState private var isFocused: Bool
    @State private var eventMonitor: Any?
    @State private var scrollProxy: ScrollViewProxy?
    @State private var insertPosition: InsertPosition = .bottom
        
    
    enum InsertPosition {
        case bottom      // 'i' - add at bottom
        case below       // 'o' - add below current
        case above       // 'O' - add above current
    }
        
    private var currentSize: CGSize {
        ViewDimensions.todoList(numberOfTodos: todoState.todos.count).size
    }
    
    var body: some View {
        VStack(spacing: 12) {
            if isInsertMode || isEditMode {
                TextField(isEditMode ? "Edit TODO" : "New TODO", text: $todoText)
                    .textFieldStyle(.plain)
                    .focused($isFocused)
                    .padding(8)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                    .padding(.top, 12)
                    .padding(.bottom, 8)
                    .padding(.horizontal)
                    .foregroundColor(.white) //text color
                    .onSubmit {
                        if isEditMode {
                            handleTodoEdit()
                        } else {
                            handleTodoSubmit()
                        }
                    }
                    .onAppear {
                        NSApp.activate(ignoringOtherApps: true)
                    }
//                    .onExitCommand {
//                        isInsertMode = false
//                        isFocused = false
//                        todoText = ""
//                    }
            } else if !isInsertMode && todoState.todos.isEmpty {
                // Show placeholder when no todos and not in insert mode
                Text("Press 'i' to add todo")
                    .foregroundColor(.gray)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 8)
            } else {
                ScrollView(.vertical, showsIndicators: false) {
                    ScrollViewReader { proxy in
                        VStack(spacing: 8) {
                            ForEach(Array(todoState.todos.enumerated()), id: \.element.id) { index, todo in
                                Text(todo.text)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(8)
                                    .background(index == todoState.selectedIndex ? Color.blue.opacity(0.3) : Color.clear)
                                    .cornerRadius(8)
                                    .id(index) // Add id for scrolling
                            }
                        }
                        .padding(.horizontal)
                        .onChange(of: todoState.selectedIndex) { _, newIndex in
                            if let index = newIndex {
                                // Scroll to the selected item with animation
                                withAnimation {
                                    proxy.scrollTo(index, anchor: .center)
                                }
                            }
                        }
                        .onAppear {
                            scrollProxy = proxy
                        }
                    }
                }
            }
        }
        .frame(width: currentSize.width, height: currentSize.height, alignment: .top)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .background(Color.black)
        .foregroundColor(.white)
        .onChange(of: todoState.todos.count) { _ in
            shouldResizeWindow = true  // Trigger resize
        }
        .onChange(of: isInsertMode) { newValue in
            isFocused = newValue
        }
        .onAppear {
            setupInitialState()
            setupEventMonitoring()
            
            // Reset state when view appears
            isInsertMode = false
            isFocused = false
            todoText = ""
        }
        .onDisappear {
            cleanupEventMonitor()
            
            // Reset state when view appears
            isInsertMode = false
            isFocused = false
            todoText = ""
        }
    }
    
    private func handleTodoEdit() {
        if !todoText.isEmpty, let selectedIndex = todoState.selectedIndex {
            todoState.todos[selectedIndex] = TodoItem(text: todoText)
            todoText = ""
        }
        isEditMode = false
        isFocused = false
    }
    
    private func handleTodoSubmit() {
        if !todoText.isEmpty {
            switch insertPosition {
            case .bottom:
                todoState.todos.append(TodoItem(text: todoText))
            case .below:
                if let selectedIndex = todoState.selectedIndex {
                    todoState.todos.insert(TodoItem(text: todoText), at: selectedIndex + 1)
                    todoState.selectedIndex = selectedIndex + 1
                } else {
                    todoState.todos.append(TodoItem(text: todoText))
                }
            case .above:
                if let selectedIndex = todoState.selectedIndex {
                    todoState.todos.insert(TodoItem(text: todoText), at: selectedIndex)
                    todoState.selectedIndex = selectedIndex
                } else {
                    todoState.todos.insert(TodoItem(text: todoText), at: 0)
                }
            }
            todoText = ""
        }
        isInsertMode = false
        isFocused = false
    }
    
    private func setupInitialState() {
        if !todoState.todos.isEmpty && todoState.selectedIndex == nil {
            todoState.selectedIndex = 0
        }
    }
    
    private func setupEventMonitoring() {
        eventMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            // Only handle events when this view is the active view
            guard activeView == .todoList else { return event }

            //when is not insert mode
            if !isInsertMode && !isEditMode {
                if handleNonInsertModeKeys(event) {
                    return nil
                }
            }

            //when insert mode
            if isInsertMode || isEditMode {
                if event.keyCode == 53 { // Escape key
                    isInsertMode = false
                    isEditMode = false
                    isFocused = false
                    todoText = ""
                    return nil
                }
                else if event.keyCode == 36 { // Enter key (return)
                    if isEditMode {
                        handleTodoEdit()
                    } else {
                        handleTodoSubmit()
                    }
                    return nil
                }
                return event
            }
            
            // Handle global command keys
            if event.modifierFlags.contains(.command) {
                if handleCommandKeys(event) {
                    return nil
                }
            }
            
            return event
        }
    }
    
    private func handleNonInsertModeKeys(_ event: NSEvent) -> Bool {
        switch event.keyCode {
        case 34: // 'i' key
            isInsertMode = true
            isEditMode = false
            insertPosition = .bottom
            isFocused = true
            return true
        case 31: // 'o' key
            if event.modifierFlags.contains(.shift) {
                // Capital 'O'
                isInsertMode = true
                isEditMode = false
                insertPosition = .above
                isFocused = true
            } else {
                // Lowercase 'o'
                isInsertMode = true
                isEditMode = false
                insertPosition = .below
                isFocused = true
            }
            return true
        case 36: // Enter key
            if event.modifierFlags.contains(.command) {
                // Handle Command + Enter
                if let selectedTodo = todoState.selectedTodo {
                    activeView = .minimalTimer
                    inputText = selectedTodo.text
                    DispatchQueue.main.async {
                        if let window = NSApplication.shared.windows.first {
                            // This will reposition the window based on the new view size
                            if let screen = window.screen {
                                let screenWidth = screen.visibleFrame.width
                                let screenHeight = screen.visibleFrame.height
                                let size = ViewDimensions.minimalTimer.size
                                
                                // Set position to default minimal timer position
                                let newOriginX = screenWidth - size.width - 5
                                let newOriginY = screenHeight - size.height - 37
                                
                                window.setContentSize(size)
                                window.setFrameOrigin(NSPoint(x: newOriginX, y: newOriginY))
                            }
                        }
                    }
                    return true
                }
            } else {
                // Handle regular Enter
                if let selectedIndex = todoState.selectedIndex {
                    isEditMode = true
                    isInsertMode = false
                    todoText = todoState.todos[selectedIndex].text
                    isFocused = true
                    return true
                }
            }
            return false
        case 38: // 'j' key
            if !todoState.todos.isEmpty {
                todoState.selectedIndex = min((todoState.selectedIndex ?? -1) + 1, todoState.todos.count - 1)
            }
            return true
        case 40: // 'k' key
            if !todoState.todos.isEmpty {
                todoState.selectedIndex = max((todoState.selectedIndex ?? 1) - 1, 0)
            }
            return true
        case 53: // Escape key
            if isInsertMode || isEditMode {
                isInsertMode = false
                isEditMode = false
                isFocused = false
                todoText = ""
                return true
            }
        default:
            return false
        }
        return false
    }
    
    private func handleCommandKeys(_ event: NSEvent) -> Bool {
        switch event.keyCode {
        case 51: // Command + Delete
            if let selectedIndex = todoState.selectedIndex {
                todoState.todos.remove(at: selectedIndex)
                if todoState.todos.isEmpty {
                    todoState.selectedIndex = nil
                } else {
                    todoState.selectedIndex = min(selectedIndex, todoState.todos.count - 1)
                }
                return true
            }
        default:
            return false
        }
        return false
    }
    
    private func cleanupEventMonitor() {
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
            eventMonitor = nil
        }
    }
}
