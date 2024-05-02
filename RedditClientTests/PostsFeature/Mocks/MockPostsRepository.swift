//
//  MockPostsRepository.swift
//  RedditClientTests
//
//  Created by Miguel Gonzalez on 4/5/24.
//

import Foundation
import Combine
@testable import RedditClient

extension MockRecorder {
    func resolveReturnValue<ReturnValue>(for prop: Prop) -> AnyPublisher<ReturnValue, any Error> { PassthroughSubject<ReturnValue, Error>().eraseToAnyPublisher() }
}

final class MockPostsRepository: PostsRepository, Mock {
    let recorder: MockRecorder<MockPostsRepository> = MockRecorder()
    
    func getPosts(for subreddit: String) -> AnyPublisher<[Link], any Error> {
        let interaction: Props = .getPosts(subreddit: .exact(subreddit))
        recorder.record(interaction: interaction)
        do {
            let returnResolver = StubResolver<MockPostsRepository, String, AnyPublisher<[Link], any Error>>(mock: self)
            return try returnResolver.resolve(for: interaction) { $0(subreddit) }
        } catch {
            return recorder.resolveReturnValue(for: interaction)
        }
    }
    
    func getHomePosts() -> AnyPublisher<[Link], any Error> {
        let interaction: Props = .getHomePosts
        recorder.record(interaction: interaction)
        do {
            let returnResolver = StubResolver<MockPostsRepository, Void, AnyPublisher<[Link], any Error>>(mock: self)
            return try returnResolver.resolve(for: interaction) { $0(()) }
        } catch {
            return recorder.resolveReturnValue(for: interaction)
        }
    }
    
    // Step 1: Define protocol requirements in the Props enum
    enum Props: Hashable, Matcheable {
        case getPosts(subreddit: ParameterMatch<String>)
        case getHomePosts
        
        func matches(_ other: Props) -> Bool {
            switch (self, other) {
            case let (.getPosts(subreddit: param1), .getPosts(subreddit: param2)): param1.matches(param2)
            case (.getHomePosts, .getHomePosts): true
            default: false
            }
        }
    }
    
    // Step 2: Define Builder to mirror the interface of the protocol with additional Parameter Matching capabilities
    struct Builder: MockBuilder {
        private let recorder: MockRecorder<MockPostsRepository>
        init(_ recorder: MockRecorder<MockPostsRepository>) {
            self.recorder = recorder
        }
        
        func getPosts(for subreddit: ParameterMatch<String> = .any) -> StubBuilder<Self, String, AnyPublisher<[Link], any Error>> {
            .init(recorder: recorder, member: .getPosts(subreddit: subreddit))
        }
        
        func getHomePosts() -> StubBuilder<Self, Void, AnyPublisher<[Link], any Error>> {
            .init(recorder: recorder, member: .getHomePosts)
        }
    }
    
    // Step 3: Define Verifier, similar to its peer Builder it mirrors the interface of the protocol
    struct Verifier: MockVerifier {
        private let recorder: MockRecorder<MockPostsRepository>
        init(_ recorder: MockRecorder<MockPostsRepository>) {
            self.recorder = recorder
        }
        
        func getPosts(for subreddit: ParameterMatch<String> = .any) -> VerifierBuilder<Self> {
            .init(recorder: recorder, member: .getPosts(subreddit: subreddit))
        }
        
        func getHomePosts() -> VerifierBuilder<Self> {
            .init(recorder: recorder, member: .getHomePosts)
        }
    }
}
