//
//  NavigationModel.swift
//  RedditClient
//
//  Created by Miguel Gonzalez on 5/7/24.
//

import SwiftUI
import FeaturePosts

final class NavigationModel: ObservableObject, Codable {
    @Published var selectedSubreddit: RedditPage? = .home
    @Published var columnVisibility: NavigationSplitViewVisibility
    @Published var preferredCompactColumn: NavigationSplitViewColumn
    
    private lazy var decoder = JSONDecoder()
    private lazy var encoder = JSONEncoder()
    
    init(columnVisibility: NavigationSplitViewVisibility = .automatic) {
        self.columnVisibility = columnVisibility
        self.preferredCompactColumn = .detail
    }
    
    required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        selectedSubreddit = try container.decodeIfPresent(RedditPage.self, forKey: .selectedSubreddit)
        columnVisibility = try container.decode(NavigationSplitViewVisibility.self, forKey: .columnVisibility)
        preferredCompactColumn = .detail
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(selectedSubreddit, forKey: .selectedSubreddit)
        try container.encode(columnVisibility, forKey: .columnVisibility)
    }
    
    enum CodingKeys: String, CodingKey {
        case selectedSubreddit
        case columnVisibility
    }
}

