//
//  FixturesLoader.swift
//  RedditClientTests
//
//  Created by Miguel Gonzalez on 4/5/24.
//

import Foundation
@testable import RedditClient

enum FixturesLoaderError: Error {
    case fixtureNotFound, unableToReadFixture
}

final class FixturesLoader {
    static func load<T: Decodable>(json fixtureName: String) throws -> T {
        guard let fixtureUrl = Bundle(for: Self.self).url(forResource: fixtureName, withExtension: "json")
        else { throw FixturesLoaderError.fixtureNotFound }
        
        let jsonData = try Data(contentsOf: fixtureUrl)
        return try JSONDecoder.defaultRedditDecoder.decode(T.self, from: jsonData)
    }
}
