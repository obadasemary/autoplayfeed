//
//  Endpoint.swift
//  autoplayfeed
//
//  Created by Claude Code on 13.02.2026.
//

import Foundation

/// HTTP method enumeration for API requests
enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

/// Protocol defining the structure of an API endpoint
protocol Endpoint {
    /// Base URL for the API endpoint
    var baseURL: String { get }

    /// Path to append to the base URL
    var path: String { get }

    /// HTTP method for the request
    var method: HTTPMethod { get }

    /// Optional HTTP headers
    var headers: [String: String]? { get }

    /// Optional query parameters
    var queryParameters: [String: String]? { get }
}

extension Endpoint {
    /// Default implementation for headers
    var headers: [String: String]? {
        ["Content-Type": "application/json"]
    }

    /// Default implementation for query parameters
    var queryParameters: [String: String]? {
        nil
    }

    /// Default HTTP method is GET
    var method: HTTPMethod {
        .get
    }
}
