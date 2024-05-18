import Foundation
import Cocoa

class DraggableWindow: NSWindow {
    override init(contentRect: NSRect, styleMask style: NSWindow.StyleMask, backing backingStoreType: NSWindow.BackingStoreType, defer flag: Bool) {
        super.init(contentRect: contentRect, styleMask: style, backing: backingStoreType, defer: flag)
        configureTransparentUI()
    }

    private func configureTransparentUI() {
        self.titleVisibility = .hidden
        self.titlebarAppearsTransparent = true
        self.styleMask.remove(.closable)
        self.styleMask.remove(.miniaturizable)
        self.styleMask.remove(.resizable)
        self.isOpaque = false
        self.backgroundColor = NSColor.clear
        self.contentView?.wantsLayer = true
        self.contentView?.layer?.cornerRadius = 10
        self.contentView?.layer?.masksToBounds = true
        self.level = .floating
    }

    override func mouseDown(with event: NSEvent) {
        if event.type == .leftMouseDown {
            self.performDrag(with: event)
        }
    }
}
