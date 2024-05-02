//
//  TestFixturesLoader.swift
//  RedditClientTests
//
//  Created by Miguel Gonzalez on 4/25/24.
//

import Foundation
@testable import RedditClient

final class TestFixturesLoader {
    static func load<T: Decodable>(json fixtureName: String) throws -> T {
        try FixturesLoader.load(json: fixtureName, bundle: Bundle(for: Self.self))
    }
}
