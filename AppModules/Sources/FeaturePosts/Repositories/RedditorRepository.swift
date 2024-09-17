//
//  RedditorRepository.swift
//  RedditClient
//
//  Created by Miguel Gonzalez on 5/31/24.
//

import Foundation
import AppNetworking
import Core

public protocol RedditorRepository: Sendable {
    func fetchDetails(for redditorId: String) async throws -> Redditor
    subscript(redditorId: String) -> Redditor? { get async }
}

public final class ProdRedditorRepository: RedditorRepository {
    private let networkFetcher: Fetcher
    private let cache: InMemoryCache<String, Redditor>
    
    public init(networkFetcher: Fetcher) {
        self.networkFetcher = networkFetcher
        self.cache = InMemoryCache()
    }
    
    public subscript(redditorId: String) -> Redditor? {
        get async {
            await cache[redditorId]
        }
    }
    
    public func fetchDetails(for redditorId: String) async throws -> Redditor {
        if let redditor = await cache[redditorId] {
            return redditor
        }
        let resource = Resource(path: "/user/\(redditorId)/about.json", responseDecoder: .init(for: Thing.self))
        let redditorExtractor = RedditorExtractor()
        let thing = try await networkFetcher.asyncFech(resource)
        return try redditorExtractor(thing)
    }
}

struct RedditorExtractor: ThingExtractor {
    func callAsFunction(_ input: Thing) throws -> Redditor {
        if let redditor = input.associatedValue as? Redditor {
            redditor
        } else {
            throw ThingExtractorError.unableToExtractThing
        }
    }
}

public struct PreviewRedditorRepository: RedditorRepository {
    private let previewRedditor = Redditor(id: "abc", name: "redditor", created: .now, iconImg: "", snoovatarImg: "", totalKarma: 1000, commentKarma: 1000, linkKarma: 1000)
    
    public func fetchDetails(for redditorId: String) async throws -> Redditor {
        previewRedditor
    }
    
    public subscript(redditor: String) -> Redditor? {
        previewRedditor
    }
}
