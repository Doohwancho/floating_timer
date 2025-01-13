import Foundation
import SwiftUI

struct ResultView: View {
//    @ObservedObject var timerModel: TimerModel
    let timerModel: TimerModel
    
    @Binding var activeView: ContentView.ActiveView
    @State private var eventMonitor: Any?
    
    var body: some View {
        VStack(alignment: .center, spacing: 4) {
            // Main accuracy percentage
            Text("\(String(format: "%.0f", timerModel.getAccuracyPercentage()))%")
                .font(.title)
                .foregroundColor(.white)
            
            // Difference in small text
            Text(timerModel.formatTimeDifference(timerModel.getTimeDifference()))
                .font(.caption)
                .foregroundColor(.gray)
            
            Text("🔥 \(timerModel.consecutiveStreaks)")
                .font(.caption)
                .foregroundColor(.green)
        }
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .onAppear {
            // Clean up any existing monitor first
            cleanupEventMonitor()
            
            eventMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
                guard activeView == .minimalTimer && timerModel.showResult else { return event }
                
                //feat: decremental timer
                if event.keyCode == 49 { // Spacebar
                    // If we're showing results, reset to timer view
                    if self.timerModel.showResult {
                        self.timerModel.showResult = false
                        self.timerModel.isGameMode = false
                        // Reset to default timer state or keep last time
                        //self.timerModel.timeRemaining = 600  // default time
                    }
                    return nil
                }
                
                return event
            }
        }
        .onDisappear {
            cleanupEventMonitor()
        }
    }
    
    private func cleanupEventMonitor() {
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
            eventMonitor = nil
        }
    }
}
