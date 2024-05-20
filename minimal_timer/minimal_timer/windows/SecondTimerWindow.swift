import Foundation
import Cocoa

class SecondTimerWindow: NSWindow {
    override init(contentRect: NSRect, styleMask style: NSWindow.StyleMask, backing backingStoreType: NSWindow.BackingStoreType, defer flag: Bool) {
        super.init(contentRect: contentRect, styleMask: style, backing: backingStoreType, defer: flag)
        setupCustomWindow()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        setupCustomWindow()
        // DispatchQueue.main.async {
        //     self.setupCustomWindow()
        // }
    }

    private func setupCustomWindow() {
        self.titleVisibility = .hidden
        self.titlebarAppearsTransparent = true
        self.styleMask.remove(.titled)
        self.styleMask.remove(.closable)
        self.styleMask.remove(.miniaturizable)
        self.styleMask.remove(.resizable)
        self.isOpaque = false
        self.backgroundColor = NSColor.clear
        self.contentView?.wantsLayer = true
        self.contentView?.layer?.cornerRadius = 10
        self.contentView?.layer?.masksToBounds = true
        self.level = .floating
        self.setContentSize(NSSize(width: 100, height: 50))
    }

    override func keyDown(with event: NSEvent) {
        if event.modifierFlags.contains(.command) && event.keyCode == 13 {
            // Command+W pressed
            NSApp.terminate(nil)
        } else {
            super.keyDown(with: event)
        }
    }
}

