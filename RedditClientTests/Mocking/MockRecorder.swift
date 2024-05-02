//
//  MockRecorder.swift
//  RedditClientTests
//
//  Created by Miguel Gonzalez on 4/4/24.
//

import Foundation
import XCTest

final class MockRecorder<T: Mock> {
    typealias Prop = T.Props
    
    private var returns: [IdentifiableProp<Prop>: ReturnKind<Any>] = [:]
    private var interactions: [Prop] = []
    private var expectations: [MockExpectation<Prop>] = []
    
    deinit {
        verifyExpectations()
    }
    
    func record(interaction: Prop) {
        interactions.append(interaction)
    }
    
    func `return`<ReturnType>(_ type: ReturnType, for prop: Prop) {
        returns[IdentifiableProp(prop: prop)] = .value(type)
    }
    
    func `return`<Arguments, ReturnType>(_ closure: @escaping (Arguments) -> ReturnType, for prop: Prop) {
        returns[IdentifiableProp(prop: prop)] = .closure(closure)
    }
    
    func add(expectation: ExpectationRecurrence, for prop: Prop) {
        expectations.append(MockExpectation(prop: prop, ocurrence: expectation))
    }
    
    func resolveReturnValue<ReturnType>(for member: Prop, closureResolver: (Any) throws -> ReturnType) throws -> ReturnType {
        guard let matchedKey = returns.keys.filter({ $0.prop.matches(member) }).first,
              let value = returns[matchedKey]
        else {
            throw ResolveError.notFound
        }
        
        let noTypeValue = switch value {
        case let .value(value): value
        case let .closure(closure): try closureResolver(closure)
        }
        guard let typedValue = noTypeValue as? ReturnType else {
            throw ResolveError.signatureMismatch
        }
        return typedValue
    }
    
    func verifyExpectations(strict: Bool = true, file: StaticString = #file, line: UInt = #line) {
        // TODO: Implement a non-strict verifier.
        StrictVerifier().verify(expectations: &expectations, interactions: &interactions, file: file, line: line)
    }
    
    struct AssertionFailure {
        let description: String
        let expected: Prop
        let actual: Prop? = nil
    }
    
    struct StrictVerifier {
        func verify(expectations: inout [MockExpectation<Prop>], interactions: inout [Prop], file: StaticString = #file, line: UInt = #line) {
            var failures = [AssertionFailure]()
            while let expectation = expectations.popLast() {
                let prop = expectation.prop
                let matchedInteractions = interactions.enumerated().filter { $0.element.matches(prop) }
                
                if matchedInteractions.isEmpty {
                    failures.append(
                        AssertionFailure(
                            description: "Expected to record mock interaction, but none were recorded. Expectation: {\n\(deepDescription(of: prop))\n}",
                            expected: prop
                        )
                    )
                } else {
                    verifyOccurrence(of: expectation, matchedInteractions: matchedInteractions.map(\.element), failures: &failures)
                }
                
                interactions.remove(atOffsets: IndexSet(matchedInteractions.map(\.offset)))
            }
            
            XCTAssert(failures.isEmpty, failures.map(\.description).joined(separator: "\n"), file: file, line: line)
        }
        
        private func verifyOccurrence(of expectation: MockExpectation<Prop>, matchedInteractions: [Prop], failures: inout [AssertionFailure]) {
            let prop = expectation.prop
            let ocurrence = expectation.ocurrence
            let propName = String(describing: prop)
            switch ocurrence {
            case .none:
                if matchedInteractions.count != 0 {
                    let message = ocurrence.failureMessage(for: propName)
                    failures.append(
                        AssertionFailure(description: message, expected: prop)
                    )
                }
            case .once:
                if matchedInteractions.count != 1 {
                    let message = ocurrence.failureMessage(for: propName) + """
                Mock verification failed:
                Expected:
                    \(deepDescription(of: prop))
                Matched:
                    \(deepDescription(of: matchedInteractions))
                """
                    failures.append(
                        AssertionFailure(description: message, expected: prop)
                    )
                }
            case .atLeastOnce:
                XCTAssert(matchedInteractions.count >= 1, "Expected \(String(describing: prop)) to be called at least once, but was called \(matchedInteractions.count) times")
            case .count(let times):
                XCTAssert(matchedInteractions.count == times, "Expected \(String(describing: prop)) to be called \(times) times, but was called \(matchedInteractions.count) times")
            }
        }
    }
}

extension MockRecorder {
    func resolveReturnValue<ReturnValue>(for prop: Prop) -> ReturnValue where ReturnValue: ExpressibleByStringLiteral { "" }
    func resolveReturnValue<ReturnValue>(for prop: Prop) -> ReturnValue where ReturnValue: ExpressibleByIntegerLiteral { 0 }
    func resolveReturnValue<ReturnValue>(for prop: Prop) -> ReturnValue where ReturnValue: ExpressibleByNilLiteral { nil }
    func resolveReturnValue<ReturnValue>(for prop: Prop) -> ReturnValue where ReturnValue: ExpressibleByArrayLiteral { [] }
    func resolveReturnValue<ReturnValue>(for prop: Prop) -> ReturnValue where ReturnValue: ExpressibleByDictionaryLiteral { [:] }
}

func unexpectedCall<T: Mock>(to mock: T, on: T.Props, file: StaticString = #file, line: UInt = #line) -> Never {
    fatalError("Unexpected call to mock: \(String(describing: mock))", file: file, line: line)
}
