//
//  TimestampFormatter.swift
//  RedditClient
//
//  Created by Miguel Gonzalez on 4/9/24.
//

import Foundation

struct TimestampFormatter {
    typealias Diffs = (year: Int, month: Int, day: Int, hour: Int, minute: Int, second: Int)
    var referenceDate: Date = .now

    // MARK: - Internal
    private static let calendar = Calendar.current
    private var cal: Calendar { Self.calendar }
    private let targetDateComponents: Set<Calendar.Component> = [.second, .minute, .hour, .day, .month, .year]
    private var lastDayOfPrevMonth: Int {
        let todayComps = cal.dateComponents(targetDateComponents, from: referenceDate)
        let firstDayOfThisMonthComps = DateComponents(calendar: cal, year: todayComps.year, month: todayComps.month, day: 1)
        let firstDayOfThisMonth = cal.date(from: firstDayOfThisMonthComps)!
        let prevMonth = cal.date(byAdding: .minute, value: -1, to: firstDayOfThisMonth)!
        let prevMonthComponents = cal.dateComponents([.day], from: prevMonth)
        return prevMonthComponents.day!
    }

    // MARK: - Human readable timestamp of a given date, using as a comparison point the `referenceDate`.
    func callAsFunction(from date: Date) -> String {
        let (yearDiff, monthDiff, dayDiff, hourDiff, minuteDiff, secondDiff) = getDiffs(from: date)
        
        if yearDiff > 0 {
            return process(component: monthDiff,
                           wrappingComponent: yearDiff,
                           lowerDescription: MonthDescriptor(value: 12 - abs(monthDiff)), 
                           upperDescription: YearDescriptor(value: yearDiff))
        }
        if monthDiff > 0 {
            return process(component: dayDiff, 
                           wrappingComponent: monthDiff,
                           lowerDescription: DaysDescriptor(value: lastDayOfPrevMonth - abs(dayDiff)),
                           upperDescription: MonthDescriptor(value: monthDiff))
        }
        if dayDiff > 0 {
            return process(component: hourDiff, 
                           wrappingComponent: dayDiff,
                           lowerDescription: HoursDescriptor(value: 24 - abs(hourDiff)),
                           upperDescription: DaysDescriptor(value: dayDiff))
        }
        if hourDiff > 0 {
            return process(component: minuteDiff,
                           wrappingComponent: hourDiff,
                           lowerDescription: MinsDescriptor(value: 60 - abs(minuteDiff)),
                           upperDescription: HoursDescriptor(value: hourDiff))
        }
        
        return switch (minuteDiff, secondDiff) {
        case (0, 1...59), (1, ..<0): SecsDescriptor().description()
        default: MinsDescriptor(value: minuteDiff).description()
        }
    }
    
    private func process(component: Int, wrappingComponent: Int, lowerDescription: @autoclosure () -> some TimeDiffDescriptor, upperDescription: @autoclosure () -> some TimeDiffDescriptor) -> String {
        switch component {
        case ..<0: lowerDescription().description()
        default: upperDescription().description()
        }
    }
    
    private func getDiffs(from date: Date) -> Diffs {
        let components = cal.dateComponents(targetDateComponents, from: date)
        let refComponents = cal.dateComponents(targetDateComponents, from: referenceDate)
        

        return (
            year: refComponents.year! - components.year!,
            month: refComponents.month! - components.month!,
            day: refComponents.day! - components.day!,
            hour: refComponents.hour! - components.hour!,
            minute: refComponents.minute! - components.minute!,
            second: refComponents.second! - components.second!
        )
    }
}

protocol TimeDiffDescriptor {
    var value: Int { get }
    static var single: String { get }
    static var plural: String { get }
}

extension TimeDiffDescriptor{
    func description() -> String {
        switch value {
        case 1: Self.single
        default: "\(value) \(Self.plural)"
        }
    }
}

struct YearDescriptor: TimeDiffDescriptor {
    static let single = "last year"
    static let plural = "years ago"
    var value: Int
}

struct MonthDescriptor: TimeDiffDescriptor {
    static let single = "last month"
    static let plural = "months ago"
    var value: Int
}

struct DaysDescriptor: TimeDiffDescriptor {
    static let single = "yesterday"
    static let plural = "days ago"
    var value: Int
}

struct HoursDescriptor: TimeDiffDescriptor {
    static let single = "1 hr ago"
    static let plural = "hrs ago"
    var value: Int
}

struct MinsDescriptor: TimeDiffDescriptor {
    static let single = "1 min ago"
    static let plural = "mins ago"
    var value: Int
}

struct SecsDescriptor: TimeDiffDescriptor {
    static let single = "now"
    static let plural = "now"
    var value = 1
    
    func description() -> String { Self.single }
}
