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

    // MARK: - Human readable timestamp of a given date, using as a comparison point the `referenceDate`.
    func callAsFunction(from date: Date) -> String {
        getDiffDescriptor(from: date).description()
    }
    
    private func getDiffDescriptor(from date: Date) -> any TimeDiffDescriptor {
        let diffs = getDiffs(from: date)
        return switch diffs {
        case (1..., _, _, _, _, _): YearDescriptor(value: diffs.year)
        case (_, 1..., _, _, _, _): MonthDescriptor(value: diffs.month)
        case (_, _, 1..., _, _, _): DaysDescriptor(value: diffs.day)
        case (_, _, _, 1..., _, _): HoursDescriptor(value: diffs.hour)
        case (_, _, _, _, 1..., _): MinsDescriptor(value: diffs.minute)
        default:                    SecsDescriptor()
        }
    }
    
    private func getDiffs(from date: Date) -> Diffs {
        let diffComponents = Self.calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date, to: referenceDate)
        return (
            year: diffComponents.year!,
            month: diffComponents.month!,
            day: diffComponents.day!,
            hour: diffComponents.hour!,
            minute: diffComponents.minute!,
            second: diffComponents.second!
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
    var value: Int { 1 }
}
