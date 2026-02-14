//
//  NewsRepository.swift
//  autoplayfeed
//
//  Created by Claude on 14.02.2026.
//

import Foundation

protocol NewsRepositoryProtocol {
    func fetchNews(page: Int, pageSize: Int) async throws -> NewsPageResponse
}

class NewsRepository: NewsRepositoryProtocol {
    private let apiClient: APIClient

    init(apiClient: APIClient = .shared) {
        self.apiClient = apiClient
    }

    func fetchNews(page: Int = 1, pageSize: Int = 20) async throws -> NewsPageResponse {
        let dto: NewsPageResponseDTO = try await apiClient.request(
            endpoint: "/news",
            parameters: ["page": String(page), "page_size": String(pageSize)]
        )
        return mapToDomain(dto)
    }

    // MARK: - Private Methods

    /// Parses an ISO8601 date string into a Date object.
    /// - Parameter dateString: The ISO8601 formatted date string
    /// - Returns: A Date object if parsing succeeds, nil otherwise
    /// - Note: Returns nil instead of Date() to prevent misleading "Just now" timestamps
    private func parseDate(_ dateString: String) -> Date? {
        let formatter = ISO8601DateFormatter()
        return formatter.date(from: dateString)
    }

    /// Maps a DTO to the domain model, filtering out items with invalid dates
    /// - Parameter dto: The NewsPageResponseDTO to map
    /// - Returns: A NewsPageResponse with only valid items
    private func mapToDomain(_ dto: NewsPageResponseDTO) -> NewsPageResponse {
        let items = dto.items.compactMap { itemDTO -> NewsItem? in
            guard let publishedDate = parseDate(itemDTO.publishedDate) else {
                print("⚠️ [Repository] Skipping item with invalid date: \(itemDTO.id)")
                return nil
            }

            return NewsItem(
                id: itemDTO.id,
                title: itemDTO.title,
                description: itemDTO.description,
                url: itemDTO.url,
                imageUrl: itemDTO.imageUrl,
                source: itemDTO.source,
                publishedDate: publishedDate,
                author: itemDTO.author,
                category: itemDTO.category
            )
        }

        return NewsPageResponse(
            items: items,
            totalCount: dto.totalCount,
            page: dto.page,
            pageSize: dto.pageSize,
            hasNextPage: dto.hasNextPage
        )
    }
}

// MARK: - APIClient (Placeholder)

class APIClient {
    static let shared = APIClient()

    func request<T: Decodable>(endpoint: String, parameters: [String: String]) async throws -> T {
        // Placeholder implementation
        throw NSError(domain: "APIClient", code: -1, userInfo: [NSLocalizedDescriptionKey: "Not implemented"])
    }
}
