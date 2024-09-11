//
//  RedditPageViewModel.swift
//  RedditClient
//
//  Created by Miguel Gonzalez on 3/28/24.
//

import Foundation
import Combine
import Core

public final class RedditPageViewModel: ObservableObject {
    @Published var postsViewModels = [PostViewModel]()
    
    private var postsRepository: PostsRepository
    private var commentsRepository: PostCommentsRepository
    private var redditorRepository: RedditorRepository
    private var cancelBag = CancelBag()
    private var fetchListingSubject = PassthroughSubject<RedditPage, Error>()
    private var currentPage: RedditPage = .home
    private var postsIds: Set<String> = []
    private var subredditRepository: SubredditRepository
    
    public init(postsRepository: PostsRepository,
                       subredditRepository: SubredditRepository,
                       commentsRepository: PostCommentsRepository,
                       redditorRepository: RedditorRepository) {
        self.postsRepository = postsRepository
        self.subredditRepository = subredditRepository
        self.commentsRepository = commentsRepository
        self.redditorRepository = redditorRepository
    }
    
    @MainActor
    func loadPosts() {
        Task {
            do {
                let posts = try await postsRepository.getListingAsync(for: .home)
                let filteredPosts = posts.filter { postsIds.contains($0.id) == false }
                filteredPosts.forEach { postsIds.insert($0.id) }
                let vms = filteredPosts.map { PostViewModel(post: $0, subredditRepository: subredditRepository, commentsRepo: commentsRepository, redditorRepo: redditorRepository) }
                postsViewModels.append(contentsOf: vms)
            } catch {
                
            }
        }
    }
}
