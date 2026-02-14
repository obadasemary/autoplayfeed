//
//  NewsFeedRouter.swift
//  autoplayfeed
//
//  Created by Claude Code on 13.02.2026.
//

import SwiftUI
import Observation

/// Destination types for news feed navigation
enum NewsFeedDestination: Hashable {
    case newsDetail(NewsItemAdapter)
}

/// Implementation of NewsFeedRouterProtocol
@MainActor
@Observable
final class NewsFeedRouter: NewsFeedRouterProtocol {
    var navigationPath = NavigationPath()

    func navigateToNewsDetail(item: NewsItemAdapter) {
        print("Navigate to detail for: \(item.title)")
        navigationPath.append(NewsFeedDestination.newsDetail(item))
    }

    /// Navigates back to the previous screen
    func navigateBack() {
        guard !navigationPath.isEmpty else { return }
        navigationPath.removeLast()
    }

    /// Resets navigation to root
    func popToRoot() {
        navigationPath = NavigationPath()
    }
}
