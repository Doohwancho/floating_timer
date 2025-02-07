import SwiftUI

enum ViewDimensions {
    case minimalTimer
    case minimalTimerWithResult
    case transparentTimer
    case calendar
    case todoList(numberOfTodos: Int, todos: [TodoItem]) // Modified to accept todos array
    
    var size: CGSize {
        switch self {
        case .minimalTimer:
            return CGSize(width: 100, height: 50)
        case .minimalTimerWithResult:
            return CGSize(width: 100, height: 80)
        case .transparentTimer:
            return CGSize(width: 270, height: 120)
        case .calendar:
            return CGSize(width: 295, height: 380)
        case .todoList(_, let todos):
            let baseHeight: CGFloat = todos.isEmpty ? 50 : 70 // Base height when empty
//            let inputHeight: CGFloat = 50 // Height for input field
            let paddingHeight: CGFloat = 10 // Total vertical padding
            let containerWidth: CGFloat = 160 // Total width minus horizontal padding
            
            // Calculate total height of all todos
            let totalTodoHeight = todos.reduce(0) { (result, todo) in
                result + calculateTodoHeight(text: todo.text, width: containerWidth)
            }
            
            let calculatedHeight = todos.isEmpty ? baseHeight : totalTodoHeight + paddingHeight
            let maxHeight: CGFloat = 720
            
            return CGSize(width: 200, height: min(calculatedHeight, maxHeight))
        }
    }
    // Helper function to calculate height for a single todo item
    private func calculateTodoHeight(text: String, width: CGFloat) -> CGFloat {
        let font = NSFont.systemFont(ofSize: NSFont.systemFontSize)
//        let baseHeight: CGFloat = 30 // Minimum height for a single line
//        let padding: CGFloat = 5 // Vertical padding within todo item
        
        // Create text container with the available width
        let textStorage = NSTextStorage(string: text)
        let textContainer = NSTextContainer(containerSize: NSSize(width: width, height: CGFloat.greatestFiniteMagnitude))
        let layoutManager = NSLayoutManager()
        
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        
        // Set the font and attributes
        let range = NSRange(location: 0, length: textStorage.length)
        textStorage.addAttribute(.font, value: font, range: range)
        
        // Calculate the height needed
        let glyphRange = layoutManager.glyphRange(for: textContainer)
        let bounds = layoutManager.boundingRect(forGlyphRange: glyphRange, in: textContainer)
        
        // Return max of single line height or calculated height, plus padding
        let linebreakOfText = round(bounds.height / 13)
        if(linebreakOfText == 1) {
            return 46;
        } else { //2줄 이상이면,
            return 62;
        }
    }
}
