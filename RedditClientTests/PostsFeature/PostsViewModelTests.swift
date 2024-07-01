//
//  PostsViewModelTests.swift
//  RedditClientTests
//
//  Created by Miguel Gonzalez on 3/28/24.
//

import XCTest
import Combine
@testable import RedditClient

final class PostsViewModelTests: XCTestCase {
    
    private func setUpViewModel() -> (PassthroughSubject<[Link], Error>, MockPostsRepository, RedditPageViewModel) {
        let postsSubject = PassthroughSubject<[Link], Error>()
        let mockRepo = MockPostsRepository()
        let mockSubredditRepo = MockSubredditRepository()
        let commentsRepo = MockPostCommentsRepository()
        let redditorRepo = MockRedditorRepository()
        let vm = RedditPageViewModel(postsRepository: mockRepo,
                                     subredditRepository: mockSubredditRepo,
                                     commentsRepository: commentsRepo,
                                     redditorRepository: redditorRepo,
                                     scheduler: ImmediateScheduler.shared)
        return (postsSubject, mockRepo, vm)
    }
    
    func test_posts_come_from_home_page() throws {
        // Given
        let mockRepo = MockPostsRepository()
        let mockSubredditRepo = MockSubredditRepository()
        let commentsRepo = MockPostCommentsRepository()
        let redditorRepo = MockRedditorRepository()
        let sampleListing: Listing = try TestFixturesLoader.load(json: "sampleListing")
        let sampleListing2: Listing = try TestFixturesLoader.load(json: "sampleListing2")

        expect(mockRepo)
            .getListing(for: .exact(.home)).toBeCalled(.count(2))
        
        var callNumber = 0
        stub(mockRepo)
            .getListing().with { page in
                callNumber += 1
                return CurrentValueSubject<[Link], Error>(callNumber == 1 ? sampleListing.allLinks : sampleListing2.allLinks)
                    .eraseToAnyPublisher()
            }
        
        let listing1ViewModels = sampleListing.allLinks.map { PostViewModel(post: $0, subredditRepository: mockSubredditRepo, commentsRepo: commentsRepo, redditorRepo: redditorRepo) }
        let listing2ViewModels = sampleListing2.allLinks.map { PostViewModel(post: $0, subredditRepository: mockSubredditRepo, commentsRepo: commentsRepo, redditorRepo: redditorRepo) }

        // When
        let vm = RedditPageViewModel(postsRepository: mockRepo, subredditRepository: mockSubredditRepo, commentsRepository: commentsRepo, redditorRepository: redditorRepo, scheduler: ImmediateScheduler.shared)

        // Then
        XCTAssertEqual(vm.postsViewModels, listing1ViewModels)
        
        // When
        vm.loadMorePosts()
        
        // Then
        XCTAssertEqual(vm.postsViewModels, listing1ViewModels + listing2ViewModels)
        verify(mockRepo)
    }
    
    // TODO: Figure out where to handle duplicate requests.
    func pending_test_calling_loadMorePosts_multiple_times_doesnt_trigger_duplicate_requests() throws {
        // Given
        let mockRepo = MockPostsRepository()
        let mockSubredditRepo = MockSubredditRepository()
        let redditorRepo = MockRedditorRepository()
        let commentsRepo = MockPostCommentsRepository()
        let sampleListing: Listing = try TestFixturesLoader.load(json: "sampleListing")
        let sampleListing2: Listing = try TestFixturesLoader.load(json: "sampleListing2")
        let postsSubject = CurrentValueSubject<[Link], Error>(sampleListing.allLinks)

        stub(mockRepo)
            .getListing().with { page in
                postsSubject.eraseToAnyPublisher()
            }
        
        expect(mockRepo)
            .getListing(for: .exact(.home)).toBeCalled(.once)
        
        let listing1 = sampleListing.allLinks.map { PostViewModel(post: $0, subredditRepository: mockSubredditRepo, commentsRepo: commentsRepo, redditorRepo: redditorRepo) }
        let listing2 = sampleListing2.allLinks.map { PostViewModel(post: $0, subredditRepository: mockSubredditRepo, commentsRepo: commentsRepo, redditorRepo: redditorRepo) }

        // When
        let vm = RedditPageViewModel(postsRepository: mockRepo, subredditRepository: mockSubredditRepo, commentsRepository: commentsRepo, redditorRepository: redditorRepo, scheduler: ImmediateScheduler.shared)
        vm.loadMorePosts()
        vm.loadMorePosts()
        vm.loadMorePosts()
        vm.loadMorePosts()
        vm.loadMorePosts()
        
        
        // Then
        XCTAssertEqual(vm.postsViewModels, listing1 + listing2)
        verify(mockRepo)
    }
    
    func test_posts_are_not_affected_by_an_error() throws {
        // Given
        enum TestError: Error {
            case repoError
        }
        let postsSubject = PassthroughSubject<[Link], Error>()
        let mockRepo = MockPostsRepository()
        let mockSubredditRepo = MockSubredditRepository()
        let commentsRepo = MockPostCommentsRepository()
        let redditorRepo = MockRedditorRepository()
        let link: Link = try TestFixturesLoader.load(json: "sampleLink")
        let mockLinks = [PostViewModel(post: link, subredditRepository: mockSubredditRepo, commentsRepo: commentsRepo, redditorRepo: redditorRepo)]

        stub(mockRepo)
            .getListing(for: .exact(.home))
            .andReturn(postsSubject.eraseToAnyPublisher())
        
        expect(mockRepo)
            .getListing(for: .exact(.home)).toBeCalled()

        // When
        let vm = RedditPageViewModel(postsRepository: mockRepo, subredditRepository: mockSubredditRepo, commentsRepository: commentsRepo, redditorRepository: redditorRepo, scheduler: ImmediateScheduler.shared)
        vm.postsViewModels = mockLinks
        postsSubject.send(completion: .failure(TestError.repoError))

        // Then
        verify(mockRepo)
        XCTAssertEqual(vm.postsViewModels, mockLinks)
    }
    
    func test_home_posts_are_fetched_upon_initialization() throws {
        // Given
        let postsSubject = PassthroughSubject<[Link], Error>()
        let mockRepo = MockPostsRepository()
        let mockSubredditRepo = MockSubredditRepository()
        let commentsRepo = MockPostCommentsRepository()
        let redditorRepo = MockRedditorRepository()
        let sampleListing: Listing = try TestFixturesLoader.load(json: "sampleListing")
        let expectedViewModels = sampleListing.allLinks.map { PostViewModel(post: $0, subredditRepository: mockSubredditRepo, commentsRepo: commentsRepo, redditorRepo: redditorRepo) }
        
        stub(mockRepo)
            .getListing(for: .exact(.home))
            .andReturn(postsSubject.eraseToAnyPublisher())
        
        expect(mockRepo)
            .getListing(for: .exact(.home))
            .toBeCalled()

        // When
        let vm = RedditPageViewModel(postsRepository: mockRepo, subredditRepository: mockSubredditRepo, commentsRepository: commentsRepo, redditorRepository: redditorRepo, scheduler: ImmediateScheduler.shared)
        postsSubject.send(sampleListing.allLinks)
        
        // Then
        XCTAssertEqual(vm.postsViewModels, expectedViewModels)
        verify(mockRepo)
    }
}
