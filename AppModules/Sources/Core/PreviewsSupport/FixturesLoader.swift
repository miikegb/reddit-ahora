//
//  FixturesLoader.swift
//  RedditClientTests
//
//  Created by Miguel Gonzalez on 4/5/24.
//

import Foundation
import AppNetworking

public enum FixturesLoaderError: Error {
    case fixtureNotFound, unableToReadFixture
}

public final class FixturesLoader {
    public static func load<T: Decodable>(json fixtureName: String, bundle: Bundle = Bundle(for: FixturesLoader.self)) throws -> T {
        guard let fixtureUrl = bundle.url(forResource: fixtureName, withExtension: "json")
        else { throw FixturesLoaderError.fixtureNotFound }
        
        let jsonData = try Data(contentsOf: fixtureUrl)
        return try JSONDecoder.defaultRedditDecoder.decode(T.self, from: jsonData)
    }
}
