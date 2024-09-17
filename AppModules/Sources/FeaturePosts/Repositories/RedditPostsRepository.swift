//
//  RedditPostsRepository.swift
//  RedditClient
//
//  Created by Miguel Gonzalez on 3/26/24.
//

import Foundation
import AppNetworking
import Core

public protocol PostsRepository: Sendable {
    func getListingAsync(for page: RedditPage) async throws -> [Link]
}

enum ThingExtractorError: Error {
    case unableToExtractThing
}

protocol ThingExtractor<Input, Output> {
    associatedtype Output
    associatedtype Input
    func callAsFunction(_ input: Input) throws -> Output
}

public enum RedditPage: Codable, Identifiable, Hashable, Sendable {
    case home
    case subreddit(name: String)
    
    public var id: String {
        stringify
    }
    
    public var title: String {
        switch self {
        case .home: "Home"
        case let .subreddit(name: name): "r/\(name)"
        }
    }
    
    public var stringify: String {
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

public final class RedditPostsRepository: PostsRepository, Sendable {
    private let networkFetcher: Fetcher
    private let listingsCache: InMemoryCache<RedditPage, Listing>
    
    private let defaultRequestParams = [
        "raw_json": "1"
    ]
    
    public init(fetcher: Fetcher) {
        self.networkFetcher = fetcher
        self.listingsCache = InMemoryCache()
    }
    
    private func listingPath(for page: RedditPage, sorting: SortResults = .best) -> String {
        "\(page.stringify)/\(sorting.path)"
    }
    
    private func listingParams(for page: RedditPage) async -> [String: String] {
        let afterParams: [String: String]? = if let afterPost = await listingsCache[page]?.after {
            ["after": afterPost]
        } else { nil }
        
        return defaultRequestParams.merging(afterParams ?? [:]) { current, _ in current }
    }
    
    public func getListingAsync(for page: RedditPage) async throws -> [Link] {
        let resource = Resource(path: listingPath(for: page), params: await listingParams(for: page), responseDecoder: .init(for: Listing.self))
        let listing = try await networkFetcher.asyncFech(resource)
        await listingsCache.set(listing, for: page)
        let extractor = PostsExtractor()
        return extractor(listing)
    }
}

//#if DEBUG
public struct PreviewPostsRepository: PostsRepository {
    private let sampleSubreddit: Thing = FixtureFinder.previewAboutiOSSub
    
    public func getListingAsync(for page: RedditPage) async throws -> [Link] {
        PreviewData.previewPosts
    }
}
//#endif
