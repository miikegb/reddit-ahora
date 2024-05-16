//
//  MockNetworkFetcher.swift
//  RedditClientTests
//
//  Created by Miguel Gonzalez on 5/16/24.
//

import Combine
@testable import RedditClient

final class MockNetworkFetcher: Fetcher, Mock {
    let recorder: MockRecorder<MockNetworkFetcher> = MockRecorder()
    
    func makeBuilder() -> Builder {
        Builder(recorder)
    }
    
    func makeVerifier() -> Verifier {
        Verifier(recorder)
    }
    
    func verifyExpectations(strict: Bool = true, file: StaticString = #file, line: UInt = #line) {
        recorder.verifyExpectations(strict: strict, file: file, line: line)
    }
    
    func fetch<T>(_ resource: Resource<T>) -> AnyPublisher<T, any Error> {
        let match: Matcher<Resource<T>> = .exact(resource)
        let interaction: Props = .fetch(resource: match.turnToGenericArgument())
        recorder.record(interaction: interaction)
        do {
            let returnResolver = StubResolver<MockNetworkFetcher, Resource<T>, AnyPublisher<T, any Error>>(recorder: recorder, mock: self)
            return try returnResolver.resolve(for: interaction) { $0(resource) }
        } catch {
            return recorder.resolveReturnValue(for: interaction)
        }
    }
    
    enum Props: Matcheable {
        case fetch(resource: Matcher<GenericArgument>)
        case testing(equ: Matcher<GenericArgument>)
        
        func matches(_ other: Props) -> Bool {
            switch (self, other) {
            case let (.fetch(resource: arg1), .fetch(resource: arg2)):
                arg1.matches(arg2)
            case let (.testing(equ: arg1), .testing(equ: arg2)):
                arg1.matches(arg2)
            default: false
            }
        }
    }
    
    struct Builder: MockBuilder {
        private let recorder: MockRecorder<MockNetworkFetcher>
        init(_ recorder: MockRecorder<MockNetworkFetcher>) {
            self.recorder = recorder
        }
        
        func fetch<T>(_ resource: Matcher<Resource<T>>) -> StubBuilder<Self, Resource<T>, AnyPublisher<T, any Error>> {
            .init(recorder: recorder, member: .fetch(resource: resource.turnToGenericArgument()))
        }
    }
    
    struct Verifier: MockVerifier {
        private let recorder: MockRecorder<MockNetworkFetcher>
        init(_ recorder: MockRecorder<MockNetworkFetcher>) {
            self.recorder = recorder
        }
        
        func fetch<T>(_ resource: Matcher<Resource<T>>) -> VerifierBuilder<Self> {
            .init(recorder: recorder, member: .fetch(resource: resource.turnToGenericArgument()))
        }
        
        func fetch(_ resource: Matcher<()>) -> VerifierBuilder<Self> {
            .init(recorder: recorder, member: .fetch(resource: .any))
        }
    }
}

