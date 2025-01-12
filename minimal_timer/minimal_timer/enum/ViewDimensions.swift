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
            let baseHeight: CGFloat = 50 // Height for empty state
            let todoItemHeight: CGFloat = 40 // Height per todo item (including padding)
            let maxHeight: CGFloat = 600 // Maximum height before scrolling
            let calculatedHeight = baseHeight + CGFloat(numberOfTodos) * todoItemHeight
            return CGSize(width: 200, height: min(calculatedHeight, maxHeight))
        }
    }
}
