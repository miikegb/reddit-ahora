//
//  IdentifiableProp.swift
//  RedditClientTests
//
//  Created by Miguel Gonzalez on 5/1/24.
//

import Foundation

struct IdentifiableProp<Prop> {
    var id = UUID()
    var prop: Prop
    
    init(id: UUID = UUID(), prop: Prop) {
        self.id = id
        self.prop = prop
        print("Creating a new IdentifiableProp")
    }
}

// TODO: How to include `Prop` in the `hash` equation? Is it necessary?
extension IdentifiableProp: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func ==(lhs: IdentifiableProp, rhs: IdentifiableProp) -> Bool {
        lhs.id == rhs.id
    }
}
