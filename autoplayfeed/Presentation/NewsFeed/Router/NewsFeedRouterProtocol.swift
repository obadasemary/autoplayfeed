//
//  NewsFeedRouterProtocol.swift
//  autoplayfeed
//
//  Created by Claude Code on 13.02.2026.
//

import Foundation

/// Protocol defining navigation actions from news feed
protocol NewsFeedRouterProtocol: Sendable {
    /// Navigates to news detail view
    /// - Parameter item: The news item to display
    func navigateToNewsDetail(item: NewsItemAdapter)
}
