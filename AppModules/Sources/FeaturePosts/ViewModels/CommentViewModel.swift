//
//  CommentViewModel.swift
//  RedditClient
//
//  Created by Miguel Gonzalez on 5/31/24.
//

import Foundation
import Combine
import Core

enum AvatarLoadingError: Error {
    case noAvatar
}

@MainActor
@dynamicMemberLookup
final class CommentViewModel: ObservableObject, Sendable {
    @Published var avatar: PlatformImage?
    lazy var attributedBody: AttributedString = {
        let options = AttributedString.MarkdownParsingOptions(interpretedSyntax: .inlineOnlyPreservingWhitespace)
        guard let markdown = try? AttributedString(markdown: comment.body, options: options) else {
            return AttributedString(comment.body)
        }
        return markdown
    }()
    var postedDateString: String {
        timestamp(from: comment.created)
    }

    private var comment: Comment
    private var redditorRepository: RedditorRepository
    private var imageCacheManager = ImageLoadingManager()
    private var timestamp = TimestampFormatter()
    
    init(comment: Comment, redditorRepository: RedditorRepository) {
        self.comment = comment
        self.redditorRepository = redditorRepository
    }
    
    func fetchRedditor() async -> Redditor? {
        if let redditor = await redditorRepository[comment.author] {
            redditor
        } else {
            try? await redditorRepository.fetchDetails(for: comment.author)
        }
    }
    
    subscript<V>(dynamicMember keyPath: KeyPath<Comment, V>) -> V {
        comment[keyPath: keyPath]
    }
    
    func loadAuthorAvatar() async {
        guard avatar == nil else { return }
        if let redittor = await fetchRedditor() {
            if let cachedAvatar = await imageCacheManager.getImage(with: redittor.iconImg) {
                avatar = cachedAvatar
            } else {
                let img = await imageCacheManager.loadImageAsync(with: redittor.iconImg)
                avatar = img
            }
        } else {
            print("Error loading Redditor: \(comment.author)")
        }
    }
}
