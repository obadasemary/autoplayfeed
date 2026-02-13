//
//  NewsPageResponse.swift
//  autoplayfeed
//
//  Created by Claude Code on 13.02.2026.
//

import Foundation

/// Domain model representing a paginated news response
struct NewsPageResponse: Sendable {
    let page: Int
    let totalPages: Int
    let totalItems: Int
    let items: [NewsItem]

    /// Computed property to check if more pages are available
    var hasMorePages: Bool {
        page < totalPages
    }
}
