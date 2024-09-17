//
//  PreviewData.swift
//  RedditClient
//
//  Created by Miguel Gonzalez on 4/25/24.
//

import Foundation
import Core

//#if DEBUG

struct PreviewData {
    static var previewPosts: [Link] {
        let listing: Listing = FixtureFinder.previewRedditPosts
        return listing.children.compactMap {
            $0.associatedValue as? Link
        }
    }
    
    static var previewComments: [Comment] {
        let comments: [Thing] = FixtureFinder.previewComments
        return comments.compactMap {
            $0.associatedValue as? Comment
        }
    }
}

//#endif
