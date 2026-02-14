//
//  DevPreview.swift
//  autoplayfeed
//
//  Created by Claude Code on 13.02.2026.
//

import Foundation

/// Development preview support with mock dependencies
@MainActor
final class DevPreview {
    static let shared = DevPreview()

    let container = DIContainer()

    private init() {
        registerMockDependencies()
    }

    /// Registers mock implementations for SwiftUI previews
    private func registerMockDependencies() {
        // Mock network service
        container.register(
            NetworkService.self,
            MockNetworkService()
        )

        // Mock repository
        let networkService = try! container.requireResolve(NetworkService.self)
        container.register(
            NewsRepositoryProtocol.self,
            NewsRepository(networkService: networkService)
        )

        // Mock use case
        container.register(
            NewsUseCaseProtocol.self,
            NewsUseCase(container: container)
        )
    }
}

// MARK: - Mock Network Service for Previews

private actor MockNetworkService: NetworkService {
    func request<T: Decodable>(endpoint: Endpoint) async throws -> T {
        // Return mock data for previews
        let mockResponse = NewsPageResponseDTO(
            page: 1,
            totalPages: 5,
            totalItems: 50,
            items: [
                NewsItemDTO(
                    id: "1",
                    title: "Sample News Title",
                    description: "This is a sample news description for preview purposes.",
                    imageURL: "https://picsum.photos/200",
                    publishedDate: "2026-02-13T10:00:00Z",
                    source: "Preview Source",
                    category: "Technology",
                    author: "Preview Author",
                    tags: ["preview", "test"]
                )
            ]
        )

        return mockResponse as! T
    }
}
