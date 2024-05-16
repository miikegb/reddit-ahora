//
//  PostsViewModel.swift
//  RedditClient
//
//  Created by Miguel Gonzalez on 3/28/24.
//

import Foundation
import Combine

final class PostsViewModel: ObservableObject {
    @Published var posts = [Link]()
    private var postsRepository: PostsRepository
    private var cancelBag = CancelBag()
    private var fetchListingSubject = PassthroughSubject<RedditPage, Error>()
    private var currentPage: RedditPage = .home
    
    init<S: Scheduler>(postsRepository: PostsRepository, scheduler: S = RunLoop.main) {
        self.postsRepository = postsRepository
        
        setupListingPublisher()
            .replaceError(with: [])
            .receive(on: scheduler)
            .sink { [weak self] links in
                self?.posts.append(contentsOf: links)
            }
            .store(in: cancelBag)
        
        // Start fetching posts automatically
        fetchListingSubject.send(currentPage)
    }
    
    private func setupListingPublisher() -> LinksPublisher {
        fetchListingSubject
            .flatMap { [postsRepository] in
                postsRepository.getListing(for: $0)
            }
            .eraseToAnyPublisher()
    }
    
    func loadMorePosts() {
        fetchListingSubject.send(currentPage)
    }
}
