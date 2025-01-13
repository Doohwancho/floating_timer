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
                guard activeView == .minimalTimer else { return event }
                print("ResutView's event Monoitor")
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
