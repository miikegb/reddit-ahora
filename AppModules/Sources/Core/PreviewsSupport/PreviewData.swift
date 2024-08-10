//
//  PreviewData.swift
//  RedditClient
//
//  Created by Miguel Gonzalez on 4/25/24.
//

import Foundation

public struct PreviewData {
    public static var previewPosts: [Link] {
        let listing: Listing = try! FixturesLoader.load(json: "PreviewRedditPosts")
        return listing.children.compactMap {
            $0.associatedValue as? Link
        }
    }
    
    public static var previewComments: [Comment] {
        let comments: [Thing] = try! FixturesLoader.load(json: "PreviewComments")
        return comments.compactMap {
            $0.associatedValue as? Comment
        }
    }
}
