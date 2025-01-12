import SwiftUI

struct CalendarWithDailyTimeView: View {
    @ObservedObject var accumulatedTimeModel: AccumulatedTimeModel
    @Binding var currentDate: Date
    @State private var selectedDate: Date?
    
    private let calendar: Calendar = {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(identifier: "Asia/Seoul")!
        calendar.firstWeekday = 2 // 2 represents Monday
        return calendar
    }()
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        return formatter
    }()
    
    private let monthYearFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        return formatter
    }()
    
    private let weekdaySymbols: [String] = {
        let symbols = Calendar.current.shortWeekdaySymbols
        return symbols.rotated(by: symbols.firstIndex(of: "Mon") ?? 0)
    }()
    
    var body: some View {
        VStack {
            HStack {
                Button(action: previousMonth) {
                    Image(systemName: "chevron.left")
                }
                VStack {
                    Text(monthYearFormatter.string(from: currentDate))
                        .font(.headline)
                    Text("\(accumulatedTimeModel.getCurrentStreak()) / \(accumulatedTimeModel.getMaxConsecutiveDays())")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Button(action: nextMonth) {
                    Image(systemName: "chevron.right")
                }
            }
            .padding()
            
            LazyVGrid(columns: Array(repeating: GridItem(.fixed(31)), count: 7), spacing: 8) {
                ForEach(weekdaySymbols, id: \.self) { symbol in
                    Text(symbol)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                ForEach(days(), id: \.self) { date in
                    DayView(date: date, 
                            isSelected: calendar.isDate(date, inSameDayAs: selectedDate ?? Date()),
                            accumulatedSeconds: accumulatedTimeForDate(date))
                        .onTapGesture {
                            selectedDate = date
                        }
                }
            }
        }
        .frame(width: ViewDimensions.calendar.size.width, height: ViewDimensions.calendar.size.height)
        .background(Color(white:0.983))
        .onAppear {
            NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
                switch event.keyCode {
                    case 4: // 'h' key
                        self.currentDate = Calendar.current.date(byAdding: .month, value: -1, to: self.currentDate) ?? self.currentDate
                        return nil
                    case 37: // 'l' key
                        self.currentDate = Calendar.current.date(byAdding: .month, value: 1, to: self.currentDate) ?? self.currentDate
                        return nil
                    default:
                        break
                }
                
                return event
            }
        }
    }
    
    private func days() -> [Date] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: currentDate) else {
            return []
        }
        
        let monthStart = monthInterval.start
        let monthEnd = monthInterval.end
        
        let dateInterval = calendar.dateInterval(of: .weekOfMonth, for: monthStart)!
        var startDate = dateInterval.start
        
        // Adjust start date if it's not a Monday
        if calendar.component(.weekday, from: startDate) != 2 {
            startDate = calendar.date(bySetting: .weekday, value: 2, of: startDate)!
        }
        
        var dates: [Date] = []
        var currentDate = startDate
        
        while currentDate < monthEnd || dates.count % 7 != 0 {
            dates.append(currentDate)
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }
        
        return dates
    }
    
    func previousMonth() {
        currentDate = calendar.date(byAdding: .month, value: -1, to: currentDate) ?? currentDate
    }
    
    func nextMonth() {
        currentDate = calendar.date(byAdding: .month, value: 1, to: currentDate) ?? currentDate
    }
    
    private func accumulatedTimeForDate(_ date: Date) -> Int {
        let dateString = dateFormatter.string(from: date)
        if calendar.isDateInToday(date) {
            return accumulatedTimeModel.todayAccumulatedTime
        }
        return accumulatedTimeModel.getDailyAccumulatedTimes()[dateString] ?? 0
    }
}

struct DayView: View {
    let date: Date
    let isSelected: Bool
    let accumulatedSeconds: Int
    
    private let calendar = Calendar.current
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter
    }()
    
    private var isToday: Bool {
        calendar.isDateInToday(date)
    }
    
    private var colorIntensity: Double {
        if(accumulatedSeconds == 0) {
            return 0
        }
        let hours = Double(accumulatedSeconds) / 3600 + 0.1 //1분이라도 했으면 mark green
        return min(hours / 6, 1.0) // 6 hours as maximum intensity
    }
    
    private var formattedTime: String {
        let hours = accumulatedSeconds / 3600
        let minutes = (accumulatedSeconds % 3600) / 60
        return String(format: "%02d:%02d", hours, minutes)
    }
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack {
                Text(dateFormatter.string(from: date))
                    .font(.system(size: 14, weight: .medium))
                Text(formattedTime)
                    .font(.system(size: 10))
            }
            .frame(width: 33, height: 40)
//            .frame(maxWidth: .infinity)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.green.opacity(colorIntensity))
                    if isToday {
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.blue, lineWidth: 2)
                            //TODO - calendar에서 다음 달로 넘겼을 때, 오늘 위치의 checkmark의 형상이 남아있는 문제가 있다.
                            //.id()에 유니크한 값을 넣어 강제로 re-render을 시도했지만 실패했다.
                            //.id("today-border-\(date)") // Unique ID for today's border for force-re-render
                    }
                }
            )
            .foregroundColor(isSelected ? .blue : .primary)
            
            if accumulatedSeconds > 0 {
                Image(systemName: "checkmark")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.blue)
                    .padding(2)
                    .background(Circle().fill(Color.white))
                    .offset(x: -1.5, y: 2)
                    //TODO - calendar에서 다음 달로 넘겼을 때, 오늘 위치의 checkmark의 형상이 남아있는 문제가 있다.
                    //.id()에 유니크한 값을 넣어 강제로 re-render을 시도했지만 실패했다.
                    //.id("checkmark-\(date)-\(accumulatedSeconds)") // Unique ID for checkmark for force-re-render
            }
        }
    }
}

extension Calendar {
    func generateDates(for dateInterval: DateInterval, matching components: DateComponents) -> [Date] {
        var dates = [Date]()
        dates.append(dateInterval.start)
        
        enumerateDates(startingAfter: dateInterval.start, matching: components, matchingPolicy: .nextTime) { date, _, stop in
            if let date = date {
                if date < dateInterval.end {
                    dates.append(date)
                } else {
                    stop = true
                }
            }
        }
        
        return dates
    }
}
extension Array {
    func rotated(by amount: Int) -> [Element] {
        guard !isEmpty else { return self }
        let amount = amount % count
        return Array(self[amount...] + self[..<amount])
    }
}
