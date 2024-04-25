//
//  RedditPostsRepository.swift
//  RedditClient
//
//  Created by Miguel Gonzalez on 3/26/24.
//

import Foundation
import Combine

enum PostsError: Error {
    case erasedError
}

protocol PostsRepository {
    func getPosts(for subreddit: String) -> AnyPublisher<[Link], Error>
}

struct RedditPostsRepository: PostsRepository {
    private let networkFetcher: Fetcher
    private let cancelBag = CancelBag()
    
    init(fetcher: Fetcher) {
        self.networkFetcher = fetcher
    }
    
    func getPosts(for subreddit: String) -> AnyPublisher<[Link], Error> {
        let resource = Resource(path: "/r/\(subreddit)", responseDecoder: ResponseDecoder(for: Listing.self))
        return networkFetcher.fetch(resource)
            .map { listing in
                return listing.children.compactMap { thing in
                    if case let .link(link) = thing { link } else { nil }
                }
            }
            .eraseToAnyPublisher()
    }
}

#if DEBUG
struct PreviewPostsRepository: PostsRepository {
    func getPosts(for subreddit: String) -> AnyPublisher<[Link], any Error> {
        Just(SampleRedditPosts.previewPosts)
            .mapError { _ in PostsError.erasedError }
            .eraseToAnyPublisher()
    }
}
#endif
