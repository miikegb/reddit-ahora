//
//  CancelBag.swift
//  RedditClient
//
//  Created by Miguel Gonzalez on 3/27/24.
//

import Foundation
import Combine

public final class CancelBag {
    private var cancellables = Set<AnyCancellable>()
    
    public init() {}
    
    public func add(cancellable: AnyCancellable) {
        cancellables.insert(cancellable)
    }
    
    public func cancel() {
        cancellables.removeAll()
    }
    
    deinit {
        cancel()
    }
}

extension AnyCancellable {
    public func store(in cancelBag: CancelBag) {
        cancelBag.add(cancellable: self)
    }
}

