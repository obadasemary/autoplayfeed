//
//  NewsRepository.swift
//  autoplayfeed
//
//  Created by Claude Code on 13.02.2026.
//

import Foundation

/// Actor-based implementation of NewsRepositoryProtocol
actor NewsRepository: NewsRepositoryProtocol {
    private let networkService: NetworkService

    init(networkService: NetworkService) {
        self.networkService = networkService
    }

    func fetchNews(page: Int) async throws -> NewsPageResponse {
        print("📚 [Repository] Fetching news for page \(page)...")
        do {
            // Fetch data from network
            let dto: NewsPageResponseDTO = try await networkService.request(
                endpoint: NewsAPI.feed(page: page)
            )

            print("✅ [Repository] Received DTO with \(dto.items.count) items")
            print("   - Page: \(dto.page)/\(dto.totalPages)")
            print("   - Total items: \(dto.totalItems)")

            // Map DTO to domain model
            let domainModel = mapToDomain(dto)
            print("✅ [Repository] Mapped to domain model with \(domainModel.items.count) items")
            return domainModel
        } catch let error as NetworkError {
            print("❌ [Repository] Network error: \(error)")
            // Map network errors to domain errors
            throw mapNetworkError(error)
        } catch {
            print("❌ [Repository] Unknown error: \(error.localizedDescription)")
            throw NewsError.unknown(error.localizedDescription)
        }
    }

    // MARK: - Private Mapping Methods

    private func mapToDomain(_ dto: NewsPageResponseDTO) -> NewsPageResponse {
        let items = dto.items.map { itemDTO -> NewsItem in
            NewsItem(
                id: itemDTO.id,
                title: itemDTO.title,
                description: itemDTO.description,
                imageURL: itemDTO.imageURL,
                publishedDate: parseDate(itemDTO.publishedDate),
                source: itemDTO.source,
                category: itemDTO.category,
                author: itemDTO.author,
                tags: itemDTO.tags
            )
        }

        return NewsPageResponse(
            page: dto.page,
            totalPages: dto.totalPages,
            totalItems: dto.totalItems,
            items: items
        )
    }

    private func parseDate(_ dateString: String) -> Date {
        let formatter = ISO8601DateFormatter()
        return formatter.date(from: dateString) ?? Date()
    }

    private func mapNetworkError(_ error: NetworkError) -> NewsError {
        switch error {
        case .networkError(let urlError):
            return .network(urlError)
        case .decodingError(let decodingError):
            return .decoding(decodingError)
        case .serverError(let statusCode):
            return .server(statusCode: statusCode)
        case .invalidURL, .invalidResponse:
            return .unknown("Invalid request configuration")
        case .unknown(let message):
            return .unknown(message)
        }
    }
}
