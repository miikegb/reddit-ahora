//
//  Entry.swift
//  RedditClientTests
//
//  Created by Miguel Gonzalez on 4/5/24.
//

import Foundation

func stub<T: Mock>(_ mock: T) -> T.Builder {
    type(of: mock).Builder(mock.recorder)
}

func expect<T: Mock>(_ mock: T) -> T.Verifier {
    type(of: mock).Verifier(mock.recorder)
}

func verify<T: Mock>(_ mock: T, strict: Bool = true, file: StaticString = #file, line: UInt = #line) {
    mock.recorder.verifyExpectations(strict: strict, file: file, line: line)
}
