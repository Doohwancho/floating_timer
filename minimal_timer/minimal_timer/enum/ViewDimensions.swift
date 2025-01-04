import SwiftUI

enum ViewDimensions {
    case minimalTimer
    case minimalTimerWithResult
    case transparentTimer
    case calendar
    
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
        }
    }
}
