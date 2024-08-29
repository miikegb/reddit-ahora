//
//  MockPostCommentsRepository.swift
//  RedditClientTests
//
//  Created by Miguel Gonzalez on 6/3/24.
//

import Foundation
import Combine
import AppTestingUtils
import FeaturePosts
import Core

final class MockPostCommentsRepository: Mock, PostCommentsRepository {
    let recorder: MockRecorder<MockPostCommentsRepository> = MockRecorder()
    
    func makeBuilder() -> Builder {
        Builder(recorder)
    }
    
    func makeVerifier() -> Verifier {
        Verifier(recorder)
    }
    
    func verifyExpectations(strict: Bool = true, file: StaticString = #file, line: UInt = #line) {
        recorder.verifyExpectations(strict: strict, file: file, line: line)
    }
    
    func fetchComments(from post: Link) -> AnyPublisher<[Comment], Error> {
        let interaction: Props = .fetchComments(from: .exact(post))
        recorder.record(interaction: interaction)
        do {
            let returnResolver = StubResolver<MockPostCommentsRepository, Link, AnyPublisher<[Comment], Error>>(recorder: recorder, mock: self)
            return try returnResolver.resolve(for: interaction) { $0(post) }
        } catch {
            return recorder.resolveReturnValue(for: interaction)
        }
    }
    
    enum Props: Matcheable {
        case fetchComments(from: Matcher<Link>)
        
        func matches(_ other: Props) -> Bool {
            switch (self, other) {
            case let (.fetchComments(from: param1), .fetchComments(from: param2)):
                param1.matches(param2)
            }
        }
    }
    
    struct Builder: MockBuilder {
        private let recorder: MockRecorder<MockPostCommentsRepository>
        init(_ recorder: MockRecorder<MockPostCommentsRepository>) {
            self.recorder = recorder
        }
        
        func fetchComments(from post: Matcher<Link>) -> StubBuilder<Self, Link, AnyPublisher<[Comment], Error>> {
            .init(recorder: recorder, member: .fetchComments(from: post))
        }
    }
    
    struct Verifier: MockVerifier {
        private let recorder: MockRecorder<MockPostCommentsRepository>
        init(_ recorder: MockRecorder<MockPostCommentsRepository>) {
            self.recorder = recorder
        }
        
        func fetchComments(from post: Matcher<Link>) -> VerifierBuilder<Self> {
            .init(recorder: recorder, member: .fetchComments(from: post))
        }
    }
}
