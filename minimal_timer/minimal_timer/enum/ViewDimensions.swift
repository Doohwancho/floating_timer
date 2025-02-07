import SwiftUI

enum ViewDimensions {
    case minimalTimer
    case minimalTimerWithResult
    case transparentTimer
    case calendar
    case todoList(numberOfTodos: Int)
    
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
        case .todoList(let numberOfTodos):
            let baseHeight: CGFloat = numberOfTodos == 0 ? 50 : 70 // Smaller height when empty
            let todoItemHeight: CGFloat = 40
            let inputHeight: CGFloat = 50 // Height for input field
            let paddingHeight: CGFloat = 24 // Total vertical padding
            
            let calculatedHeight = if numberOfTodos == 0 {
                baseHeight // Just show base height when empty
            } else {
                CGFloat(numberOfTodos) * todoItemHeight
            }
            
            let maxHeight: CGFloat = 720
            return CGSize(width: 200, height: min(calculatedHeight, maxHeight))
        }
    }
}
