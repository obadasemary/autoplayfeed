//
//  NewsFeedRouter.swift
//  autoplayfeed
//
//  Created by Claude Code on 13.02.2026.
//

import Foundation

/// Implementation of NewsFeedRouterProtocol
@MainActor
final class NewsFeedRouter: NewsFeedRouterProtocol {
    func navigateToNewsDetail(item: NewsItemAdapter) {
        // Placeholder for future navigation to detail view
        print("Navigate to detail for: \(item.title)")
    }
}
