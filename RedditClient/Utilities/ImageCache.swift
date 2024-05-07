//
//  ImageCache.swift
//  RedditClient
//
//  Created by Miguel Gonzalez on 4/25/24.
//

import Combine

#if canImport(AppKit)
import AppKit
typealias PlatformImage = NSImage
#else
import UIKit
typealias PlatformImage = UIImage
#endif

struct ImageCache {
    private static var cache: [String: PlatformImage] = [:]
    
    static subscript(_ key: String) -> PlatformImage? {
        get { cache[key] }
        set {
            cache[key] = newValue
        }
    }
}

struct ImageCacheManager {
    private var inFlightImages: Set<String> = []
    private var fetcher = SimpleImageFetcher()
    
    func loadImage(with url: String) -> AnyPublisher<PlatformImage, Never> {
        if let cached = ImageCache[url] {
            return Just(cached)
                .eraseToAnyPublisher()
        }
        
        return fetcher.fetchImage(from: url)
            .map {
                ImageCache[url] = PlatformImage(data: $0)!
                return ImageCache[url]!
            }
            .replaceError(with: PlatformImage())
            .eraseToAnyPublisher()
    }
    
    func getImage(with url: String) -> PlatformImage? {
        let image = ImageCache[url]
        return image
    }
}
