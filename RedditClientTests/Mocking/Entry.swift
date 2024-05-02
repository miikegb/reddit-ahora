//
//  Entry.swift
//  RedditClientTests
//
//  Created by Miguel Gonzalez on 4/5/24.
//

import Foundation

func stub<T: Mock>(_ mock: T) -> T.Builder {
    mock.makeBuilder()
}

func expect<T: Mock>(_ mock: T) -> T.Verifier {
    mock.makeVerifier()
}

func verify<T: Mock>(_ mock: T, strict: Bool = true, file: StaticString = #file, line: UInt = #line) {
    mock.verifyExpectations(strict: strict, file: file, line: line)
}
