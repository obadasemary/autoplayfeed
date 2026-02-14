//
//  NetworkService.swift
//  autoplayfeed
//
//  Created by Claude Code on 13.02.2026.
//

import Foundation

/// Protocol defining the network service interface
protocol NetworkService: Sendable {
    /// Executes a network request and returns a decoded response
    /// - Parameter endpoint: The endpoint configuration
    /// - Returns: Decoded response of type T
    /// - Throws: Network or decoding errors
    func request<T: Decodable>(endpoint: Endpoint) async throws -> T
}
