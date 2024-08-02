//
//  SubredditRepository.swift
//  RedditClient
//
//  Created by Miguel Gonzalez on 5/28/24.
//

import Combine
import AppNetworking

protocol SubredditRepository {
    func fetchSubredditAbout(_ sub: String) -> AnyPublisher<Subreddit, Error>
    subscript(sub: String) -> Subreddit? { get }
}

final class ProdSubredditRepository: SubredditRepository {
    private var networkFetcher: Fetcher
    private var subredditDetails: [String: Subreddit] = [:]
    
    init(networkFetcher: Fetcher) {
        self.networkFetcher = networkFetcher
    }
    
    subscript(sub: String) -> Subreddit? {
        subredditDetails[sub]
    }
    
    func fetchSubredditAbout(_ sub: String) -> AnyPublisher<Subreddit, Error> {
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

struct PreviewSubredditRepository: SubredditRepository {
    func fetchSubredditAbout(_ sub: String) -> AnyPublisher<Subreddit, any Error> {
        let subreddit: Thing = try! FixturesLoader.load(json: "PreviewAboutiOSSub")
        let extractor = SubredditExtractor()
        return Just(try! extractor(subreddit))
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    subscript(sub: String) -> Subreddit? {
        nil
    }
}
