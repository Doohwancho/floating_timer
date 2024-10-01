import SwiftUI

struct CalendarWithDailyTimeView: View {
    @State private var currentDate = Date()
    @State private var selectedDate: Date?
    
    private let calendar: Calendar = {
        var calendar = Calendar.current
        calendar.firstWeekday = 2 // 2 represents Monday
        return calendar
    }()
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter
    }()
    
    private let monthYearFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
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
                Text(monthYearFormatter.string(from: currentDate))
                    .font(.headline)
                Button(action: nextMonth) {
                    Image(systemName: "chevron.right")
                }
            }
            .padding()
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                ForEach(weekdaySymbols, id: \.self) { symbol in
                    Text(symbol)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                ForEach(days(), id: \.self) { date in
                    DayView(date: date, isSelected: Calendar.current.isDate(date, inSameDayAs: selectedDate ?? Date()))
                        .onTapGesture {
                            selectedDate = date
                        }
                }
            }
        }
        .frame(width: 300, height: 300)
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
    
    private func previousMonth() {
        currentDate = calendar.date(byAdding: .month, value: -1, to: currentDate) ?? currentDate
    }
    
    private func nextMonth() {
        currentDate = calendar.date(byAdding: .month, value: 1, to: currentDate) ?? currentDate
    }
}

struct DayView: View {
    let date: Date
    let isSelected: Bool
    
    private let calendar = Calendar.current
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter
    }()
    
    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
    
    private var isToday: Bool {
        calendar.isDateInToday(date)
    }
    
    private var colorIntensity: Double {
        let components = calendar.dateComponents([.hour, .minute], from: date)
        let totalMinutes = Double(components.hour! * 60 + components.minute!)
        return totalMinutes / (24 * 60)
    }
    
    var body: some View {
        VStack {
            Text(dateFormatter.string(from: date))
                .font(.system(size: 14, weight: .medium))
            Text(timeFormatter.string(from: date))
                .font(.system(size: 10))
        }
        .frame(height: 40)
        .frame(maxWidth: .infinity)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.red.opacity(colorIntensity * 0.5))
                if isToday {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.blue, lineWidth: 2)
                }
            }
        )
        .foregroundColor(isSelected ? .blue : .primary)
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
