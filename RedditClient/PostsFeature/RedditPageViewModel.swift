//
//  RedditPageViewModel.swift
//  RedditClient
//
//  Created by Miguel Gonzalez on 3/28/24.
//

import Foundation
import Combine

final class RedditPageViewModel: ObservableObject {
    @Published var postsViewModels = [PostViewModel]()
    
    private var postsRepository: PostsRepository
    private var cancelBag = CancelBag()
    private var fetchListingSubject = PassthroughSubject<RedditPage, Error>()
    private var currentPage: RedditPage = .home
    private var postsIds: Set<String> = []
    private var subredditRepository: SubredditRepository
    
    init<S: Scheduler>(postsRepository: PostsRepository, subredditRepository: SubredditRepository, scheduler: S = RunLoop.main) {
        self.postsRepository = postsRepository
        self.subredditRepository = subredditRepository
        
        setupListingPublisher()
            .replaceError(with: [])
            .map { [weak self] links in
                let filteredPosts = links.filter { self?.postsIds.contains($0.id) == false }
                filteredPosts.forEach { self?.postsIds.insert($0.id) }
                return filteredPosts
            }
            .receive(on: scheduler)
            .sink { [weak self] (links: [Link]) -> Void in
                let vms = links.map { PostViewModel(post: $0, subredditRepository: subredditRepository) }
                self?.postsViewModels.append(contentsOf: vms)
            }
            .store(in: cancelBag)
        
        // Start fetching posts automatically
        fetchListingSubject.send(currentPage)
    }
    
    func loadMorePosts() {
        fetchListingSubject.send(currentPage)
    }
    
    private func setupListingPublisher() -> LinksPublisher {
        fetchListingSubject
            .flatMap { [postsRepository] in
                postsRepository.getListing(for: $0)
            }
            .eraseToAnyPublisher()
    }
}
