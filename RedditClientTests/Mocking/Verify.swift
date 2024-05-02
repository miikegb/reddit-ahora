//
//  Verify.swift
//  RedditClientTests
//
//  Created by Miguel Gonzalez on 4/5/24.
//

import Foundation

struct MockExpectation<Prop: Matcheable> {
    var prop: Prop
    var ocurrence: ExpectationRecurrence
}

enum ExpectationRecurrence {
    case none, once, atLeastOnce, count(Int)
    
    func failureMessage(for propName: String) -> String {
        switch self {
        case .none: "Expected mock not to record any interactions with \(propName), but recorded at least one"
        case .once: "Expected mock to record any interactions with \(propName), but recorded at least one"
        case .atLeastOnce: "Expected mock not to record any interactions with \(propName), but recorded at least one"
        case .count: "Expected mock not to record any interactions with \(propName), but recorded at least one"
        }
    }
}

struct VerifierBuilder<SuperVerifier: MockVerifier> {
    typealias RecorderType = SuperVerifier.MockType
    typealias Member = SuperVerifier.MockType.Props
    
    var recorder: MockRecorder<RecorderType>
    var member: Member
    var assertion: ExpectationRecurrence
    init(recorder: MockRecorder<RecorderType>, member: Member, assertion: ExpectationRecurrence = .once) {
        self.recorder = recorder
        self.member = member
        self.assertion = assertion
    }
    
    @discardableResult
    func times(_ count: Int) -> SuperVerifier {
        recorder.add(expectation: .count(count), for: member)
        return .init(recorder)
    }
    
    @discardableResult
    func atLeastOnce() -> SuperVerifier {
        recorder.add(expectation: .atLeastOnce, for: member)
        return .init(recorder)
    }
    
    @discardableResult
    func once() -> SuperVerifier {
        recorder.add(expectation: .once, for: member)
        return .init(recorder)
    }
    
    @discardableResult
    func toBeCalled(_ recurrence: ExpectationRecurrence = .once) -> SuperVerifier {
        recorder.add(expectation: recurrence, for: member)
        return .init(recorder)
    }
    
    @discardableResult
    func notToBeCalled() -> SuperVerifier {
        recorder.add(expectation: .none, for: member)
        return .init(recorder)
    }
}
