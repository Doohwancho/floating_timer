import SwiftUI
import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    var firstUIWindow: NSWindow?
    var secondUIWindow: NSWindow?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        setupWindows()
        setupShortcut()
    }

    func setupWindows() {
        let timerModel = TimerModel() // Create an instance of TimerModel

        let firstContentView = ContentView(timerModel: timerModel)
        firstUIWindow = TransparentDraggableWindow(
            contentRect: NSRect(x: 0, y: 0, width: 250, height: 100),
            styleMask: [.closable, .miniaturizable, .resizable, .fullSizeContentView], // Adjusted styleMask
            backing: .buffered, defer: false)
        firstUIWindow?.center()
        firstUIWindow?.setFrameAutosaveName("First UI")
        firstUIWindow?.contentView = NSHostingController(rootView: firstContentView).view
        firstUIWindow?.makeKeyAndOrderFront(nil)

        firstUIWindow?.isOpaque = false
        firstUIWindow?.backgroundColor = NSColor.clear
        firstUIWindow?.contentView?.wantsLayer = true
        firstUIWindow?.contentView?.layer?.cornerRadius = 10 // Set the desired corner radius
        firstUIWindow?.contentView?.layer?.masksToBounds = true


        let secondContentView = FloatingTimerView(timerModel: timerModel)
        secondUIWindow = NSWindow( //?
            contentRect: NSRect(x: 0, y: 0, width: 250, height: 100),
            styleMask: [.closable, .miniaturizable, .resizable, .fullSizeContentView], // Adjusted styleMask
            backing: .buffered, defer: false)
        secondUIWindow?.center()
        secondUIWindow?.setFrameAutosaveName("Second UI")
        secondUIWindow?.contentView = NSHostingController(rootView: secondContentView).view
        secondUIWindow?.makeKeyAndOrderFront(nil)

        // secondUIWindow?.isOpaque = false
        // secondUIWindow?.backgroundColor = NSColor.clear
        // secondUIWindow?.contentView?.wantsLayer = true
        // secondUIWindow?.contentView?.layer?.cornerRadius = 10 // Set the desired corner radius
        // secondUIWindow?.contentView?.layer?.masksToBounds = true

        // let secondContentView = FloatingTimerView(timerModel: timerModel) // Assume you have another view called SecondContentView
        // secondUIWindow = NSWindow(
        //     contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
        //     styleMask: [.titled, .closable, .miniaturizable, .resizable],
        //     backing: .buffered, defer: false)
        // secondUIWindow?.center()
        // secondUIWindow?.setFrameAutosaveName("Second UI")
        // secondUIWindow?.contentView = NSHostingController(rootView: secondContentView).view
        // secondUIWindow?.orderOut(nil)
    }

    func setupShortcut() {
        NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { [weak self] event in
            if event.modifierFlags.contains(.command) && event.keyCode == 49 { // Assuming '1' is the shortcut key
                self?.toggleTimerView()
            }
        }
    }
    
    func toggleTimerView() {
        if firstUIWindow?.isVisible == true {
            firstUIWindow?.orderOut(nil)
            secondUIWindow?.makeKeyAndOrderFront(nil)
        } else {
            secondUIWindow?.orderOut(nil)
            firstUIWindow?.makeKeyAndOrderFront(nil)
        }
    }
}
