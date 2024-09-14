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

public struct ImageLoadingManager: Sendable {
    private var inFlightImages: Set<String> = []
    private var fetcher = SimpleImageFetcher()
    private var imageCache: InMemoryCache<String, PlatformImage>
    
    public init() {
        self.imageCache = InMemoryCache()
    }
    
    public func loadImageAsync(with url: String) async -> PlatformImage {
        if let cached = await imageCache[url] {
            return cached
        }
        do {
            let data = try await fetcher.fetchImageAsync(from: url)
            if let img = PlatformImage(data: data) {
                await imageCache.set(img, for: url)
                return img
            }
            return PlatformImage()
        } catch {
            return PlatformImage()
        }
    }
    
    public func getImage(with url: String) async -> PlatformImage? {
        await imageCache[url]
    }
}
