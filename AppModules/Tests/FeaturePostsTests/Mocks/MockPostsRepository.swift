//
//  MockPostsRepository.swift
//  RedditClientTests
//
//  Created by Miguel Gonzalez on 4/5/24.
//

import Foundation
import Combine
import AppTestingUtils
import FeaturePosts

extension MockRecorder {
    func resolveReturnValue<ReturnValue>(for prop: Prop) -> AnyPublisher<ReturnValue, any Error> { PassthroughSubject<ReturnValue, Error>().eraseToAnyPublisher() }
}

final class MockPostsRepository: PostsRepository, Mock {
    let recorder: MockRecorder<MockPostsRepository> = MockRecorder()
    
    func makeBuilder() -> Builder {
        Builder(recorder)
    }
    
    func makeVerifier() -> Verifier {
        Verifier(recorder)
    }
    
    func verifyExpectations(strict: Bool = true, file: StaticString = #file, line: UInt = #line) {
        recorder.verifyExpectations(strict: strict, file: file, line: line)
    }
    
    func getListing(for page: RedditPage) -> LinksPublisher {
        let interaction: Props = .getListing(for: .exact(page))
        recorder.record(interaction: interaction)
        do {
            let returnResolver = StubResolver<MockPostsRepository, RedditPage, LinksPublisher>(recorder: recorder, mock: self)
            return try returnResolver.resolve(for: interaction) { $0(page) }
        } catch {
            return recorder.resolveReturnValue(for: interaction)
        }
    }
    
    // Step 1: Define protocol requirements in the Props enum
    enum Props: Matcheable {
        case getListing(for: Matcher<RedditPage>)
        
        func matches(_ other: Props) -> Bool {
            switch (self, other) {
            case let (.getListing(for: param1), .getListing(for: param2)): param1.matches(param2)
            }
        }
    }
    
    // Step 2: Define Builder to mirror the interface of the protocol with additional Parameter Matching capabilities
    struct Builder: MockBuilder {
        private let recorder: MockRecorder<MockPostsRepository>
        init(_ recorder: MockRecorder<MockPostsRepository>) {
            self.recorder = recorder
        }
        
        func getListing(for page: Matcher<RedditPage> = .any) -> StubBuilder<Self, RedditPage, LinksPublisher> {
            .init(recorder: recorder, member: .getListing(for: page))
        }
    }
    
    // Step 3: Define Verifier, similar to its peer Builder it mirrors the interface of the protocol
    struct Verifier: MockVerifier {
        private let recorder: MockRecorder<MockPostsRepository>
        init(_ recorder: MockRecorder<MockPostsRepository>) {
            self.recorder = recorder
        }
        
        func getListing(for page: Matcher<RedditPage> = .any) -> VerifierBuilder<Self> {
            .init(recorder: recorder, member: .getListing(for: page))
        }
    }
}
