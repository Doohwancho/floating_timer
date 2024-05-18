import SwiftUI
import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    // var firstUIWindow: NSWindow?
    // var secondUIWindow: NSWindow?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // setupWindows()
        // setupShortcut()
    }

    // func setupWindows() {
    //     let timerModel = TimerModel() // Create an instance of TimerModel

    //     // Setup firstUIWindow
//        let firstContentView = ContentView(timerModel: timerModel)
//        firstUIWindow = TransparentDraggableWindow(
//        // firstUIWindow = NSWindow(
//            contentRect: NSRect(x: 0, y: 0, width: 250, height: 100),
//            styleMask: [.closable, .miniaturizable, .resizable, .fullSizeContentView],
//            backing: .buffered, defer: false)
//        firstUIWindow?.center()
//        firstUIWindow?.setFrameAutosaveName("First UI")
//        firstUIWindow?.contentView = NSHostingController(rootView: firstContentView).view
//        firstUIWindow?.makeKeyAndOrderFront(nil) // Make firstUIWindow key and front
//        firstUIWindow?.isOpaque = false
//        firstUIWindow?.backgroundColor = NSColor.clear
//        firstUIWindow?.contentView?.wantsLayer = true
//        firstUIWindow?.contentView?.layer?.cornerRadius = 10
//        firstUIWindow?.contentView?.layer?.masksToBounds = true
//        firstUIWindow?.level = .floating

    //     // Setup secondUIWindow
    //     let secondContentView = FloatingTimerView(timerModel: timerModel)
    //     secondUIWindow = TransparentDraggableWindow(
    //         contentRect: NSRect(x: 0, y: 0, width: 250, height: 100),
    //         styleMask: [.closable, .miniaturizable, .resizable, .fullSizeContentView],
    //         backing: .buffered, defer: false)
    //     secondUIWindow?.center()
    //     secondUIWindow?.setFrameAutosaveName("Second UI")
    //     secondUIWindow?.contentView = NSHostingController(rootView: secondContentView).view
    //     secondUIWindow?.orderOut(nil) // Initially hide secondUIWindow
    //     secondUIWindow?.level = .floating
    // }

    // func setupShortcut() {
    //     NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { [weak self] event in
    //         print("1")
    //         guard !event.isARepeat else { return } //check if you are holding the key down 

    //         if event.keyCode == 49 { // Corrected keyCode for spacebar
    //             print(event)
    //             print("2")
    //             self?.toggleTimerView()
    //         }
    //         // if event.modifierFlags.contains(.command) && event.keyCode == 49 { // Assuming 'spacebar' is the shortcut key
    //         //     self?.toggleTimerView()
    //         // }
    //     }
    // }
    
    // func toggleTimerView() {
    //     if firstUIWindow?.isVisible == true {
    //         firstUIWindow?.orderOut(nil)
    //         secondUIWindow?.makeKeyAndOrderFront(nil)
    //     } else {
    //         secondUIWindow?.orderOut(nil)
    //         firstUIWindow?.makeKeyAndOrderFront(nil)
    //     }
    // }
}
