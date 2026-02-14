//
//  NewsUseCaseTests.swift
//  autoplayfeedTests
//
//  Created by Claude Code on 14.02.2026.
//

import Testing
import Foundation
@testable import autoplayfeed

@Suite("NewsUseCase Tests")
@MainActor
struct NewsUseCaseTests {
    
    // MARK: - Successful Fetch Tests
    
    @Test("Fetch news returns adapters when repository succeeds")
    func fetchNewsSuccess() async throws {
        // Given
        let mockRepository = MockNewsRepository()
        let mockResponse = Self.createMockResponse(page: 1, totalPages: 5, itemCount: 10)
        mockRepository.stubbedResponse = mockResponse
        
        let container = Self.createContainer(with: mockRepository)
        let useCase = NewsUseCase(container: container)
        
        // When
        let result = try await useCase.fetchNews(page: 1)
        
        // Then
        #expect(mockRepository.fetchNewsCallCount == 1)
        #expect(mockRepository.fetchNewsCalledWithPages == [1])
        #expect(result.count == 10)
        #expect(result.first?.id == "item-1")
        #expect(result.first?.title == "Test News 1")
    }
    
    @Test("Fetch news transforms domain models to adapters correctly")
    func fetchNewsTransformsToAdapters() async throws {
        // Given
        let mockRepository = MockNewsRepository()
        let mockResponse = Self.createMockResponse(page: 1, totalPages: 3, itemCount: 5)
        mockRepository.stubbedResponse = mockResponse
        
        let container = Self.createContainer(with: mockRepository)
        let useCase = NewsUseCase(container: container)
        
        // When
        let result = try await useCase.fetchNews(page: 1)
        
        // Then
        let firstAdapter = try #require(result.first)
        #expect(firstAdapter.id == "item-1")
        #expect(firstAdapter.title == "Test News 1")
        #expect(firstAdapter.description == "Description for news 1")
        #expect(firstAdapter.imageURL?.absoluteString == "https://example.com/image1.jpg")
        #expect(firstAdapter.source == "Test Source")
        #expect(firstAdapter.category == "Technology")
        #expect(firstAdapter.author == "Test Author 1")
        #expect(firstAdapter.tags == ["tech", "news"])
    }
    
    @Test("Fetch news caches total pages for pagination")
    func fetchNewsCachesTotalPages() async throws {
        // Given
        let mockRepository = MockNewsRepository()
        let mockResponse = Self.createMockResponse(page: 1, totalPages: 5, itemCount: 10)
        mockRepository.stubbedResponse = mockResponse
        
        let container = Self.createContainer(with: mockRepository)
        let useCase = NewsUseCase(container: container)
        
        // When
        let _ = try await useCase.fetchNews(page: 1)
        let hasMore = try await useCase.hasMorePages(currentPage: 1)
        
        // Then
        // hasMorePages should use cached value, not call repository again
        #expect(mockRepository.fetchNewsCallCount == 1)
        #expect(hasMore == true)
    }
    
    @Test("Fetch news handles multiple pages correctly")
    func fetchNewsMultiplePages() async throws {
        // Given
        let mockRepository = MockNewsRepository()
        let container = Self.createContainer(with: mockRepository)
        let useCase = NewsUseCase(container: container)
        
        // When - Fetch page 1
        mockRepository.stubbedResponse = Self.createMockResponse(page: 1, totalPages: 3, itemCount: 10)
        let page1 = try await useCase.fetchNews(page: 1)
        
        // When - Fetch page 2
        mockRepository.stubbedResponse = Self.createMockResponse(page: 2, totalPages: 3, itemCount: 10)
        let page2 = try await useCase.fetchNews(page: 2)
        
        // Then
        #expect(mockRepository.fetchNewsCallCount == 2)
        #expect(mockRepository.fetchNewsCalledWithPages == [1, 2])
        #expect(page1.count == 10)
        #expect(page2.count == 10)
    }
    
    // MARK: - hasMorePages Tests
    
    @Test("hasMorePages returns true when current page is less than total pages")
    func hasMorePagesReturnsTrue() async throws {
        // Given
        let mockRepository = MockNewsRepository()
        let mockResponse = Self.createMockResponse(page: 2, totalPages: 5, itemCount: 10)
        mockRepository.stubbedResponse = mockResponse
        
        let container = Self.createContainer(with: mockRepository)
        let useCase = NewsUseCase(container: container)
        
        // Fetch news first to cache total pages
        let _ = try await useCase.fetchNews(page: 2)
        
        // When
        let hasMore = try await useCase.hasMorePages(currentPage: 2)
        
        // Then
        #expect(hasMore == true)
    }
    
