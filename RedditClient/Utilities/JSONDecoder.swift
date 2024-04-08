//
//  JSONDecoder.swift
//  RedditClient
//
//  Created by Miguel Gonzalez on 4/5/24.
//

import Foundation

extension JSONDecoder {
    convenience init(keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy, dateDecodingStrategy: JSONDecoder.DateDecodingStrategy) {
        self.init()
        self.keyDecodingStrategy = keyDecodingStrategy
        self.dateDecodingStrategy = dateDecodingStrategy
    }
    
    static var defaultRedditDecoder: JSONDecoder {
        JSONDecoder(keyDecodingStrategy: .convertFromSnakeCase, dateDecodingStrategy: .secondsSince1970)
    }
}

struct ResponseDecoder<Response: Decodable> {
    var decode: (Data) throws -> Response
    
    func callAsFunction(_ data: Data) throws -> Response {
        try decode(data)
    }
}

extension ResponseDecoder {
    init(for type: Response.Type) {
        decode = {
            try JSONDecoder(keyDecodingStrategy: .convertFromSnakeCase, dateDecodingStrategy: .secondsSince1970)
                .decode(type, from: $0)
        }
    }
}
