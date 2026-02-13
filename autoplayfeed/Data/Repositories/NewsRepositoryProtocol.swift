//
//  NewsRepositoryProtocol.swift
//  autoplayfeed
//
//  Created by Claude Code on 13.02.2026.
//

import Foundation

/// Protocol defining the news repository interface
protocol NewsRepositoryProtocol: Sendable {
    /// Fetches paginated news from the API
    /// - Parameter page: The page number to fetch
    /// - Returns: Domain model containing news page response
    /// - Throws: Repository or network errors
    func fetchNews(page: Int) async throws -> NewsPageResponse
}
