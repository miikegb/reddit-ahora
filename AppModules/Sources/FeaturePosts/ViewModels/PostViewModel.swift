//
//  PostViewModel.swift
//  RedditClient
//
//  Created by Miguel Gonzalez on 5/28/24.
//

import Foundation
import Core

@MainActor
@dynamicMemberLookup
public final class PostViewModel: ObservableObject, Identifiable, @preconcurrency Equatable {
    @Published var icon: PlatformImage?
    @Published var image: PlatformImage?
    @Published var comments: [CommentViewModel] = []
    lazy var attributedTitle: AttributedString = {
        let options = AttributedString.MarkdownParsingOptions(interpretedSyntax: .inlineOnlyPreservingWhitespace)
        guard let markdown = try? AttributedString(markdown: post.title, options: options) else {
            return AttributedString(post.title)
        }
        return markdown
    }()
    lazy var attributedBody: AttributedString = {
        let options = AttributedString.MarkdownParsingOptions(interpretedSyntax: .inlineOnlyPreservingWhitespace)
        guard let markdown = try? AttributedString(markdown: post.selftext, options: options) else {
            return AttributedString(post.selftext)
        }
        return markdown
    }()
    var postedDateString: String {
        timestamp(from: post.created)
    }

    private var post: Link
    private var imageCacheManager = ImageLoadingManager()
    private var timestamp = TimestampFormatter()
    private let subredditRepository: SubredditRepository
    private let commentsRepository: PostCommentsRepository
    private let redditorRepository: RedditorRepository

    public init(post: Link, subredditRepository: SubredditRepository, commentsRepo: PostCommentsRepository, redditorRepo: RedditorRepository) {
        self.post = post
        self.subredditRepository = subredditRepository
        self.commentsRepository = commentsRepo
        self.redditorRepository = redditorRepo
    }
    
    subscript<V>(dynamicMember keyPath: KeyPath<Link, V>) -> V {
        post[keyPath: keyPath]
    }
    
    public static func ==(_ lhs: PostViewModel, _ rhs: PostViewModel) -> Bool {
        lhs.post == rhs.post
    }
    
    func loadIconIfNeeded() async {
        guard icon == nil else { return }
        
        if let subreddit = await fetchSubreddit(), let iconImg = subreddit.iconImg {
            if let icon = await imageCacheManager.getImage(with: iconImg) {
                self.icon = icon
            } else {
                icon = await imageCacheManager.loadImageAsync(with: iconImg)
            }
        } else {
            print("Subreddit: \(post.subreddit) doesn't have an icon")
        }
    }
    
    private func fetchSubreddit() async -> Subreddit? {
        if let subreddit = await subredditRepository[post.subreddit] {
            return subreddit
        }
        do {
            return try await subredditRepository.fetchAboutSubreddit(post.subreddit)
        } catch {
            return nil
        }
    }
    
    func loadPostImageIfNeeded() async {
        guard post.postHint == "image", image == nil else { return }
        image = if let cachedImage = await imageCacheManager.getImage(with: post.url) {
            cachedImage
        } else {
            await imageCacheManager.loadImageAsync(with: post.url)
        }
    }
    
    func loadComments() async {
        do {
            let comments = try await commentsRepository.fetchCommentsAsync(from: post)
            self.comments = comments.map { CommentViewModel(comment: $0, redditorRepository: redditorRepository) }
        } catch {
            print("Error loading comments...")
        }
    }
}
