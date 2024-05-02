//
//  FixturesLoader.swift
//  RedditClientTests
//
//  Created by Miguel Gonzalez on 4/5/24.
//

import Foundation

enum FixturesLoaderError: Error {
    case fixtureNotFound, unableToReadFixture
}

final class FixturesLoader {
    static func load<T: Decodable>(json fixtureName: String, bundle: Bundle = Bundle(for: FixturesLoader.self)) throws -> T {
        guard let fixtureUrl = bundle.url(forResource: fixtureName, withExtension: "json")
        else { throw FixturesLoaderError.fixtureNotFound }
        
        let jsonData = try Data(contentsOf: fixtureUrl)
        return try JSONDecoder.defaultRedditDecoder.decode(T.self, from: jsonData)
    }
}
