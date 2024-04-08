//
//  Mock.swift
//  RedditClientTests
//
//  Created by Miguel Gonzalez on 4/5/24.
//

import Foundation

protocol MockBuilder<MockType> {
    associatedtype MockType: Mock
    init(_ recorder: MockRecorder<MockType>)
}

protocol MockVerifier<MockType> {
    associatedtype MockType: Mock
    init(_ recorder: MockRecorder<MockType>)
}

protocol Mock {
    associatedtype Props: Hashable & Matcheable
    associatedtype Builder: MockBuilder<Self>
    associatedtype Verifier: MockVerifier<Self>
    
    var recorder: MockRecorder<Self> { get }
}

protocol Matcheable {
    func matches(_ other: Self) -> Bool
}

