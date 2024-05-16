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

protocol ThingExtractor<Thing> {
    associatedtype Thing
    func callAsFunction(_ listing: Listing) -> Thing
}

enum RedditPage: Hashable {
    case home
    case subreddit(name: String)
    
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
            if case let .link(link) = thing { link } else { nil }
        }
    }
}

final class RedditPostsRepository: PostsRepository {
    private let networkFetcher: Fetcher
    private var latestListings: [RedditPage: Listing] = [:]
    
    init(fetcher: Fetcher) {
        self.networkFetcher = fetcher
    }
    
    func getListing(for page: RedditPage) -> LinksPublisher {
        let params: [String: String]? = if let afterPost = latestListings[page]?.after {
            ["after": afterPost]
        } else { nil }
        
        let resource = Resource(path: page.stringify, sort: .best, responseDecoder: .init(for: Listing.self), params: params)
        return get(resource: resource, extractor: PostsExtractor())
    }
    
    private func get<T>(resource: Resource<Listing>, extractor: some ThingExtractor<T>) -> AnyPublisher<T, Error> {
        networkFetcher.fetch(resource)
            .handleEvents(receiveOutput: { [weak self] listing in
                self?.latestListings[.home] = listing
            })
            .eraseToAnyPublisher()
            .map { extractor($0) }
            .eraseToAnyPublisher()
    }
}

#if DEBUG
struct PreviewPostsRepository: PostsRepository {
    func getListing(for page: RedditPage) -> LinksPublisher {
        Just(SampleRedditPosts.previewPosts)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}
#endif
