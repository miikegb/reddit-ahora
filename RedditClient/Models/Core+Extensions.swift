//
//  Core+Extensions.swift
//  RedditClient
//
//  Created by Miguel Gonzalez on 5/2/24.
//

import Foundation

extension Link {
    var styledText: AttributedString? {
        guard let attrString = try? AttributedString(markdown: selftext) else { return nil }
        return attrString
    }
    var styledTitle: AttributedString? {
        guard let attrString = try? AttributedString(markdown: title) else { return nil }
        return attrString
    }
}

