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
    
    private func setUpViewModel() -> (PassthroughSubject<[Link], Error>, MockPostsRepository, PostsViewModel) {
        let postsSubject = PassthroughSubject<[Link], Error>()
        let mockRepo = MockPostsRepository()
        let vm = PostsViewModel(postsRepository: mockRepo, scheduler: ImmediateScheduler.shared)
        return (postsSubject, mockRepo, vm)
    }
    
    func test_posts_delivered_to_the_view_come_from_the_posts_repository() throws {
        // Given
        let (postsSubject, mockRepo, vm) = setUpViewModel()
        let link: Link = try FixturesLoader.load(json: "sampleLink")
        let mockLinks = [link]
        let subredditToSearch = "testsubreddit"
        
        stub(mockRepo)
            .getPosts(for: .exact(subredditToSearch))
            .andReturn(postsSubject.eraseToAnyPublisher())
        
        expect(mockRepo)
            .getPosts(for: .exact(subredditToSearch)).toBeCalled()

        // When
        // Flow: -> Empty string -> Filter -> (no-op)
        //       -> subredditToSearch -> mockRepo -> mockData -> viewmodel
        vm.searchText = "" // Should not trigger a new search for an empty search term
        vm.searchText = subredditToSearch
        postsSubject.send(mockLinks)
        
        // Then
        verify(mockRepo)
        XCTAssertEqual(vm.posts, mockLinks, "Expected PostsViewModel to get back mockLinks from MockPostsRepository, but the result didn't match.")
    }
    
    func test_posts_are_cleared_out_on_error() {
        // Given
        enum TestError: Error {
            case repoError
        }
        let (postsSubject, mockRepo, vm) = setUpViewModel()
        let mockLinks = [
            Link(id: "", name: "", author: "", title: "", created: .now, createdUtc: .now, ups: 0, downs: 0, numComments: 0, subreddit: "", permalink: "", pinned: true)
        ]
        vm.posts = mockLinks
        let subredditToSearch = "testsubreddit"
        
        stub(mockRepo)
            .getPosts(for: .exact(subredditToSearch))
            .andReturn(postsSubject.eraseToAnyPublisher())
        
        expect(mockRepo)
            .getPosts(for: .exact(subredditToSearch)).toBeCalled()

        // When
        vm.searchText = subredditToSearch
        postsSubject.send(completion: .failure(TestError.repoError))

        // Then
        verify(mockRepo)
        XCTAssertTrue(vm.posts.isEmpty)
    }
}
