//
//  Mock.swift
//  RedditClientTests
//
//  Created by Miguel Gonzalez on 4/5/24.
//

import Foundation

public protocol Mock {
    associatedtype Props: Matcheable
    associatedtype Builder: MockBuilder<Self>
    associatedtype Verifier: MockVerifier<Self>
    
    func makeBuilder() -> Builder
    func makeVerifier() -> Verifier
    func verifyExpectations(strict: Bool, file: StaticString, line: UInt)
}

public protocol MockRecordeable {
    associatedtype MockType: Mock
    init(_ recorder: MockRecorder<MockType>)
}

public protocol MockBuilder<MockType>: MockRecordeable {}

public protocol MockVerifier<MockType>: MockRecordeable {}

public protocol Matcheable {
    func matches(_ other: Self) -> Bool
}

