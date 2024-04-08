//
//  CancelBag.swift
//  RedditClient
//
//  Created by Miguel Gonzalez on 3/27/24.
//

import Foundation
import Combine

final class CancelBag {
    private var cancellables = Set<AnyCancellable>()
    
    func add(cancellable: AnyCancellable) {
        cancellables.insert(cancellable)
    }
    
    func cancel() {
        cancellables.removeAll()
    }
    
    deinit {
        cancel()
    }
}

extension AnyCancellable {
    func store(in cancelBag: CancelBag) {
        cancelBag.add(cancellable: self)
    }
}

