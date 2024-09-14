//
//  SubredditRepository.swift
//  RedditClient
//
//  Created by Miguel Gonzalez on 5/28/24.
//

import AppNetworking
import Core

public protocol SubredditRepository: Sendable {
    func fetchAboutSubreddit(_ sub: String) async throws -> Subreddit
    subscript(sub: String) -> Subreddit? { get async }
}

public final class ProdSubredditRepository: SubredditRepository, Sendable {
    private let networkFetcher: Fetcher
    private let cache: InMemoryCache<String, Subreddit>
    
    public init(networkFetcher: Fetcher) {
        self.networkFetcher = networkFetcher
        self.cache = InMemoryCache()
    }
    
    public subscript(sub: String) -> Subreddit? {
        get async {
            await cache[sub]
        }
    }
    
    public func fetchAboutSubreddit(_ sub: String) async throws -> Subreddit {
        if let subreddit = await cache[sub] {
            return subreddit
        }
        let resource = Resource(path: "r/\(sub)/about.json", responseDecoder: .init(for: Thing.self))
        let thing = try await networkFetcher.asyncFech(resource)
        let extractor = SubredditExtractor()
        let subreddit = try extractor(thing)
        await cache.set(subreddit, for: sub)
        return subreddit
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
    public subscript(sub: String) -> Subreddit? {
        nil
    }
    
    public func fetchAboutSubreddit(_ sub: String) async throws -> Subreddit {
        let subreddit: Thing = FixtureFinder.previewAboutiOSSub
        let extractor = SubredditExtractor()
        return try! extractor(subreddit)
    }
}
