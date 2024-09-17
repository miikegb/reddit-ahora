//
//  PostCommentsRepository.swift
//  RedditClient
//
//  Created by Miguel Gonzalez on 5/31/24.
//

import Foundation
import AppNetworking
import Core

public protocol PostCommentsRepository: Sendable {
    func fetchCommentsAsync(from post: Link) async throws -> [Comment]
}

public final class ProdPostCommentsRepository: PostCommentsRepository {
    private let networkFetcher: Fetcher
    
    public init(networkFetcher: Fetcher) {
        self.networkFetcher = networkFetcher
    }
    
    public func fetchCommentsAsync(from post: Link) async throws -> [Comment] {
        let resource = Resource(path: "\(post.permalink).json", responseDecoder: .init(for: [Listing].self))
        let extractor = CommentsExtractor()
        let thing = try await networkFetcher.asyncFech(resource)
        return extractor(thing.last)
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
    public func fetchCommentsAsync(from post: Link) async throws -> [Comment] {
        PreviewData.previewComments
    }
}
