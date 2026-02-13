//
//  NewsFeedBuilder.swift
//  autoplayfeed
//
//  Created by Claude Code on 13.02.2026.
//

import Foundation
import Observation

/// Builder class for composing NewsFeedView with dependencies
@MainActor
@Observable
final class NewsFeedBuilder {
    private let container: DIContainer

    init(container: DIContainer) {
        self.container = container
    }

    /// Builds and returns a configured NewsFeedView
    func buildNewsFeedView() -> NewsFeedView {
        // Resolve use case from container
        let useCase = try! container.requireResolve(NewsUseCaseProtocol.self)

        // Create router
        let router = NewsFeedRouter()

        // Create view model
        let viewModel = NewsFeedViewModel(useCase: useCase, router: router)

        // Return configured view
        return NewsFeedView(viewModel: viewModel)
    }
}
