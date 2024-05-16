import Cocoa
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow!

    func applicationDidFinishLaunching(_ notification: Notification) {
        if let window = NSApplication.shared.windows.first {
            window.styleMask.remove(.closable)
            window.styleMask.remove(.miniaturizable)
            window.styleMask.remove(.resizable)
            window.level = .floating
        }
    }
}