    @Test("hasMorePages returns false when on last page")
    func hasMorePagesReturnsFalse() async throws {
        // Given
        let mockRepository = MockNewsRepository()
        let mockResponse = Self.createMockResponse(page: 5, totalPages: 5, itemCount: 10)
        mockRepository.stubbedResponse = mockResponse
        
        let container = Self.createContainer(with: mockRepository)
        let useCase = NewsUseCase(container: container)
        
        // Fetch news first to cache total pages
        let _ = try await useCase.fetchNews(page: 5)
        
        // When
        let hasMore = try await useCase.hasMorePages(currentPage: 5)
        
        // Then
        #expect(hasMore == false)
    }
    
    @Test("hasMorePages fetches data when no cached total pages")
    func hasMorePagesFetchesWhenNoCachedData() async throws {
        // Given
        let mockRepository = MockNewsRepository()
        let mockResponse = Self.createMockResponse(page: 1, totalPages: 5, itemCount: 10)
        mockRepository.stubbedResponse = mockResponse
        
        let container = Self.createContainer(with: mockRepository)
        let useCase = NewsUseCase(container: container)
        
        // When - Call hasMorePages without fetching news first
        let hasMore = try await useCase.hasMorePages(currentPage: 1)
        
        // Then - Should fetch from repository
        #expect(mockRepository.fetchNewsCallCount == 1)
        #expect(hasMore == true)
    }
    
    @Test("hasMorePages uses cached value after initial fetch")
    func hasMorePagesUsesCachedValue() async throws {
        // Given
        let mockRepository = MockNewsRepository()
        let mockResponse = Self.createMockResponse(page: 1, totalPages: 5, itemCount: 10)
        mockRepository.stubbedResponse = mockResponse
        
        let container = Self.createContainer(with: mockRepository)
        let useCase = NewsUseCase(container: container)
        
        // Fetch news first to cache total pages
        let _ = try await useCase.fetchNews(page: 1)
        mockRepository.reset()
        
        // When - Call hasMorePages multiple times
        let hasMore1 = try await useCase.hasMorePages(currentPage: 1)
        let hasMore2 = try await useCase.hasMorePages(currentPage: 2)
        let hasMore3 = try await useCase.hasMorePages(currentPage: 3)
        
        // Then - Should not fetch from repository again
        #expect(mockRepository.fetchNewsCallCount == 0)
        #expect(hasMore1 == true)
        #expect(hasMore2 == true)
        #expect(hasMore3 == true)
    }
    
    // MARK: - Error Handling Tests
    
