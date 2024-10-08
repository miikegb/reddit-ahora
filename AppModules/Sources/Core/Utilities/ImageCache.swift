//
//  ImageCache.swift
//  RedditClient
//
//  Created by Miguel Gonzalez on 4/25/24.
//

import Combine
import AppNetworking

#if canImport(AppKit)
import AppKit
public typealias PlatformImage = NSImage
#else
import UIKit
public typealias PlatformImage = UIImage
#endif

struct ImageCache {
    nonisolated(unsafe) private static var cache: [String: PlatformImage] = [:]
    
    static subscript(_ key: String) -> PlatformImage? {
        get { cache[key] }
        set {
            cache[key] = newValue
        }
    }
}

public struct ImageLoadingManager {
    private var inFlightImages: Set<String> = []
    private var fetcher = SimpleImageFetcher()
    
    public init() {}
    
    public func loadImage(with url: String) -> AnyPublisher<PlatformImage, Never> {
        if let cached = ImageCache[url] {
            return Just(cached)
                .eraseToAnyPublisher()
        }
        
        return fetcher.fetchImage(from: url)
            .compactMap {
                PlatformImage(data: $0)
            }
            .handleEvents(receiveOutput: { img in
                ImageCache[url] = img
            })
            .replaceError(with: PlatformImage())
            .eraseToAnyPublisher()
    }
    
    public func getImage(with url: String) -> PlatformImage? {
        let image = ImageCache[url]
        return image
    }
}
