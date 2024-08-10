//
//  RedditPostsRepositoryTests.swift
//  RedditClientTests
//
//  Created by Miguel Gonzalez on 4/26/24.
//

import XCTest
import Combine
import AppNetworking
@testable import RedditClient

final class RedditPostsRepositoryTests: XCTestCase {
    enum TestError: Error {
        case noResponse
    }
    
    func test_posts_are_fetched_from_network() throws {
        // Given
        let mockFetcher = MockNetworkFetcher()
        let publisher = PassthroughSubject<Listing, Error>()
        let sampleListing: Listing = try TestFixturesLoader.load(json: "sampleListing")
        let repo = RedditPostsRepository(fetcher: mockFetcher)
        let homePage: RedditPage = .home
        let defaultSort: SortResults = .best
        let expectedParams = ["raw_json": "1"]
        let expectedResource = Resource(path: "\(homePage.stringify)/\(defaultSort.path)", params: expectedParams, responseDecoder: .init(for: Listing.self))
        var homePosts = [Link]()
        
        stub(mockFetcher).fetch(.any)
            .andReturn(publisher.eraseToAnyPublisher())
        
        expect(mockFetcher).fetch(.exact(expectedResource))
            .toBeCalled()

        // When
        repo.getListing(for: .home)
            .flexValue { homePosts = $0 }
        publisher.send(sampleListing)

        // Then
        XCTAssertEqual(homePosts, sampleListing.allLinks)
        verify(mockFetcher)
    }
}
