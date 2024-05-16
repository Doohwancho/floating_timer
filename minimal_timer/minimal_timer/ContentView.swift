import SwiftUI

struct ContentView: View {
    @State private var timeRemaining = 300
    @State private var timer: Timer?
    @State private var isRunning = false

    @State private var selectedIndex: Int?
    
    let totalTime = 300
    
    var body: some View {
        VStack {
            HStack {
                ZStack {
                    HStack(spacing: 1) {
                        ForEach(0..<121) { index in
                            Rectangle()
                                .fill(selectedIndex == index ? Color.black : Color.gray)
                                .frame(width: 1, height: 20)
                                .onTapGesture {
                                    selectedIndex = index
                                }
                        }
                    }.frame(height:30)
                }
                .padding(.top, 0) 
            }

            HStack {
                Button(action: {
                    stopTimer()
                }) {
                    Text("5m")
                }
                .buttonStyle(PlainButtonStyle()) // Makes the button borderless and background colorless
                // .buttonStyle(.borderless) // Makes the button borderless and background colorless
                // .contentEdgeInsets(EdgeInsets(0, 0, 0, 0))
                .padding(.leading)
                
                Button(action: {
                    stopTimer()
                }) {
                    Text("10m")
                }
                .buttonStyle(PlainButtonStyle()) // Makes the button borderless and background colorless
                .padding(.leading)
                
                Button(action: {
                    stopTimer()
                }) {
                    Text("25m")
                }
                .buttonStyle(PlainButtonStyle()) // Makes the button borderless and background colorless
                .padding(.leading)
                
                Spacer()
                
                Text("...")
                .padding(.trailing)
            }
            .padding(.bottom, 1)

            HStack {
                Button(action: {
                    if isRunning {
                        pauseTimer()
                    } else {
                        startTimer()
                    }
                }) {
                    Text(isRunning ? "pause" : "start")
                    .padding(.trailing)
                }
                .buttonStyle(PlainButtonStyle()) // Makes the button borderless and background colorless
                .padding(0)
                .padding(.leading)
                
                Spacer()
                
                Text(formatTime(timeRemaining))
                    .font(.system(size: 32)) // Reduce the font size
                    .padding(.trailing)
            }
        }
        .frame(width: 250, height: 100) // Adjust the width and height to make the screen smaller
    }
    
    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                stopTimer()
            }
        }
        isRunning = true
    }
    
    func pauseTimer() {
        timer?.invalidate()
        timer = nil
        isRunning = false
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
        timeRemaining = totalTime
        isRunning = false
    }
    
    func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%02d:%02d", minutes, remainingSeconds)
    }
}

#Preview {
    ContentView()
}