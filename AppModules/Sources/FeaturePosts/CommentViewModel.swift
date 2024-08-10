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

@dynamicMemberLookup
final class CommentViewModel: ObservableObject {
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
    private var imageCacheManager = ImageCacheManager()
    private var timestamp = TimestampFormatter()

    private var avatarPublisher: AnyPublisher<PlatformImage, Error>?
    private var avatarSubscription: AnyCancellable?
    
    init(comment: Comment, redditorRepository: RedditorRepository) {
        self.comment = comment
        self.redditorRepository = redditorRepository
        
        setupAvatarPublisher()
    }
    
    subscript<V>(dynamicMember keyPath: KeyPath<Comment, V>) -> V {
        comment[keyPath: keyPath]
    }
    
    func loadAuthorAvatar() {
        guard avatar == nil, let avatarPublisher else { return }
        avatarSubscription = avatarPublisher.receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
            self?.avatarSubscription = nil
        }, receiveValue: { [weak self] image in
            self?.avatar = image
        })
    }
    
    // MARK: - Private methods
    private func setupAvatarPublisher() {
        if let redditor = redditorRepository[comment.author] {
            if let avatar = imageCacheManager.getImage(with: redditor.iconImg) {
                self.avatar = avatar
            } else {
                avatarPublisher = imageCacheManager.loadImage(with: redditor.iconImg)
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            }
        } else {
            avatarPublisher = redditorRepository.fetchRedditorDetails(for: comment.author)
                .flatMap { [imageCacheManager] in
                    imageCacheManager.loadImage(with: $0.iconImg)
                }
                .eraseToAnyPublisher()
        }
    }
}
