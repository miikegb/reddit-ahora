//
//  RedditPostsRepository.swift
//  RedditClient
//
//  Created by Miguel Gonzalez on 3/26/24.
//

import Foundation
import Combine

typealias LinksPublisher = AnyPublisher<[Link], Error>
protocol PostsRepository {
    func getListing(for page: RedditPage) -> LinksPublisher
}

enum ThingExtractorError: Error {
    case unableToExtractThing
}

protocol ThingExtractor<Input, Output> {
    associatedtype Output
    associatedtype Input
    func callAsFunction(_ input: Input) throws -> Output
}

enum RedditPage: Codable, Identifiable, Hashable {
    case home
    case subreddit(name: String)
    
    var id: String {
        stringify
    }
    
    var title: String {
        switch self {
        case .home: "Home"
        case let .subreddit(name: name): "r/\(name)"
        }
    }
    
    var stringify: String {
        switch self {
        case .home: ""
        case let .subreddit(name: name): "/r/\(name)"
        }
    }
}

struct PostsExtractor: ThingExtractor {
    func callAsFunction(_ listing: Listing) -> [Link] {
        return listing.children.compactMap { thing in
            thing.associatedValue as? Link
        }
    }
}

final class RedditPostsRepository: PostsRepository {
    private let networkFetcher: Fetcher
    private var latestListings: [RedditPage: Listing] = [:]
    private var cancelBag = CancelBag()
    
    private var defaultRequestParams = [
        "raw_json": "1"
    ]
    
    init(fetcher: Fetcher) {
        self.networkFetcher = fetcher
    }
    
    private func listingPath(for page: RedditPage, sorting: SortResults = .best) -> String {
        "\(page.stringify)/\(sorting.path)"
    }
    
    private func listingParams(for page: RedditPage) -> [String: String] {
        let afterParams: [String: String]? = if let afterPost = latestListings[page]?.after {
            ["after": afterPost]
        } else { nil }
        
        return defaultRequestParams.merging(afterParams ?? [:]) { current, _ in current }
    }
    
    func getListing(for page: RedditPage) -> LinksPublisher {
        let resource = Resource(path: listingPath(for: page), params: listingParams(for: page), responseDecoder: .init(for: Listing.self))
        return getListing(resource: resource, extractor: PostsExtractor())
    }
    
    private func getListing<T>(resource: Resource<Listing>, extractor: some ThingExtractor<Listing, T>) -> AnyPublisher<T, Error> {
        networkFetcher.fetch(resource)
            .handleEvents(receiveOutput: { [weak self] listing in
                self?.latestListings[.home] = listing
            })
            .tryMap { try extractor($0) }
            .eraseToAnyPublisher()
    }
    
    private func getThing<T>(resource: Resource<Thing>, extractor: some ThingExtractor<Thing, T>) -> AnyPublisher<T, Error> {
        networkFetcher.fetch(resource)
            .tryMap { try extractor($0) }
            .eraseToAnyPublisher()
    }
}

#if DEBUG
struct PreviewPostsRepository: PostsRepository {
    private let sampleSubreddit: Thing = try! FixturesLoader.load(json: "PreviewAboutiOSSub")
    
    func getListing(for page: RedditPage) -> LinksPublisher {
        Just(SampleRedditPosts.previewPosts)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}
#endif
