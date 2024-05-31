//
//  MockSubredditRepository.swift
//  RedditClientTests
//
//  Created by Miguel Gonzalez on 5/30/24.
//

import Foundation
import Combine
@testable import RedditClient

final class MockSubredditRepository: Mock, SubredditRepository {
    let recorder: MockRecorder<MockSubredditRepository> = MockRecorder()

    func makeBuilder() -> Builder {
        Builder(recorder)
    }
    
    func makeVerifier() -> Verifier {
        Verifier(recorder)
    }
    
    func verifyExpectations(strict: Bool = true, file: StaticString = #file, line: UInt = #line) {
        recorder.verifyExpectations(strict: strict, file: file, line: line)
    }
    
    subscript(sub: String) -> Subreddit? {
        let interaction: Props = .subscript(sub: .exact(sub))
        recorder.record(interaction: interaction)
        do {
            let returnResolver = StubResolver<MockSubredditRepository, String, Subreddit?>(recorder: recorder, mock: self)
            return try returnResolver.resolve(for: interaction) { $0(sub) }
        } catch {
            return recorder.resolveReturnValue(for: interaction)
        }
    }
    
    func fetchSubredditAbout(_ sub: String) -> AnyPublisher<Subreddit, any Error> {
        let interaction: Props = .fetchSubredditAbout(.exact(sub))
        recorder.record(interaction: interaction)
        do {
            let returnResolver = StubResolver<MockSubredditRepository, String, AnyPublisher<Subreddit, Error>>(recorder: recorder, mock: self)
            return try returnResolver.resolve(for: interaction) { $0(sub) }
        } catch {
            return recorder.resolveReturnValue(for: interaction)
        }
    }
    
    enum Props: Matcheable {
        case fetchSubredditAbout(Matcher<String>)
        case `subscript`(sub: Matcher<String>)
        
        func matches(_ other: Props) -> Bool {
            switch (self, other) {
            case let (.fetchSubredditAbout(param1), .fetchSubredditAbout(param2)):
                param1.matches(param2)
            case let (.subscript(sub: param1), .subscript(sub: param2)):
                param1.matches(param2)
            default: false
            }
        }
    }
    
    struct Builder: MockBuilder {
        private let recorder: MockRecorder<MockSubredditRepository>
        init(_ recorder: MockRecorder<MockSubredditRepository>) {
            self.recorder = recorder
        }
        
        func fetchSubredditAbout(_ sub: Matcher<String>) -> StubBuilder<Self, String, AnyPublisher<Subreddit, Error>> {
            .init(recorder: recorder, member: .fetchSubredditAbout(sub))
        }
        
        func `subscript`(sub: Matcher<String>) -> StubBuilder<Self, String, Subreddit?> {
            .init(recorder: recorder, member: .subscript(sub: sub))
        }
    }
    
    struct Verifier: MockVerifier {
        private let recorder: MockRecorder<MockSubredditRepository>
        init(_ recorder: MockRecorder<MockSubredditRepository>) {
            self.recorder = recorder
        }
        
        func fetchSubredditAbout(_ sub: Matcher<String>) -> VerifierBuilder<Self> {
            .init(recorder: recorder, member: .fetchSubredditAbout(sub))
        }
        
        func `subscript`(sub: Matcher<String>) -> VerifierBuilder<Self> {
            .init(recorder: recorder, member: .subscript(sub: sub))
        }
    }
}
