//
//  JSONDecoder.swift
//  RedditClient
//
//  Created by Miguel Gonzalez on 4/5/24.
//

import Foundation

public struct ResponseDecoder<Response: Decodable> {
    private var decode: (Data) throws -> Response
    public init(decode: @escaping (Data) throws -> Response) {
        self.decode = decode
    }
    
    func callAsFunction(_ data: Data) throws -> Response {
        try decode(data)
    }
}
