//
//  RedditPageViewModel.swift
//  RedditClient
//
//  Created by Miguel Gonzalez on 3/28/24.
//

import Foundation
import Combine
import Core

@MainActor
public final class RedditPageViewModel: ObservableObject {
    @Published var postsViewModels = [PostViewModel]()
    @Published var isLoading = false
    @Published var errorLoading = false
    
    private var postsRepository: PostsRepository
    private var commentsRepository: PostCommentsRepository
    private var redditorRepository: RedditorRepository
    private var subredditRepository: SubredditRepository
    private var currentPage: RedditPage = .home
    private var postsIds: Set<String> = []
    
    public init(postsRepository: PostsRepository,
                       subredditRepository: SubredditRepository,
                       commentsRepository: PostCommentsRepository,
                       redditorRepository: RedditorRepository) {
        self.postsRepository = postsRepository
        self.subredditRepository = subredditRepository
        self.commentsRepository = commentsRepository
        self.redditorRepository = redditorRepository
    }
    
    func loadPosts() async {
        isLoading.toggle()
        errorLoading = false
        defer {
            isLoading.toggle()
        }
        
        do {
            let posts = try await postsRepository.getListingAsync(for: currentPage)
            let filteredPosts = posts.filter { postsIds.contains($0.id) == false }
            filteredPosts.forEach { postsIds.insert($0.id) }
            let vms = filteredPosts.map { PostViewModel(post: $0, subredditRepository: subredditRepository, commentsRepo: commentsRepository, redditorRepo: redditorRepository) }
            postsViewModels.append(contentsOf: vms)
        } catch {
            print("Error loading posts for page: \(currentPage)")
            errorLoading = true
        }
    }
}
