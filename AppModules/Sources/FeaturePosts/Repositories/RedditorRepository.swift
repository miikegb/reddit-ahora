//
//  RedditorRepository.swift
//  RedditClient
//
//  Created by Miguel Gonzalez on 5/31/24.
//

import Foundation
import Combine
import AppNetworking
import Core

public protocol RedditorRepository {
    func fetchRedditorDetails(for redditorId: String) -> AnyPublisher<Redditor, Error>
    subscript(redditorId: String) -> Redditor? { get }
}

public final class ProdRedditorRepository: RedditorRepository {
    private var networkFetcher: Fetcher
    private var redditorsCache: [String: Redditor] = [:]
    
    public init(networkFetcher: Fetcher) {
        self.networkFetcher = networkFetcher
    }
    
    public subscript(redditorId: String) -> Redditor? {
        redditorsCache[redditorId]
    }
    
    public func fetchRedditorDetails(for redditorId: String) -> AnyPublisher<Redditor, any Error> {
        if let redditor = redditorsCache[redditorId] {
            return Just(redditor)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        
        let resource = Resource(path: "/user/\(redditorId)/about.json", responseDecoder: .init(for: Thing.self))
        let redditorExtractor = RedditorExtractor()
        return networkFetcher.fetch(resource)
            .tryMap {
                try redditorExtractor($0)
            }
            .eraseToAnyPublisher()
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
    
    public func fetchRedditorDetails(for redditorId: String) -> AnyPublisher<Redditor, Error> {
        Just(previewRedditor)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    public subscript(redditor: String) -> Redditor? {
        previewRedditor
    }
}
