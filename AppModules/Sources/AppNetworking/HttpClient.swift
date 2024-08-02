//
//  HttpClient.swift
//  RedditClient
//
//  Created by Miguel Gonzalez on 3/26/24.
//

import Foundation
import Combine
import OSLog

public enum HttpMethod: Equatable {
    case get
    case post(payload: Data)
    
    var asString: String {
        return switch self {
        case .get: "GET"
        case .post: "POST"
        }
    }
}

public enum SortResults: String, Equatable {
    case best, hot, new, top, rising
    public var path: String {
        "\(rawValue).json"
    }
    var asQueryParam: [String: String] {
        ["sort": path]
    }
}

public struct Resource<Response: Decodable> {
    var path: String
    var method: HttpMethod = .get
    var params: [String: String]? = nil
    var responseDecoder: ResponseDecoder<Response>
    
    public init(path: String, method: HttpMethod = .get, params: [String : String]? = nil, responseDecoder: ResponseDecoder<Response>) {
        self.path = path
        self.method = method
        self.params = params
        self.responseDecoder = responseDecoder
    }
}

extension Resource: Equatable {
    public static func ==(_ lhs: Resource<Response>, _ rhs: Resource<Response>) -> Bool {
        lhs.path == rhs.path &&
        lhs.method == rhs.method &&
        lhs.params == lhs.params
    }
}

public struct HttpClientConfiguration {
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

public protocol Fetcher {
    func fetch<T>(_ resource: Resource<T>) -> AnyPublisher<T, Error>
}

public final class HttpClient: Fetcher {
    private let config: HttpClientConfiguration
    private var urlSession: URLSessionProvider { config.session }
    private var baseUrl: URL { config.baseUrl }
    private var logger: Logger
    
    public init(config: HttpClientConfiguration) {
        self.config = config
        self.logger = Logger(subsystem: "Networking", category: "HttpClient")
    }
    
    public func fetch<T>(_ resource: Resource<T>) -> AnyPublisher<T, Error> {
        urlSession.dataTask(for: .init(for: resource, baseUrl: baseUrl, headers: config.defaultHeaders))
            .tryMap { data, _ in
                try resource.responseDecoder(data)
            }
            .handleEvents(
                receiveCompletion: { [logger] completion in
                    if case let .failure(error) = completion {
                        logger.error("[HTTPClient:\(#function)] Failed loading \(resource.path) with error: \(error.localizedDescription)")
                    } else {
                        logger.info("[HTTPClient:\(#function)] Completed loading \(resource.path)")
                    }
                },
                receiveCancel: { [logger] in
                    logger.warning("[HTTPClient:\(#function)] Cancelled loading \(resource.path)")
                }
            )
            .eraseToAnyPublisher()
    }
}

extension HttpClientConfiguration {
    public static var `default`: HttpClientConfiguration {
        HttpClientConfiguration(baseUrl: URL(string: "https://reddit.com")!, session: .shared)
    }
}

enum HTTPError: Error {
    case invalidUrlFormat
    case unableToLoadImage
}

public struct SimpleImageFetcher {
    private let logger = Logger(subsystem: "Networking", category: "SimpleImageFetcher")
    
    public init() {}
    
    public func fetchImage(from url: String) -> AnyPublisher<Data, Error> {
        guard let imageUrl = URL(string: url) else { return Fail(error: HTTPError.invalidUrlFormat).eraseToAnyPublisher() }
        return URLSession.shared.dataTaskPublisher(for: imageUrl)
            .handleEvents(
                receiveCompletion: { [logger] completion in
                    if case let .failure(error) = completion {
                        logger.error("[SimpleImageFetcher:\(#function)] Failed loading \(url) with error: \(error.localizedDescription)")
                    } else {
                        logger.info("[SimpleImageFetcher:\(#function)] Completed loading \(url)")
                    }
                },
                receiveCancel: { [logger] in
                    logger.warning("[SimpleImageFetcher:\(#function)] Cancelled loading \(url)")
                }
            )
            .mapError { _ in HTTPError.unableToLoadImage }
            .map { data, _ in data }
            .eraseToAnyPublisher()
    }
}

