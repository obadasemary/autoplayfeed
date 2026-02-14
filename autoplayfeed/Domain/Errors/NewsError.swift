//
//  NewsError.swift
//  autoplayfeed
//
//  Created by Claude Code on 13.02.2026.
//

import Foundation

/// Domain-specific errors for news feature
enum NewsError: Error, Sendable {
    case network(URLError)
    case decoding(DecodingError)
    case server(statusCode: Int)
    case unknown(String)
    case noMorePages

    /// User-friendly error message for display
    var userMessage: String {
        switch self {
        case .network:
            return "Network connection failed. Please check your connection and try again."
        case .decoding:
            return "Unable to process server response. Please try again later."
        case .server(let statusCode):
            return "Server error (\(statusCode)). Please try again later."
        case .unknown(let message):
            return message
        case .noMorePages:
            return "No more news to load."
        }
    }
}
