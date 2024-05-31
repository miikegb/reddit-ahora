//
//  PostViewModel.swift
//  RedditClient
//
//  Created by Miguel Gonzalez on 5/28/24.
//

import Foundation
import Combine

@dynamicMemberLookup
final class PostViewModel: ObservableObject, Identifiable, Equatable {
    @Published var icon: PlatformImage?
    @Published var image: PlatformImage?

    private var post: Link
    private var imageCacheManager = ImageCacheManager()
    private var subredditRepository: SubredditRepository
    
    private var loadIconPublisher: AnyPublisher<PlatformImage, Error>?
    private var iconLoaderSubscription: AnyCancellable?
    private var loadPostImagePublisher: AnyPublisher<PlatformImage, Error>?
    private var postImageLoaderSubscription: AnyCancellable?

    init(post: Link, subredditRepository: SubredditRepository) {
        self.post = post
        self.subredditRepository = subredditRepository
        
        setupIcon()
        setupPostImage()
    }
    
    subscript<V>(dynamicMember keyPath: KeyPath<Link, V>) -> V {
        post[keyPath: keyPath]
    }
    
    static func ==(_ lhs: PostViewModel, _ rhs: PostViewModel) -> Bool {
        lhs.post == rhs.post
    }
    
    func loadIconIfNeeded() {
        guard icon == nil, let loadIconPublisher else { return }
        
        iconLoaderSubscription = loadIconPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] completion in
                self?.iconLoaderSubscription = nil
            } receiveValue: { [weak self] image in
                self?.icon = image
            }
    }
    
    func loadPostImageIfNeeded() {
        guard image == nil, let loadPostImagePublisher else { return }
        
        postImageLoaderSubscription = loadPostImagePublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] completion in
                self?.postImageLoaderSubscription = nil
            } receiveValue: { [weak self] image in
                self?.image = image
            }
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
            loadPostImagePublisher = imageCacheManager.loadImage(with: post.url)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
    }
    
    private func setupIconLoader() {
        if let subreddit = subredditRepository[post.subreddit] {
            if let iconImg = subreddit.iconImg {
                loadIconPublisher = imageCacheManager.loadImage(with: iconImg)
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            } else {
                // TODO: Handle this scenario
                fatalError("Need to handle this scenario...")
            }
        } else {
            loadIconPublisher = subredditRepository.fetchSubredditAbout(post.subreddit)
                .compactMap { $0.iconImg }
                .flatMap { [imageCacheManager] iconImg in
                    imageCacheManager.loadImage(with: iconImg)
                        .handleEvents(receiveCompletion: { [weak self] completion in
                            print("Completed loading image for \(String(describing: self?.post.subreddit)), url: \(iconImg)")
                        })
                }
                .eraseToAnyPublisher()
        }
    }
}
