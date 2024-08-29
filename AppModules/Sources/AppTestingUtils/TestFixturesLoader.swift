//
//  TestFixturesLoader.swift
//  RedditClientTests
//
//  Created by Miguel Gonzalez on 4/25/24.
//

import Foundation
import Core

public final class TestFixturesLoader {
    public static func load<T: Decodable>(from url: URL) throws -> T {
        let jsonData = try Data(contentsOf: url)
        return try JSONDecoder.defaultRedditDecoder.decode(T.self, from: jsonData)
    }
}
