import SwiftUI
import Cocoa

@main
struct minimal_timerApp: App {
    var accumulatedTimeModel = AccumulatedTimeModel()
    
//    init() {
        // 앱의 기본 시간대를 Asia/Seoul로 설정
        // TODO - app store에 배포하려면, 현재 자기 위치에 맞는 시간대로 설정해야 함.
//        TimeZone.ReferenceType.default = TimeZone(identifier: "Asia/Seoul")!
//    }

    var body: some Scene {  
        let timerModel = TimerModel(accumulatedTimeModel: accumulatedTimeModel)
        
        WindowGroup {
            ContentView(timerModel: timerModel, accumulatedTimeModel: accumulatedTimeModel)
        }
    }
}

