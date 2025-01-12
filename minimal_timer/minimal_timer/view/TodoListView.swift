import SwiftUI
import AppKit

struct TodoListView: View {
    @StateObject private var todoState = TodoListState.shared
    @State private var isInsertMode = false
    @State private var todoText = ""
    @Binding var activeView: ContentView.ActiveView
    @Binding var shouldResizeWindow: Bool
    @FocusState private var isFocused: Bool
    @State private var eventMonitor: Any?
    
    private var currentSize: CGSize {
        ViewDimensions.todoList(numberOfTodos: todoState.todos.count).size
    }
    
    var body: some View {
        VStack(spacing: 12) {
            if isInsertMode {
                TextField("New TODO", text: $todoText)
//                    .textFieldStyle(PlainTextFieldStyle())
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
                        handleTodoSubmit()
                    }
                    .onAppear {
                        NSApp.activate(ignoringOtherApps: true)
                    }
//                    .onExitCommand {
//                        isInsertMode = false
//                        isFocused = false
//                        todoText = ""
//                    }
            }
            
            if !isInsertMode && todoState.todos.isEmpty {
                // Show placeholder when no todos and not in insert mode
                Text("Press 'i' to add todo")
                    .foregroundColor(.gray)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 8)
            }
            
            ScrollView {
                VStack(spacing: 8) {
                    ForEach(Array(todoState.todos.enumerated()), id: \.element.id) { index, todo in
                        Text(todo.text)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(8)
                            .background(index == todoState.selectedIndex ? Color.blue.opacity(0.3) : Color.clear)
                            .cornerRadius(8)
                    }
                }
                .padding(.horizontal)
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
    
    private func handleTodoSubmit() {
        if !todoText.isEmpty {
            todoState.todos.append(TodoItem(text: todoText))
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
            if !isInsertMode {
                if handleNonInsertModeKeys(event) {
                    return nil
                }
            }

            //when insert mode
            if isInsertMode {
                if event.keyCode == 53 { // Escape key
                    isInsertMode = false
                    isFocused = false
                    todoText = ""
                    return nil
                }
                else if event.keyCode == 36 { // Enter key (return)
                    handleTodoSubmit()
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
            isFocused = true
            return true
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
            if isInsertMode {
                isInsertMode = false
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
//        case 36: // Command + Return
//            if activeView == .todoList,
//               let selectedTodo = TodoListState.shared.selectedTodo {
//                activeView = .minimalTimer
//                inputText = selectedTodo.text
//                DispatchQueue.main.async {
//                    if let window = NSApplication.shared.windows.first {
//                        configureWindow(window)
//                    }
//                }
//            }
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
