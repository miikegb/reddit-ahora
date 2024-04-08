//
//  HttpClient.swift
//  RedditClient
//
//  Created by Miguel Gonzalez on 3/26/24.
//

import Foundation
import Combine

enum HttpMethod {
    case get
    case post(payload: Data)
    
    var asString: String {
        return switch self {
        case .get: "GET"
        case .post: "POST"
        }
    }
}

enum SortResults: String {
    case best, hot, new, top, rising
    var path: String {
        "\(rawValue).json"
    }
}

struct Resource<Response: Decodable> {
    var path: String
    var method: HttpMethod = .get
    var sort: SortResults = .hot
    var responseDecoder: ResponseDecoder<Response>
}


struct HttpClientConfiguration {
    var baseUrl: URL
    var session: URLSession
    var defaultHeaders: [String: String]? = nil
}

extension URLRequest {
    init<T>(for resource: Resource<T>, baseUrl: URL, headers: [String: String]? = nil) {
        let resourceUrl = baseUrl
            .appendingPathComponent(resource.path)
            .appendingPathComponent(resource.sort.path)
        self.init(url: resourceUrl)
        httpMethod = resource.method.asString
        if let defaultHeaders = headers {
            for (key, value) in defaultHeaders {
                setValue(value, forHTTPHeaderField: key)
            }
        }
    }
}

final class HttpClient {
    private let config: HttpClientConfiguration
    private var urlSession: URLSession { config.session }
    private var baseUrl: URL { config.baseUrl }
    
    init(config: HttpClientConfiguration) {
        self.config = config
    }
    
    func fetch<T>(_ resource: Resource<T>) -> AnyPublisher<T, Error> {
        URLSession.DataTaskPublisher(request: .init(for: resource, baseUrl: baseUrl, headers: config.defaultHeaders), session: urlSession)
            .tryMap { data, _ in
                try resource.responseDecoder(data)
            }
            .eraseToAnyPublisher()
    }
}

