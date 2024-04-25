//
//  SampleRedditPosts.swift
//  RedditClient
//
//  Created by Miguel Gonzalez on 4/25/24.
//

import Foundation

struct SampleRedditPosts {
    static var previewPosts: [Link] {
        let listing: Listing = try! FixturesLoader.load(json: "PreviewRedditPosts")
        return listing.children.compactMap { thing in
            if case let .link(link) = thing { return link }
            return nil
        }
    }
}
