//
//  Publisher+Extensions.swift
//  RedditClientTests
//
//  Created by Miguel Gonzalez on 5/1/24.
//

import Combine

extension Publisher {
    public func flexValue(with valueReceiver: @escaping (Output) -> Void) {
        let flex = FlexValueSubscriber<Output, Failure>(valueReceiver: valueReceiver)
        subscribe(flex)
    }
}

struct FlexValueSubscriber<Input, Failure: Error>: Subscriber {
    let valueReceiver: (Input) -> Void
    let completionReceiver: ((Subscribers.Completion<Failure>) -> Void)? = nil
    let combineIdentifier = CombineIdentifier()
    
    func receive(subscription: any Subscription) {
        subscription.request(.unlimited)
    }
    
    func receive(_ input: Input) -> Subscribers.Demand {
        valueReceiver(input)
        return .unlimited
    }
    
    func receive(completion: Subscribers.Completion<Failure>) {
        completionReceiver?(completion)
    }
}
