//
//  PostCommentsRepository.swift
//  RedditClient
//
//  Created by Miguel Gonzalez on 5/31/24.
//

import Foundation
import Combine
import AppNetworking
import Core

public protocol PostCommentsRepository {
    func fetchComments(from post: Link) -> AnyPublisher<[Comment], Error>
}

public final class ProdPostCommentsRepository: PostCommentsRepository {
    private var networkFetcher: Fetcher
    
    public init(networkFetcher: Fetcher) {
        self.networkFetcher = networkFetcher
    }
    
    public func fetchComments(from post: Link) -> AnyPublisher<[Comment], Error> {
        let resource = Resource(path: "\(post.permalink).json", responseDecoder: .init(for: [Listing].self))
        let extractor = CommentsExtractor()
        return networkFetcher.fetch(resource)
            .map {
                extractor($0.last)
            }
            .eraseToAnyPublisher()
    }
}

struct CommentsExtractor {
    func callAsFunction(_ listing: Listing?) -> [Comment] {
        guard let listing else { return [] }
        return listing.children.compactMap {
            $0.associatedValue as? Comment
        }
    }
}

public struct PreviewPostCommentsRepository: PostCommentsRepository {
    public func fetchComments(from post: Link) -> AnyPublisher<[Comment], Error> {
        Just(PreviewData.previewComments).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
}