    @Test("Fetch news propagates NewsError from repository")
    func fetchNewsPropagatesNewsError() async throws {
        // Given
        let mockRepository = MockNewsRepository()
        mockRepository.shouldThrowError = .network(URLError(.notConnectedToInternet))
        
        let container = Self.createContainer(with: mockRepository)
        let useCase = NewsUseCase(container: container)
        
        // When/Then
        await #expect(throws: NewsError.self) {
            try await useCase.fetchNews(page: 1)
        }
    }
    
    @Test("Fetch news wraps unknown errors as NewsError.unknown")
    func fetchNewsWrapsUnknownErrors() async throws {
        // Given
        let mockRepository = MockNewsRepository()
        mockRepository.shouldThrowError = .unknown("Test error message")
        
        let container = Self.createContainer(with: mockRepository)
        let useCase = NewsUseCase(container: container)
        
        // When/Then
        await #expect(throws: NewsError.self) {
            try await useCase.fetchNews(page: 1)
        }
    }
    
    @Test("hasMorePages propagates errors from repository")
    func hasMorePagesPropagatesErrors() async throws {
        // Given
        let mockRepository = MockNewsRepository()
        mockRepository.shouldThrowError = .network(URLError(.notConnectedToInternet))
        
        let container = Self.createContainer(with: mockRepository)
        let useCase = NewsUseCase(container: container)
        
        // When/Then
        await #expect(throws: NewsError.self) {
            try await useCase.hasMorePages(currentPage: 1)
        }
    }
    
    @Test("Fetch news throws DIError when repository not registered")
    func fetchNewsThrowsWhenRepositoryNotRegistered() async throws {
        // Given
        let container = DIContainer() // Empty container
        let useCase = NewsUseCase(container: container)
        
        // When/Then
        await #expect(throws: (any Error).self) {
            try await useCase.fetchNews(page: 1)
        }
    }
    
    // MARK: - Edge Cases
    
    @Test("Fetch news handles empty items array")
    func fetchNewsHandlesEmptyItems() async throws {
        // Given
        let mockRepository = MockNewsRepository()
        let mockResponse = Self.createMockResponse(page: 1, totalPages: 1, itemCount: 0)
        mockRepository.stubbedResponse = mockResponse
        
        let container = Self.createContainer(with: mockRepository)
        let useCase = NewsUseCase(container: container)
        
        // When
        let result = try await useCase.fetchNews(page: 1)
        
        // Then
        #expect(result.isEmpty)
    }
    
    @Test("hasMorePages handles page beyond total pages")
    func hasMorePagesHandlesBeyondTotalPages() async throws {
        // Given
        let mockRepository = MockNewsRepository()
        let mockResponse = Self.createMockResponse(page: 5, totalPages: 5, itemCount: 10)
        mockRepository.stubbedResponse = mockResponse
        
        let container = Self.createContainer(with: mockRepository)
        let useCase = NewsUseCase(container: container)
        
        // Fetch news first to cache total pages
        let _ = try await useCase.fetchNews(page: 5)
        
        // When - Check for page beyond total
        let hasMore = try await useCase.hasMorePages(currentPage: 10)
        
        // Then
        #expect(hasMore == false)
    }
    
    @Test("Fetch news adapter contains formatted date string")
    func fetchNewsAdapterContainsFormattedDate() async throws {
        // Given
        let mockRepository = MockNewsRepository()
        let mockResponse = Self.createMockResponse(page: 1, totalPages: 1, itemCount: 1)
        mockRepository.stubbedResponse = mockResponse
        
        let container = Self.createContainer(with: mockRepository)
        let useCase = NewsUseCase(container: container)
        
        // When
        let result = try await useCase.fetchNews(page: 1)
        
        // Then
        let firstAdapter = try #require(result.first)
        #expect(!firstAdapter.formattedDate.isEmpty)
        // Should format as "Just now" since we created with Date()
        #expect(firstAdapter.formattedDate == "Just now")
    }
    
    @Test("Fetch news preserves order of items")
    func fetchNewsPreservesOrder() async throws {
        // Given
        let mockRepository = MockNewsRepository()
        let mockResponse = Self.createMockResponse(page: 1, totalPages: 1, itemCount: 5)
        mockRepository.stubbedResponse = mockResponse
        
        let container = Self.createContainer(with: mockRepository)
        let useCase = NewsUseCase(container: container)
        
        // When
        let result = try await useCase.fetchNews(page: 1)
        
        // Then
        #expect(result[0].id == "item-1")
        #expect(result[1].id == "item-2")
        #expect(result[2].id == "item-3")
        #expect(result[3].id == "item-4")
        #expect(result[4].id == "item-5")
    }
}

// MARK: - Mock NewsRepository

final class MockNewsRepository: NewsRepositoryProtocol, @unchecked Sendable {
    var fetchNewsCallCount = 0
    var fetchNewsCalledWithPages: [Int] = []
    var stubbedResponse: NewsPageResponse?
    var shouldThrowError: NewsError?
    
    func fetchNews(page: Int) async throws -> NewsPageResponse {
        fetchNewsCallCount += 1
        fetchNewsCalledWithPages.append(page)
        
        if let error = shouldThrowError {
            throw error
        }
        
        guard let response = stubbedResponse else {
            throw NewsError.unknown("No stubbed response")
        }
        
        return response
    }
    
    func reset() {
        fetchNewsCallCount = 0
        fetchNewsCalledWithPages = []
        stubbedResponse = nil
        shouldThrowError = nil
    }
}

// MARK: - Test Helpers

extension NewsUseCaseTests {
    @MainActor
    static func createMockResponse(page: Int = 1, totalPages: Int = 5, itemCount: Int = 10) -> NewsPageResponse {
        let items: [NewsItem]
        if itemCount > 0 {
            items = (1...itemCount).map { index in
                NewsItem(
                    id: "item-\(index)",
                    title: "Test News \(index)",
                    description: "Description for news \(index)",
                    imageURL: "https://example.com/image\(index).jpg",
                    publishedDate: Date(),
                    source: "Test Source",
                    category: "Technology",
                    author: "Test Author \(index)",
                    tags: ["tech", "news"]
                )
            }
        } else {
            items = []
        }
        
        return NewsPageResponse(
            page: page,
            totalPages: totalPages,
            totalItems: itemCount * totalPages,
            items: items
        )
    }
    
    @MainActor
    static func createContainer(with repository: NewsRepositoryProtocol) -> DIContainer {
        let container = DIContainer()
        container.register(NewsRepositoryProtocol.self, repository)
        return container
    }
}
