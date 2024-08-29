//
//  FixturesLoader.swift
//  RedditClientTests
//
//  Created by Miguel Gonzalez on 4/5/24.
//

import Foundation

public enum FixturesLoaderError: Error {
    case fixtureNotFound, unableToReadFixture
}

public final class FixturesLoader {
    public static func load<T: Decodable>(json fixtureName: String, bundle: Bundle = Bundle(for: FixturesLoader.self)) throws -> T {
        guard let fixtureUrl = bundle.url(forResource: fixtureName, withExtension: "json")
        else { throw FixturesLoaderError.fixtureNotFound }
        return try load(url: fixtureUrl)
    }
    
    public static func load<T: Decodable>(url _url: URL) throws -> T {
        let jsonData = try Data(contentsOf: _url)
        return try JSONDecoder.defaultRedditDecoder.decode(T.self, from: jsonData)
    }
}
