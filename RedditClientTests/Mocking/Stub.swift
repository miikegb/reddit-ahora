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

struct StubBuilder<SuperBuilder: MockBuilder, Arguments, ReturnType> {
    typealias Signature =  (Arguments) -> ReturnType
    var recorder: MockRecorder<SuperBuilder.MockType>
    var member: SuperBuilder.MockType.Props
    
    @discardableResult
    func andReturn(_ returnValue: ReturnType) -> SuperBuilder {
        recorder.return(returnValue, for: member)
        return .init(recorder)
    }
    
    @discardableResult
    func with(_ closure: @escaping Signature) -> SuperBuilder {
        recorder.return(closure, for: member)
        return .init(recorder)
    }
}

struct StubResolver<T: Mock, Arguments, ReturnType> {
    typealias InnerClosureType = (Arguments) -> ReturnType
    typealias ClosureType = (InnerClosureType) -> ReturnType
    var recorder: MockRecorder<T>
    var mock: T
    
    func resolve(for member: T.Props, closure: ClosureType) throws -> ReturnType {
        return try recorder.resolveReturnValue(for: member) { savedClosure in
            if let castClosure = savedClosure as? InnerClosureType {
                return closure(castClosure)
            }
            throw ResolveError.signatureMismatch
        } as ReturnType
    }
}
