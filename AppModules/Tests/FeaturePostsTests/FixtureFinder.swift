//
//  File.swift
//  AppModules
//
//  Created by Miguel Gonzalez on 8/28/24.
//

import Foundation
import Core

@dynamicMemberLookup
final class TestFixture {
    static func url(for fixtureName: String) -> URL {
        Bundle.module.url(forResource: fixtureName, withExtension: "json", subdirectory: "Fixtures")!
    }
    
    static subscript<T: Decodable>(dynamicMember fixtureName: String) -> T {
        try! FixturesLoader.load(url: url(for: fixtureName))
    }
}
