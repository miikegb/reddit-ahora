//
//  Core+Extensions.swift
//  RedditClient
//
//  Created by Miguel Gonzalez on 5/2/24.
//

import Foundation

extension Listing {
    public var allLinks: [Link] {
        children.compactMap { thing in
            if case let .link(link) = thing { link } else { nil }
        }
    }
}

extension Link {
    public var imageSize: CGSize? {
        if let firstPreview = preview?.images.first {
            CGSize(width: firstPreview.source.width, height: firstPreview.source.height)
        } else {
            nil
        }
    }
}
