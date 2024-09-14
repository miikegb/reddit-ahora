//
//  InMemoryCache.swift
//  AppModules
//
//  Created by Miguel Gonzalez on 9/12/24.
//

public actor InMemoryCache<Key: Hashable, Value> {
    private var storage: [Key: Value] = [:]
    
    public init() {}
    
    public subscript(_ key: Key) -> Value? {
        get { storage[key] }
        set { storage[key] = newValue }
    }
    
    public func set(_ value: Value, for key: Key) {
        storage[key] = value
    }
}
