//
//  Entry.swift
//  RedditClientTests
//
//  Created by Miguel Gonzalez on 4/5/24.
//

import Foundation

public func stub<T: Mock>(_ mock: T) -> T.Builder {
    mock.makeBuilder()
}

public func expect<T: Mock>(_ mock: T) -> T.Verifier {
    mock.makeVerifier()
}

public func verify<T: Mock>(_ mock: T, strict: Bool = true, file: StaticString = #file, line: UInt = #line) {
    mock.verifyExpectations(strict: strict, file: file, line: line)
}
