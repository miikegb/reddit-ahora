//
//  RedditPostsRepository.swift
//  RedditClient
//
//  Created by Miguel Gonzalez on 3/26/24.
//

import Foundation
import Combine

protocol PostsRepository {
    func getPosts(for subreddit: String) -> AnyPublisher<[Link], Error>
    func getHomePosts() -> AnyPublisher<[Link], Error>
}

protocol ThingExtractor<Thing> {
    associatedtype Thing
    func callAsFunction(_ listing: Listing) -> Thing
}

struct PostsExtractor: ThingExtractor {
    func callAsFunction(_ listing: Listing) -> [Link] {
        return listing.children.compactMap { thing in
            if case let .link(link) = thing { link } else { nil }
        }
    }
}

struct RedditPostsRepository: PostsRepository {
    private let networkFetcher: Fetcher
    
    init(fetcher: Fetcher) {
        self.networkFetcher = fetcher
    }
    
    func getHomePosts() -> AnyPublisher<[Link], Error> {
        let resource = Resource(path: "", sort: .best, responseDecoder: .init(for: Listing.self))
        return get(resource: resource, extractor: PostsExtractor())
    }
    
    func getPosts(for subreddit: String) -> AnyPublisher<[Link], Error> {
        let resource = Resource(path: "/r/\(subreddit)", responseDecoder: .init(for: Listing.self))
        return get(resource: resource, extractor: PostsExtractor())
    }
    
    private func get<T>(resource: Resource<Listing>, extractor: some ThingExtractor<T>) -> AnyPublisher<T, Error> {
        return networkFetcher.fetch(resource)
            .map { extractor($0) }
            .eraseToAnyPublisher()
    }
}

#if DEBUG
struct PreviewPostsRepository: PostsRepository {
    func getPosts(for subreddit: String) -> AnyPublisher<[Link], any Error> {
        getPreviewPosts()
    }
    
    func getHomePosts() -> AnyPublisher<[Link], any Error> {
        getPreviewPosts()
    }
    
    private func getPreviewPosts() -> AnyPublisher<[Link], any Error> {
        Just(SampleRedditPosts.previewPosts)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}
#endif
