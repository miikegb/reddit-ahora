//
//  FixtureFinder.swift
//  AppModules
//
//  Created by Miguel Gonzalez on 9/3/24.
//

import Foundation
import Core

//#if DEBUG

@dynamicMemberLookup
final class FixtureFinder {
    public static func url(for fixtureName: String) -> URL {
        Bundle.module.url(forResource: fixtureName, withExtension: "json", subdirectory: "Fixtures")!
    }
    
    static subscript<T: Decodable>(dynamicMember fixtureName: String) -> T {
        return try! load(url: url(for: fixtureName))
    }
    
    private static func load<T: Decodable>(url: URL) throws -> T {
        let jsonData = try Data(contentsOf: url)
        return try JSONDecoder.defaultRedditDecoder.decode(T.self, from: jsonData)
    }
}

//#endif
