//
//  Date+Utils.swift
//  Anemone SDK
//
//  Created by Angel Garcia on 12/01/2017.
//  Copyright © 2017 Syltek Solutions S.L. All rights reserved.
//

import Foundation

public extension Date {

    public static func from(day: Date, time: Date, timeZone: TimeZone? = nil) -> Date {
        let calendar = NSCalendar.current
        let timeComponents = calendar.dateComponents(in: timeZone ?? .current, from: time)
        var dateComponents = calendar.dateComponents(in: timeZone ?? .current, from: day)

        dateComponents.setValue(timeComponents.hour, for: .hour)
        dateComponents.setValue(timeComponents.minute, for: .minute)
        dateComponents.setValue(timeComponents.second, for: .second)
        dateComponents.setValue(0, for: .nanosecond)

        let date: Date! = calendar.date(from: dateComponents)
        return date
    }

    public static func today(timeZone: TimeZone? = nil) -> Date {
        return Date().midnight(timeZone: timeZone)
    }

    public static func tomorrow(timeZone: TimeZone? = nil) -> Date {
        return today(timeZone: timeZone).add(days: 1)
    }

    public static func yesterday(timeZone: TimeZone? = nil) -> Date {
        return today(timeZone: timeZone).add(days: -1)
    }

    public func midnight(timeZone: TimeZone? = nil) -> Date {
        var calendar = NSCalendar.current
        calendar.timeZone = timeZone ?? .current
        let midnightComponents = calendar.dateComponents([.year, .month, .day, .timeZone], from: self)
        let date: Date! = calendar.date(from: midnightComponents)
        return date
    }

    public func add(hours: Int) -> Date {
        let calendar = NSCalendar.current
        let date: Date! = calendar.date(byAdding: .hour, value: hours, to: self)
        return date
    }

    public func add(minutes: Int) -> Date {
        let calendar = NSCalendar.current
        let date: Date! = calendar.date(byAdding: .minute, value: minutes, to: self)
        return date
    }

    public func add(days: Int) -> Date {
        let calendar = NSCalendar.current
        let date: Date! = calendar.date(byAdding: .day, value: days, to: self)

        return date
    }

    public func isToday(timeZone: TimeZone? = nil) -> Bool {
        return isSameDay(day: Date.today(timeZone: timeZone), timeZone: timeZone)
    }

    public func isTomorrow(timeZone: TimeZone? = nil) -> Bool {
        return isSameDay(day: Date.tomorrow(timeZone: timeZone), timeZone: timeZone)
    }

    public func isSameDay(day: Date, timeZone: TimeZone? = nil) -> Bool {
        var calendar = Calendar.current
        calendar.timeZone = timeZone ?? .current
        let dayComponents = calendar.dateComponents([.day, .month, .year], from: day)
        let selfComponents = calendar.dateComponents([.day, .month, .year], from: self)
        return dayComponents == selfComponents
    }

    public func dateByAddingTimeZoneOffset(_ timeZone: TimeZone) -> Date {
        return self.addingTimeInterval(-TimeInterval(timeZone.secondsFromGMT(for: self)))
    }

    public func dateByRemovingTimeZoneOffset(_ timeZone: TimeZone) -> Date {
        return self.addingTimeInterval(TimeInterval(timeZone.secondsFromGMT(for: self)))
    }

    public func days(to: Date) -> Int {
        return Calendar.current.dateComponents([.day], from: self, to: to).day ?? 0
    }

    public func hours(to: Date) -> Int {
        return Calendar.current.dateComponents([.hour], from: self, to: to).hour ?? 0
    }

    public func minutes(to: Date) -> Int {
        return Calendar.current.dateComponents([.minute], from: self, to: to).minute ?? 0
    }

    public func isFuture() -> Bool {
        return self.timeIntervalSinceNow > 0
    }

    public func isPast() -> Bool {
        return self.timeIntervalSinceNow < 0
    }

    public func dayOfYear(timeZone: TimeZone? = nil) -> Int {
        var calendar = Calendar.current
        calendar.timeZone = timeZone ?? .current
        return calendar.ordinality(of: .day, in: .year, for: self) ?? 0
    }

    public func minutes(timeZone: TimeZone? = nil) -> Int {
        var calendar = Calendar.current
        calendar.timeZone = timeZone ?? .current
        return calendar.component(.minute, from: self)
    }
}
