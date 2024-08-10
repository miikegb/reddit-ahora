//
//  PostViewModel.swift
//  RedditClient
//
//  Created by Miguel Gonzalez on 5/28/24.
//

import Foundation
import Combine
import Core

@dynamicMemberLookup
public final class PostViewModel: ObservableObject, Identifiable, Equatable {
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
    private var imageCacheManager = ImageCacheManager()
    private var timestamp = TimestampFormatter()
    private var subredditRepository: SubredditRepository
    private var commentsRepository: PostCommentsRepository
    private var redditorRepository: RedditorRepository
    
    private var loadIconPublisher: AnyPublisher<PlatformImage, Error>?
    private var iconLoaderSubscription: AnyCancellable?
    private var loadPostImagePublisher: AnyPublisher<PlatformImage, Error>?
    private var postImageLoaderSubscription: AnyCancellable?

    public init(post: Link, subredditRepository: SubredditRepository, commentsRepo: PostCommentsRepository, redditorRepo: RedditorRepository) {
        self.post = post
        self.subredditRepository = subredditRepository
        self.commentsRepository = commentsRepo
        self.redditorRepository = redditorRepo
        
        setupIcon()
        setupPostImage()
    }
    
    subscript<V>(dynamicMember keyPath: KeyPath<Link, V>) -> V {
        post[keyPath: keyPath]
    }
    
    public static func ==(_ lhs: PostViewModel, _ rhs: PostViewModel) -> Bool {
        lhs.post == rhs.post
    }
    
    func loadIconIfNeeded() {
        guard icon == nil, let loadIconPublisher else { return }
        
        iconLoaderSubscription = loadIconPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.iconLoaderSubscription = nil
            } receiveValue: { [weak self] image in
                self?.icon = image
            }
    }
    
    func loadPostImageIfNeeded() {
        guard image == nil, let loadPostImagePublisher else { return }
        
        postImageLoaderSubscription = loadPostImagePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.postImageLoaderSubscription = nil
            } receiveValue: { [weak self] image in
                self?.image = image
            }
    }
    
    func loadComments() {
        commentsRepository.fetchComments(from: post)
            .replaceError(with: [])
            .map { [redditorRepository] in $0.map { CommentViewModel(comment: $0, redditorRepository: redditorRepository) } }
            .receive(on: DispatchQueue.main)
            .assign(to: &$comments)
    }

    // MARK: - Private Methods
    private func setupIcon() {
        if let subreddit = subredditRepository[post.subreddit], let iconImg = subreddit.iconImg, let cachedIcon = imageCacheManager.getImage(with: iconImg) {
            icon = cachedIcon
        } else {
            setupIconLoader()
        }
    }
    
    private func setupPostImage() {
        guard post.postHint == "image" else { return }
        if let postImage = imageCacheManager.getImage(with: post.url) {
            image = postImage
        } else {
            loadPostImagePublisher = loadImage(from: post.url)
        }
    }
    
    private func setupIconLoader() {
        if let subreddit = subredditRepository[post.subreddit] {
            if let iconImg = subreddit.iconImg {
                loadIconPublisher = loadImage(from: iconImg)
            } else {
                // TODO: Handle this scenario
                fatalError("Need to handle this scenario...")
            }
        } else {
            loadIconPublisher = subredditRepository.fetchSubredditAbout(post.subreddit)
                .compactMap { $0.iconImg }
                .flatMap(loadImage)
                .eraseToAnyPublisher()
        }
    }
    
    private func loadImage(from imageUrl: String) -> AnyPublisher<PlatformImage, Error> {
        imageCacheManager.loadImage(with: imageUrl)
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
    }
}

extension Publishers {
    
}
