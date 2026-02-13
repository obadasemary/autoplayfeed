//
//  NewsUseCaseProtocol.swift
//  autoplayfeed
//
//  Created by Claude Code on 13.02.2026.
//

import Foundation

/// Protocol defining the news use case interface
protocol NewsUseCaseProtocol: Sendable {
    /// Fetches news for a specific page
    /// - Parameter page: The page number to fetch
    /// - Returns: Array of news item adapters for presentation
    /// - Throws: NewsError if the operation fails
    func fetchNews(page: Int) async throws -> [NewsItemAdapter]

    /// Checks if more pages are available
    /// - Parameter currentPage: The current page number
    /// - Returns: True if more pages exist, false otherwise
    /// - Throws: NewsError if the operation fails
    func hasMorePages(currentPage: Int) async throws -> Bool
}
