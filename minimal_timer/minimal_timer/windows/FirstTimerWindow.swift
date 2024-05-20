import Foundation
import Cocoa

class FirstTimerWindow: NSWindow {
    override init(contentRect: NSRect, styleMask style: NSWindow.StyleMask, backing backingStoreType: NSWindow.BackingStoreType, defer flag: Bool) {
        super.init(contentRect: contentRect, styleMask: style, backing: backingStoreType, defer: flag)
        setupCustomWindow()
    }

    // required init?(coder: NSCoder) {
    //     super.init(coder: coder)
    //     setupCustomWindow()
    // }

    // override func awakeFromNib() {
    //     super.awakeFromNib()
    //     setupCustomWindow()
    //     // DispatchQueue.main.async {
    //     //     self.setupCustomWindow()
    //     // }
    // }

    private func setupCustomWindow() {
        // self.titleVisibility = .hidden
        // print("Setting titleVisibility")
        // print("Current titleVisibility: \(self.titleVisibility)")
        self.titleVisibility = .hidden
        // print("Current titleVisibility: \(self.titleVisibility)")

        // print("Setting titlebarAppearsTransparent: \(self.titlebarAppearsTransparent)")
        self.titlebarAppearsTransparent = true
        // print("Setting titlebarAppearsTransparent: \(self.titlebarAppearsTransparent)")
        self.styleMask.remove(.miniaturizable)
        self.styleMask.remove(.resizable)
        self.isOpaque = false
        self.backgroundColor = NSColor.clear
        self.contentView?.wantsLayer = true
        self.contentView?.layer?.cornerRadius = 10
        self.contentView?.layer?.masksToBounds = true
        self.level = .floating
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
