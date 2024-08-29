//
//  File.swift
//  AppModules
//
//  Created by Miguel Gonzalez on 8/10/24.
//

import Foundation
import AppNetworking
import Core

extension ResponseDecoder {
    public init(for type: Response.Type) {
        self.init {
            try JSONDecoder(keyDecodingStrategy: .convertFromSnakeCase, dateDecodingStrategy: .secondsSince1970)
                .decode(type, from: $0)
        }
    }
}
