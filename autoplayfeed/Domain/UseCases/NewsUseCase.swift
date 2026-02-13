//
//  NewsUseCase.swift
//  autoplayfeed
//
//  Created by Claude Code on 13.02.2026.
//

import Foundation

/// Implementation of NewsUseCaseProtocol handling business logic
@MainActor
final class NewsUseCase: NewsUseCaseProtocol {
    private let container: DIContainer
    private var cachedTotalPages: Int?

    /// Lazy resolution of repository to avoid circular dependency
    private var repository: NewsRepositoryProtocol {
        get throws {
            try container.requireResolve(NewsRepositoryProtocol.self)
        }
    }

    nonisolated init(container: DIContainer) {
        self.container = container
    }

    func fetchNews(page: Int) async throws -> [NewsItemAdapter] {
        print("🎯 [UseCase] Fetching news for page \(page)...")
        do {
            let response = try await repository.fetchNews(page: page)

            print("✅ [UseCase] Received response with \(response.items.count) items")

            // Cache total pages for pagination logic
            cachedTotalPages = response.totalPages
            print("📝 [UseCase] Cached total pages: \(response.totalPages)")

            // Transform domain models to adapters
            let adapters = response.items.map { NewsItemAdapter.from($0) }
            print("✅ [UseCase] Transformed to \(adapters.count) adapters")

            // Log first item for debugging
            if let first = adapters.first {
                print("📰 [UseCase] First item: \(first.title)")
            }

            return adapters
        } catch let error as NewsError {
            print("❌ [UseCase] News error: \(error)")
            throw error
        } catch {
            print("❌ [UseCase] Unknown error: \(error.localizedDescription)")
            throw NewsError.unknown(error.localizedDescription)
        }
    }

    func hasMorePages(currentPage: Int) async throws -> Bool {
        // If we have cached total pages, use that
        if let totalPages = cachedTotalPages {
            return currentPage < totalPages
        }

        // Otherwise, fetch and check
        do {
            let response = try await repository.fetchNews(page: currentPage)
            cachedTotalPages = response.totalPages
            return response.hasMorePages
        } catch let error as NewsError {
            throw error
        } catch {
            throw NewsError.unknown(error.localizedDescription)
        }
    }
}
