import Foundation
import SwiftUI

struct ResultView: View {
    @ObservedObject var timerModel: TimerModel
    
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
    }
}
