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
    @Published var searchText = ""
    private var postsRepository: PostsRepository
    private var cancelBag = CancelBag()
    private var scheduler: any Scheduler
    
    init<S: Scheduler>(postsRepository: PostsRepository, scheduler: S = RunLoop.main) {
        self.postsRepository = postsRepository
        self.scheduler = scheduler
        
        postsRepository.getHomePosts()
            .replaceError(with: [])
            .receive(on: scheduler)
            .assign(to: &$posts)
        
        $searchText
            .filter { $0.count > 0 }
            .removeDuplicates()
            .debounce(for: .seconds(0.5), scheduler: scheduler)
            .flatMap { term in
                postsRepository.getPosts(for: term)
                    .replaceError(with: [])
                    .eraseToAnyPublisher()
            }
            .receive(on: scheduler)
            .assign(to: &$posts)
    }
}
