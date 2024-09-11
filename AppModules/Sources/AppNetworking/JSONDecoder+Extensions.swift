//
//  File.swift
//  AppModules
//
//  Created by Miguel Gonzalez on 8/10/24.
//

import Foundation

extension JSONDecoder {
    public convenience init(keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy, dateDecodingStrategy: JSONDecoder.DateDecodingStrategy) {
        self.init()
        self.keyDecodingStrategy = keyDecodingStrategy
        self.dateDecodingStrategy = dateDecodingStrategy
    }
    
    public static var defaultRedditDecoder: JSONDecoder {
        JSONDecoder(keyDecodingStrategy: .convertFromSnakeCase, dateDecodingStrategy: .secondsSince1970)
    }
}

extension JSONEncoder {
    public static var defaultRedditEncoder: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return encoder
    }
}
