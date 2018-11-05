import Foundation

class CalendarUtils {
    
    let formatter = DateFormatter()
    
    func formatCalendarHeader(date: Date) -> String {
        formatter.dateFormat = "yyyy"
        let year = formatter.string(from: date)
        
        formatter.dateFormat = "MMMM"
        let month = formatter.string(from: date).capitalized
        
        return month + ", " + year
    }
    
    func containsDate(date: Date, items: [Date]) -> Bool {
        for tempDate in items {
            if Calendar.current.compare(date, to: tempDate, toGranularity: .day) == .orderedSame {
                return true
            }
        }
        return false
    }
    
    func selectDates(_ items: [Date]) -> [Date] {
        var items = items
        var date = items.first ?? Date()
        let endDate = items.last ?? Date()
        
        if Calendar.current.compare(date, to: endDate, toGranularity: .day) == .orderedSame {
            items = [date, date]
            return items
        }
        items = [date]
        while date < endDate {
            guard let selectedDate = Calendar.current.date(byAdding: .day, value: 1, to: date) else {
                return items
            }
            date = selectedDate
            items.append(selectedDate)
        }
        return items
    }
    
    func inSelectedYear(year: Int, days: [Day]) -> Bool {
        let calendar = Calendar.current
        
        guard let firstDate = days.first?.date,
            let lastDate = days.last?.date else {
                return false
        }
        return calendar.component(.year, from: firstDate) == year ||
            calendar.component(.year, from: lastDate) == year
    }
    
    func getStartDate(startYear: Int) -> Date {
        let startDateString = "01 01 \(startYear)"
        formatter.dateFormat = "dd MM yyyy"
        return formatter.date(from: startDateString) ?? Date()
    }
    
    func getEndDate(endYear: Int) -> Date {
        let endDateString = "31 12 \(endYear)"
        formatter.dateFormat = "dd MM yyyy"
        return formatter.date(from: endDateString) ?? Date()
    }
    
    func isDateOrderValid(startDate: Date?, endDate: Date?) -> Bool {
        return Calendar.current.compare(startDate ?? Date(), to: endDate ?? Date(), toGranularity: .day) == .orderedAscending ||
            Calendar.current.compare(startDate ?? Date(), to: endDate ?? Date(), toGranularity: .day) == .orderedSame
    }
}
