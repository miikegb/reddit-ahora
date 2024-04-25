//
//  TimestampFormatterTests.swift
//  RedditClientTests
//
//  Created by Miguel Gonzalez on 4/10/24.
//

import XCTest
@testable import RedditClient

final class TimestampTests: XCTestCase {
    
    private func dateByAdding(_ components: KeyValuePairs<Calendar.Component, Int>, to date: Date) -> Date {
        guard !components.isEmpty else { return date }
        var result = date
        for kv in components {
            result = Calendar.current.date(byAdding: kv.key, value: kv.value, to: result)!
        }
        return result
    }
    
    func test_human_readable_logic_for_timestamp() {
        // Given
        let now = Date.now
        let timestamp = TimestampFormatter(referenceDate: now)
        
        // Then
        // Check "now"
        for secs in 1...59 {
            XCTAssertEqual(timestamp(from: dateByAdding([.second: secs * -1], to: now)), "now")
        }
        
        // Check mins
        for mins in 1...59 {
            let minsAgo = dateByAdding([.minute: mins * -1], to: now)
            if mins == 1 {
                XCTAssertEqual(timestamp(from: minsAgo), "\(mins) min ago")
            } else {
                XCTAssertEqual(timestamp(from: minsAgo), "\(mins) mins ago")
            }
        }
        
        // Check hours
        for hrs in 1...23 {
            let hrsAgo = dateByAdding([.hour: hrs * -1], to: now)
            if hrs == 1 {
                XCTAssertEqual(timestamp(from: hrsAgo), "\(hrs) hr ago")
            } else {
                XCTAssertEqual(timestamp(from: hrsAgo), "\(hrs) hrs ago")
            }
        }
        
        // Check for days
        for days in 1...28 {
            let daysAgo = dateByAdding([.day: days * -1], to: now)
            if days == 1 {
                XCTAssertEqual(timestamp(from: daysAgo), "yesterday")
            } else {
                XCTAssertEqual(timestamp(from: daysAgo), "\(days) days ago")
            }
        }

        // Check for months
        for months in 1..<12 {
            let monthsAgo = dateByAdding([.month: months * -1], to: now)
            if months == 1 {
                XCTAssertEqual(timestamp(from: monthsAgo), "last month")
            } else {
                XCTAssertEqual(timestamp(from: monthsAgo), "\(months) months ago")
            }
        }

        // Check for years
        for years in 1..<99 {
            let yearsAgo = dateByAdding([.year: years * -1], to: now)
            if years == 1 {
                XCTAssertEqual(timestamp(from: yearsAgo), "last year")
            } else {
                XCTAssertEqual(timestamp(from: yearsAgo), "\(years) years ago")
            }
        }
    }
}

