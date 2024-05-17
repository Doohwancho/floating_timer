import Cocoa

class CustomWindow: NSWindow {
    override func awakeFromNib() {
        super.awakeFromNib()
        self.styleMask.remove(.closable)
        self.styleMask.remove(.miniaturizable)
        self.styleMask.remove(.resizable)
    }
}
