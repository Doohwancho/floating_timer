import Foundation
import SwiftUI

struct TodoItem: Identifiable {
    let id = UUID()
    var text: String
}

class TodoListState: ObservableObject {
    static let shared = TodoListState() // Add singleton instance
    
    @Published var todos: [TodoItem] = []
    @Published var selectedIndex: Int? = nil
    
    var selectedTodo: TodoItem? {
        guard let index = selectedIndex, todos.indices.contains(index) else { return nil }
        return todos[index]
    }
}

// Environment key for accessing TodoState
private struct TodoStateKey: EnvironmentKey {
    static let defaultValue: TodoListState? = nil
}

extension EnvironmentValues {
    var todoState: TodoListState? {
        get { self[TodoStateKey.self] }
        set { self[TodoStateKey.self] = newValue }
    }
}
