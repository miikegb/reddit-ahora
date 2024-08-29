//
//  MockRedditorRepository.swift
//  RedditClientTests
//
//  Created by Miguel Gonzalez on 6/4/24.
//

import Foundation
import Combine
import AppTestingUtils
import FeaturePosts
import Core

final class MockRedditorRepository: Mock, RedditorRepository {
    let recorder: MockRecorder<MockRedditorRepository> = MockRecorder()
    
    func makeBuilder() -> Builder {
        Builder(recorder)
    }
    
    func makeVerifier() -> Verifier {
        Verifier(recorder)
    }
    
    func verifyExpectations(strict: Bool = true, file: StaticString = #file, line: UInt = #line) {
        recorder.verifyExpectations(strict: strict, file: file, line: line)
    }
    
    func fetchRedditorDetails(for redditorId: String) -> AnyPublisher<Redditor, Error> {
        let interaction: Props = .fetchRedditorDetails(for: .exact(redditorId))
        recorder.record(interaction: interaction)
        do {
            let returnResolver = StubResolver<MockRedditorRepository, String, AnyPublisher<Redditor, Error>>(recorder: recorder, mock: self)
            return try returnResolver.resolve(for: interaction) { $0(redditorId) }
        } catch {
            return recorder.resolveReturnValue(for: interaction)
        }
    }
    
    subscript(redditor: String) -> Redditor? {
        nil
    }
    
    enum Props: Matcheable {
        case fetchRedditorDetails(for: Matcher<String>)
        case `subscript`(redditorId: Matcher<String>)
        
        func matches(_ other: Props) -> Bool {
            switch (self, other) {
            case let (.fetchRedditorDetails(for: param1), .fetchRedditorDetails(for: param2)):
                param1.matches(param2)
            case let (.subscript(redditorId: param1), .subscript(redditorId: param2)):
                param1.matches(param2)
            default: false
            }
        }
    }
    
    struct Builder: MockBuilder {
        private let recorder: MockRecorder<MockRedditorRepository>
        init(_ recorder: MockRecorder<MockRedditorRepository>) {
            self.recorder = recorder
        }
        
        func fetchRedditorDetails(for redditorId: Matcher<String>) -> StubBuilder<Self, String, AnyPublisher<Redditor, Error>> {
            .init(recorder: recorder, member: .fetchRedditorDetails(for: redditorId))
        }
        
        func `subscript`(redditorId: Matcher<String>) -> StubBuilder<Self, String, Redditor?> {
            .init(recorder: recorder, member: .subscript(redditorId: redditorId))
        }
    }
    
    struct Verifier: MockVerifier {
        private let recorder: MockRecorder<MockRedditorRepository>
        init(_ recorder: MockRecorder<MockRedditorRepository>) {
            self.recorder = recorder
        }
        
        func fetchRedditorDetails(for redditorId: Matcher<String>) -> VerifierBuilder<Self> {
            .init(recorder: recorder, member: .fetchRedditorDetails(for: redditorId))
        }
        
        func `subscript`(redditorId: Matcher<String>) -> VerifierBuilder<Self> {
            .init(recorder: recorder, member: .subscript(redditorId: redditorId))
        }
    }
}
