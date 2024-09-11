//
//  SubredditRepository.swift
//  RedditClient
//
//  Created by Miguel Gonzalez on 5/28/24.
//

import Combine
import AppNetworking
import Core

public protocol SubredditRepository {
    func fetchAboutSubreddit(_ sub: String) async throws -> Subreddit
    func fetchSubredditAbout(_ sub: String) -> AnyPublisher<Subreddit, Error>
    subscript(sub: String) -> Subreddit? { get }
}

public final class ProdSubredditRepository: SubredditRepository {
    private var networkFetcher: Fetcher
    private var subredditDetails: [String: Subreddit] = [:]
    
    public init(networkFetcher: Fetcher) {
        self.networkFetcher = networkFetcher
    }
    
    public subscript(sub: String) -> Subreddit? {
        subredditDetails[sub]
    }
    
    public func fetchSubredditAbout(_ sub: String) -> AnyPublisher<Subreddit, Error> {
        if let subreddit = self[sub] {
            return Just(subreddit)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        let resource = Resource(path: "r/\(sub)/about.json", responseDecoder: .init(for: Thing.self))
        return getThing(resource: resource, extractor: SubredditExtractor())
            .handleEvents(receiveOutput: { [weak self] subreddit in
                self?.subredditDetails[sub] = subreddit
            })
            .eraseToAnyPublisher()
    }
    
    public func fetchAboutSubreddit(_ sub: String) async throws -> Subreddit {
        if let subreddit = self[sub] {
            return subreddit
        }
        let resource = Resource(path: "r/\(sub)/about.json", responseDecoder: .init(for: Thing.self))
        let thing = try await networkFetcher.asyncFech(resource)
        let extractor = SubredditExtractor()
        let subreddit = try extractor(thing)
        subredditDetails[sub] = subreddit
        return subreddit
    }
    
    private func getThing<T>(resource: Resource<Thing>, extractor: some ThingExtractor<Thing, T>) -> AnyPublisher<T, Error> {
        networkFetcher.fetch(resource)
            .tryMap { try extractor($0) }
            .eraseToAnyPublisher()
    }
}

struct SubredditExtractor: ThingExtractor {
    func callAsFunction(_ input: Thing) throws -> Subreddit {
        if let subreddit = input.associatedValue as? Subreddit {
            subreddit
        } else {
            throw ThingExtractorError.unableToExtractThing
        }
    }
}

public struct PreviewSubredditRepository: SubredditRepository {
    public func fetchSubredditAbout(_ sub: String) -> AnyPublisher<Subreddit, any Error> {
        let subreddit: Thing = FixtureFinder.previewAboutiOSSub
        let extractor = SubredditExtractor()
        return Just(try! extractor(subreddit))
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    public subscript(sub: String) -> Subreddit? {
        nil
    }
    
    public func fetchAboutSubreddit(_ sub: String) async throws -> Subreddit {
        let subreddit: Thing = FixtureFinder.previewAboutiOSSub
        let extractor = SubredditExtractor()
        return try! extractor(subreddit)
    }
}
