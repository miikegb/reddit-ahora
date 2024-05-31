//
//  HttpClient.swift
//  RedditClient
//
//  Created by Miguel Gonzalez on 3/26/24.
//

import Foundation
import Combine

enum HttpMethod: Equatable {
    case get
    case post(payload: Data)
    
    var asString: String {
        return switch self {
        case .get: "GET"
        case .post: "POST"
        }
    }
}

enum SortResults: String, Equatable {
    case best, hot, new, top, rising
    var path: String {
        "\(rawValue).json"
    }
    var asQueryParam: [String: String] {
        ["sort": path]
    }
}

struct Resource<Response: Decodable> {
    var path: String
    var method: HttpMethod = .get
    var params: [String: String]? = nil
    var responseDecoder: ResponseDecoder<Response>
}

extension Resource: Equatable {
    static func ==(_ lhs: Resource<Response>, _ rhs: Resource<Response>) -> Bool {
        lhs.path == rhs.path &&
        lhs.method == rhs.method &&
        lhs.params == lhs.params
    }
}

struct HttpClientConfiguration {
    var baseUrl: URL
    var session: URLSession
    var defaultHeaders: [String: String]? = nil
}

extension Dictionary where Key == String, Value == String {
    var asQueryItems: [URLQueryItem]? {
        map { URLQueryItem(name: $0.key, value: $0.value) }
    }
}

extension URLRequest {
    init<T>(for resource: Resource<T>, baseUrl: URL, headers: [String: String]? = nil) {
        let resourceUrl = baseUrl
            .appendingPathComponent(resource.path)
            .appending(params: resource.params)
        self.init(url: resourceUrl)
        httpMethod = resource.method.asString
        if let defaultHeaders = headers {
            for (key, value) in defaultHeaders {
                setValue(value, forHTTPHeaderField: key)
            }
        }
    }
    
}

extension URL {
    func appending(params: [String: String]?) -> Self {
        guard let params, !params.isEmpty else { return self }
        return appending(queryItems: params.asQueryItems ?? [])
    }
}

protocol URLSessionProvider {
    func dataTask(for request: URLRequest) -> AnyPublisher<(data: Data, response: URLResponse), URLError>
}

extension URLSession: URLSessionProvider {
    func dataTask(for request: URLRequest) -> AnyPublisher<(data: Data, response: URLResponse), URLError> {
        URLSession.DataTaskPublisher(request: request, session: self)
            .eraseToAnyPublisher()
    }
}

protocol Fetcher {
    func fetch<T>(_ resource: Resource<T>) -> AnyPublisher<T, Error>
}

final class HttpClient: Fetcher {
    private let config: HttpClientConfiguration
    private var urlSession: URLSessionProvider { config.session }
    private var baseUrl: URL { config.baseUrl }
    
    init(config: HttpClientConfiguration) {
        self.config = config
    }
    
    func fetch<T>(_ resource: Resource<T>) -> AnyPublisher<T, Error> {
        urlSession.dataTask(for: .init(for: resource, baseUrl: baseUrl, headers: config.defaultHeaders))
            .tryMap { data, _ in
                try resource.responseDecoder(data)
            }
            .eraseToAnyPublisher()
    }
}

extension HttpClientConfiguration {
    static var `default`: HttpClientConfiguration {
        HttpClientConfiguration(baseUrl: URL(string: "https://reddit.com")!, session: .shared)
    }
}

enum HTTPError: Error {
    case invalidUrlFormat
    case unableToLoadImage
}

struct SimpleImageFetcher {
    func fetchImage(from url: String) -> AnyPublisher<Data, Error> {
        guard let imageUrl = URL(string: url) else { return Fail(error: HTTPError.invalidUrlFormat).eraseToAnyPublisher() }
        return URLSession.shared.dataTaskPublisher(for: imageUrl)
            .mapError { _ in HTTPError.unableToLoadImage }
            .map { data, _ in data }
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
}

