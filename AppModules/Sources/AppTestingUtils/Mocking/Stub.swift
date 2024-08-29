//
//  Stub.swift
//  RedditClientTests
//
//  Created by Miguel Gonzalez on 4/5/24.
//

import Foundation

enum ReturnKind<ReturnType> {
    case value(ReturnType)
    case closure(ReturnType)
}

enum ResolveError: Error {
    case notFound, signatureMismatch
}

public struct StubBuilder<SuperBuilder: MockBuilder, Arguments, ReturnType> {
    public typealias Signature =  (Arguments) -> ReturnType
    var recorder: MockRecorder<SuperBuilder.MockType>
    var member: SuperBuilder.MockType.Props
    
    public init(recorder: MockRecorder<SuperBuilder.MockType>, member: SuperBuilder.MockType.Props) {
        self.recorder = recorder
        self.member = member
    }
    
    @discardableResult
    public func andReturn(_ returnValue: ReturnType) -> SuperBuilder {
        recorder.return(returnValue, for: member)
        return .init(recorder)
    }
    
    @discardableResult
    public func with(_ closure: @escaping Signature) -> SuperBuilder {
        recorder.return(closure, for: member)
        return .init(recorder)
    }
}

public struct StubResolver<T: Mock, Arguments, ReturnType> {
    public typealias InnerClosureType = (Arguments) -> ReturnType
    public typealias ClosureType = (InnerClosureType) -> ReturnType
    var recorder: MockRecorder<T>
    var mock: T
    
    public init(recorder: MockRecorder<T>, mock: T) {
        self.recorder = recorder
        self.mock = mock
    }
    
    public func resolve(for member: T.Props, closure: ClosureType) throws -> ReturnType {
        return try recorder.resolveReturnValue(for: member) { savedClosure in
            if let castClosure = savedClosure as? InnerClosureType {
                return closure(castClosure)
            }
            throw ResolveError.signatureMismatch
        } as ReturnType
    }
}
