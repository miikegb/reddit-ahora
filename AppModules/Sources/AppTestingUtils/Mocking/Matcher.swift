//
//  Matcher.swift
//  RedditClientTests
//
//  Created by Miguel Gonzalez on 5/1/24.
//

import Foundation

typealias MockComparatorKey<T> = (T, T) -> Bool

// A type used to register Comparator functions for types that don't conform to the `Equatable` protocol
struct MockerTypeComparators {
    nonisolated(unsafe) private static var other: [ObjectIdentifier: Any] = [:]
    
    static subscript<K>(key: K.Type) -> MockComparatorKey<K>? {
        get { other[ObjectIdentifier(key)] as? MockComparatorKey<K> }
        set { other[ObjectIdentifier(key)] = newValue }
    }
}

public enum Matcher<T> {
    case any
    case exact(T)
}

extension Matcher: Equatable where T: Equatable {
    public static func ==(lhs: Matcher<T>, rhs: Matcher<T>) -> Bool {
        switch (lhs, rhs) {
        case (.any, .any): true
        case let (.exact(lhsValue), .exact(rhsValue)): lhsValue == rhsValue
        default: false
        }
    }
}

extension Matcher: Matcheable {
    public func matches(_ other: Matcher<T>) -> Bool {
        switch (self, other) {
        case (.any, _), (_, .any): return true
        case let (.exact(arg1), .exact(arg2)):
            guard let comparator = MockerTypeComparators[T.self] else { return false }
            return comparator(arg1, arg2)
        }
    }
}

extension Matcher where T: Equatable {
    func matches(_ other: Matcher<T>) -> Bool {
        switch (self, other) {
        case (.any, _), (_, .any): true
        case let (.exact(arg1), .exact(arg2)):
            arg1 == arg2
        }
    }
}

extension Matcher where T == GenericArgument {
    func matches(_ other: Matcher<T>) -> Bool {
        switch (self, other) {
        case (.any, _), (_, .any): true
        case let (.exact(arg1), .exact(arg2)):
            arg1.comparator(arg2)
        }
    }
}

extension Matcher {
    public func turnToGenericArgument() -> Matcher<GenericArgument> {
        switch self {
        case .any: .any
        case let .exact(arg): .exact(GenericArgument(argument: arg, comparator: GenericComparator(compare: { _ in
            fatalError("Please ensure the parameters for your mocks are Equatable if you need to use the `.exact` matcher")
        })))
        }
    }
}

extension Matcher where T: Equatable {
    func turnToGenericArgument() -> Matcher<GenericArgument> {
        switch self {
        case .any: .any
        case let .exact(arg): .exact(.genericEquatable(arg))
        }
    }
}

// A type-erasing type to allow us to work with Generic arguments
public struct GenericArgument {
    var argument: Any
    var comparator: GenericComparator
}

extension GenericArgument {
    static func genericEquatable<T>(_ argument: T) -> GenericArgument where T: Equatable {
        GenericArgument(argument: argument, comparator: GenericComparator(for: argument))
    }
}

struct GenericComparator {
    var compare: (GenericArgument) -> Bool
    func callAsFunction(_ other: GenericArgument) -> Bool {
        compare(other)
    }
}

extension GenericComparator {
    init<T>(for baseArg: T) where T: Equatable {
        compare = { arg in
            guard let otherArg = arg.argument as? T else { return false }
            return baseArg == otherArg
        }
    }
}
