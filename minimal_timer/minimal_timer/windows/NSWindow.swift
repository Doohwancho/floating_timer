import Cocoa

class CustomWindow: NSWindow {
    override func awakeFromNib() {
        super.awakeFromNib()
        self.styleMask.remove(.closable)
        self.styleMask.remove(.miniaturizable)
        self.styleMask.remove(.resizable)
    }

    override func mouseDown(with event: NSEvent) {
        let originalMouseLocation = self.convertPoint(toScreen: event.locationInWindow)
        let originalFrame = self.frame

        while true {
            guard let newEvent = self.nextEvent(matching: [.leftMouseUp, .leftMouseDragged]) else { continue }
            if newEvent.type == .leftMouseUp { break }

            let newMouseLocation = self.convertPoint(toScreen: newEvent.locationInWindow)
            let deltaX = newMouseLocation.x - originalMouseLocation.x
            let deltaY = newMouseLocation.y - originalMouseLocation.y

            var newFrame = originalFrame
            newFrame.origin.x += deltaX
            newFrame.origin.y += deltaY
            self.setFrame(newFrame, display: true)
        }
    }
}
