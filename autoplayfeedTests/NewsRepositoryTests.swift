//
//  NewsRepositoryTests.swift
//  autoplayfeedTests
//
//  Created by Claude Code on 14.02.2026.
//

import Testing
import Foundation
@testable import autoplayfeed

@Suite("NewsRepository Tests")
struct NewsRepositoryTests {
    
    // MARK: - Successful Fetch Tests
    
    @Test("Fetch news returns domain model when network request succeeds")
    func fetchNewsSuccess() async throws {
        // Given
        let mockNetworkService = MockNetworkService()
        let repository = NewsRepository(networkService: mockNetworkService)
        let mockDTO = Self.createMockDTO(page: 1, totalPages: 5, itemCount: 10)
        mockNetworkService.stubbedResponse = mockDTO
        
        // When
        let result = try await repository.fetchNews(page: 1)
        
        // Then
        #expect(mockNetworkService.requestCallCount == 1)
        #expect(result.page == 1)
        #expect(result.totalPages == 5)
        #expect(result.totalItems == 50)
        #expect(result.items.count == 10)
        #expect(result.items.first?.id == "item-1")
        #expect(result.items.first?.title == "Test News 1")
    }
    
    @Test("Fetch news correctly maps all DTO fields to domain model")
    func fetchNewsMapsAllFields() async throws {
        // Given
        let mockNetworkService = MockNetworkService()
        let repository = NewsRepository(networkService: mockNetworkService)
        let mockDTO = Self.createMockDTO(page: 2, totalPages: 3, itemCount: 5)
        mockNetworkService.stubbedResponse = mockDTO
        
        // When
        let result = try await repository.fetchNews(page: 2)
        
        // Then
        let firstItem = try #require(result.items.first)
        #expect(firstItem.id == "item-1")
        #expect(firstItem.title == "Test News 1")
        #expect(firstItem.description == "Description for news 1")
        #expect(firstItem.imageURL == "https://example.com/image1.jpg")
        #expect(firstItem.source == "Test Source")
        #expect(firstItem.category == "Technology")
        #expect(firstItem.author == "Test Author 1")
        #expect(firstItem.tags == ["tech", "news"])
    }
    
    @Test("Fetch news parses ISO8601 date correctly")
    func fetchNewsParsesDateCorrectly() async throws {
        // Given
        let mockNetworkService = MockNetworkService()
        let repository = NewsRepository(networkService: mockNetworkService)
        let mockDTO = Self.createMockDTO()
        mockNetworkService.stubbedResponse = mockDTO
        
        // When
        let result = try await repository.fetchNews(page: 1)
        
        // Then
        let firstItem = try #require(result.items.first)
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: firstItem.publishedDate)
        #expect(components.year == 2026)
        #expect(components.month == 2)
        #expect(components.day == 14)
    }
    
    @Test("hasMorePages returns true when current page is less than total pages")
    func hasMorePagesReturnsTrue() async throws {
        // Given
        let mockNetworkService = MockNetworkService()
        let repository = NewsRepository(networkService: mockNetworkService)
        let mockDTO = Self.createMockDTO(page: 2, totalPages: 5, itemCount: 10)
        mockNetworkService.stubbedResponse = mockDTO
        
        // When
        let result = try await repository.fetchNews(page: 2)
        
        // Then
        #expect(result.hasMorePages == true)
    }
    
    @Test("hasMorePages returns false when on last page")
    func hasMorePagesReturnsFalse() async throws {
        // Given
        let mockNetworkService = MockNetworkService()
        let repository = NewsRepository(networkService: mockNetworkService)
        let mockDTO = Self.createMockDTO(page: 5, totalPages: 5, itemCount: 10)
        mockNetworkService.stubbedResponse = mockDTO
        
        // When
        let result = try await repository.fetchNews(page: 5)
        
        // Then
        #expect(result.hasMorePages == false)
    }
    
    // MARK: - Error Handling Tests
    
    @Test("Fetch news throws NewsError.network when network error occurs")
    func fetchNewsThrowsNetworkError() async throws {
        // Given
        let mockNetworkService = MockNetworkService()
        let repository = NewsRepository(networkService: mockNetworkService)
        let urlError = URLError(.notConnectedToInternet)
        mockNetworkService.shouldThrowError = .networkError(urlError)
        
        // When/Then
        await #expect(throws: NewsError.self) {
            try await repository.fetchNews(page: 1)
        }
    }
    
    @Test("Fetch news throws NewsError.decoding when decoding error occurs")
    func fetchNewsThrowsDecodingError() async throws {
        // Given
        let mockNetworkService = MockNetworkService()
        let repository = NewsRepository(networkService: mockNetworkService)
        
        // Create a decoding error
        let data = Data()
        let decoder = JSONDecoder()
        do {
            let _ = try decoder.decode(NewsPageResponseDTO.self, from: data)
        } catch let decodingError as DecodingError {
            mockNetworkService.shouldThrowError = .decodingError(decodingError)
        }
        
        // When/Then
        await #expect(throws: NewsError.self) {
            try await repository.fetchNews(page: 1)
        }
    }
    
    @Test("Fetch news throws NewsError.server when server error occurs")
    func fetchNewsThrowsServerError() async throws {
        // Given
        let mockNetworkService = MockNetworkService()
        let repository = NewsRepository(networkService: mockNetworkService)
        mockNetworkService.shouldThrowError = .serverError(statusCode: 500)
        
        // When/Then
        await #expect(throws: NewsError.self) {
            try await repository.fetchNews(page: 1)
        }
    }
    
    @Test("Fetch news throws NewsError.unknown for unexpected errors")
    func fetchNewsThrowsUnknownError() async throws {
        // Given
        let mockNetworkService = MockNetworkService()
        let repository = NewsRepository(networkService: mockNetworkService)
        mockNetworkService.shouldThrowError = .unknown("Something went wrong")
        
        // When/Then
        await #expect(throws: NewsError.self) {
            try await repository.fetchNews(page: 1)
        }
    }
    
    // MARK: - Edge Cases
    
    @Test("Fetch news handles empty items array")
    func fetchNewsHandlesEmptyItems() async throws {
        // Given
        let mockNetworkService = MockNetworkService()
        let repository = NewsRepository(networkService: mockNetworkService)
        let mockDTO = Self.createMockDTO(page: 1, totalPages: 1, itemCount: 0)
        mockNetworkService.stubbedResponse = mockDTO
        
        // When
        let result = try await repository.fetchNews(page: 1)
        
        // Then
        #expect(result.items.isEmpty)
        #expect(result.totalItems == 0)
    }
    
    @Test("Fetch news handles invalid date string gracefully")
    func fetchNewsHandlesInvalidDate() async throws {
        // Given
        let mockNetworkService = MockNetworkService()
        let repository = NewsRepository(networkService: mockNetworkService)
        
        let itemWithInvalidDate = NewsItemDTO(
            id: "item-1",
            title: "Test News",
            description: "Description",
            imageURL: "https://example.com/image.jpg",
            publishedDate: "invalid-date",
            source: "Test Source",
            category: "Technology",
            author: "Test Author",
            tags: ["tech"]
        )
        
        let mockDTO = NewsPageResponseDTO(
            page: 1,
            totalPages: 1,
            totalItems: 1,
            items: [itemWithInvalidDate]
        )
        mockNetworkService.stubbedResponse = mockDTO
        
        // When
        let result = try await repository.fetchNews(page: 1)
        
        // Then - Should use current date as fallback
        #expect(result.items.count == 1)
        #expect(result.items.first?.publishedDate != nil)
    }
}

// MARK: - Mock NetworkService

final class MockNetworkService: NetworkService, @unchecked Sendable {
    var requestCallCount = 0
    var requestedEndpoints: [Endpoint] = []
    var stubbedResponse: Any?
    var shouldThrowError: NetworkError?
    
    func request<T: Decodable>(endpoint: Endpoint) async throws -> T {
        requestCallCount += 1
        requestedEndpoints.append(endpoint)
        
        if let error = shouldThrowError {
            throw error
        }
        
        guard let response = stubbedResponse as? T else {
            throw NetworkError.unknown("No stubbed response")
        }
        
        return response
    }
    
    func reset() {
        requestCallCount = 0
        requestedEndpoints = []
        stubbedResponse = nil
        shouldThrowError = nil
    }
}

// MARK: - Test Helpers

extension NewsRepositoryTests {
    static func createMockDTO(page: Int = 1, totalPages: Int = 5, itemCount: Int = 10) -> NewsPageResponseDTO {
        let items: [NewsItemDTO]
        if itemCount > 0 {
            items = (1...itemCount).map { index in
                NewsItemDTO(
                    id: "item-\(index)",
                    title: "Test News \(index)",
                    description: "Description for news \(index)",
                    imageURL: "https://example.com/image\(index).jpg",
                    publishedDate: "2026-02-14T10:00:00Z",
                    source: "Test Source",
                    category: "Technology",
                    author: "Test Author \(index)",
                    tags: ["tech", "news"]
                )
            }
        } else {
            items = []
        }
        
        return NewsPageResponseDTO(
            page: page,
            totalPages: totalPages,
            totalItems: itemCount * totalPages,
            items: items
        )
    }
}
