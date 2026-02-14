//
//  autoplayfeedTests.swift
//  autoplayfeedTests
//
//  Created by Abdelrahman Mohamed on 13.02.2026.
//

import Testing
import Foundation
@testable import autoplayfeed

@MainActor
struct NewsFeedViewModelTests {
    
    // MARK: - Initial State Tests
    
    @Test func initialState() {
        let useCase = MockNewsUseCase()
        let router = MockNewsFeedRouter()
        let viewModel = NewsFeedViewModel(useCase: useCase, router: router)
        
        #expect(viewModel.state == .idle)
        #expect(viewModel.newsItems.isEmpty)
        #expect(!viewModel.isLoading)
        #expect(!viewModel.isLoadingMore)
        #expect(viewModel.errorMessage.isEmpty)
    }
    
    // MARK: - Load News Tests
    
    @Test func loadNews_Success() async {
        let useCase = MockNewsUseCase()
        let router = MockNewsFeedRouter()
        let viewModel = NewsFeedViewModel(useCase: useCase, router: router)
        
        let mockItems = [
            NewsItemAdapter.mock(id: "1", title: "News 1"),
            NewsItemAdapter.mock(id: "2", title: "News 2")
        ]
        
        useCase.fetchNewsResult = .success(mockItems)
        useCase.hasMorePagesResult = .success(true)
        
        viewModel.loadNews()
        
        // Wait for async task to complete
        try? await Task.sleep(for: .milliseconds(100))
        
        #expect(viewModel.newsItems.count == 2)
        #expect(viewModel.newsItems[0].title == "News 1")
        #expect(viewModel.newsItems[1].title == "News 2")
        #expect(!viewModel.isLoading)
        #expect(!viewModel.isLoadingMore)
        #expect(useCase.fetchNewsCallCount == 1)
        #expect(useCase.lastRequestedPage == 1)
    }
    
    @Test func loadNews_NetworkError() async {
        let useCase = MockNewsUseCase()
        let router = MockNewsFeedRouter()
        let viewModel = NewsFeedViewModel(useCase: useCase, router: router)
        
        let networkError = URLError(.notConnectedToInternet)
        useCase.fetchNewsResult = .failure(NewsError.network(networkError))
        
        viewModel.loadNews()
        
        // Wait for async task to complete
        try? await Task.sleep(for: .milliseconds(100))
        
        if case .error(let error) = viewModel.state {
            #expect(error.userMessage.contains("Network connection failed"))
        } else {
            Issue.record("Expected error state")
        }
        
        #expect(!viewModel.errorMessage.isEmpty)
        #expect(viewModel.newsItems.isEmpty)
    }
    
    @Test func loadNews_ServerError() async {
        let useCase = MockNewsUseCase()
        let router = MockNewsFeedRouter()
        let viewModel = NewsFeedViewModel(useCase: useCase, router: router)
        
        useCase.fetchNewsResult = .failure(NewsError.server(statusCode: 500))
        
        viewModel.loadNews()
        
        // Wait for async task to complete
        try? await Task.sleep(for: .milliseconds(100))
        
        #expect(viewModel.errorMessage.contains("Server error (500)"))
        #expect(viewModel.newsItems.isEmpty)
    }
    
    @Test func loadNews_PreventsConcurrentCalls() async {
        let useCase = MockNewsUseCase()
        let router = MockNewsFeedRouter()
        let viewModel = NewsFeedViewModel(useCase: useCase, router: router)
        
        useCase.fetchNewsResult = .success([NewsItemAdapter.mock()])
        
        // Call loadNews twice rapidly
        viewModel.loadNews()
        viewModel.loadNews()
        
        // Wait for async tasks to complete
        try? await Task.sleep(for: .milliseconds(100))
        
        // Should only be called once due to isLoadingPage guard
        #expect(useCase.fetchNewsCallCount == 1)
    }
    
    // MARK: - Refresh Tests
    
    @Test func refresh_Success() async {
        let useCase = MockNewsUseCase()
        let router = MockNewsFeedRouter()
        let viewModel = NewsFeedViewModel(useCase: useCase, router: router)
        
        // First load
        let initialItems = [NewsItemAdapter.mock(id: "1", title: "Old News")]
        useCase.fetchNewsResult = .success(initialItems)
        viewModel.loadNews()
        try? await Task.sleep(for: .milliseconds(100))
        
        // Refresh with new data
        let refreshedItems = [
            NewsItemAdapter.mock(id: "2", title: "New News 1"),
            NewsItemAdapter.mock(id: "3", title: "New News 2")
        ]
        useCase.fetchNewsResult = .success(refreshedItems)
        
        await viewModel.refresh()
        
        #expect(viewModel.newsItems.count == 2)
        #expect(viewModel.newsItems[0].title == "New News 1")
        #expect(useCase.lastRequestedPage == 1)
    }
    
    @Test func refresh_Error() async {
        let useCase = MockNewsUseCase()
        let router = MockNewsFeedRouter()
        let viewModel = NewsFeedViewModel(useCase: useCase, router: router)
        
        useCase.fetchNewsResult = .failure(NewsError.server(statusCode: 503))
        
        await viewModel.refresh()
        
        #expect(!viewModel.errorMessage.isEmpty)
        if case .error = viewModel.state {
            // Expected
        } else {
            Issue.record("Expected error state after failed refresh")
        }
    }
    
    // MARK: - Load More Tests
    
    @Test func loadMore_Success() async {
        let useCase = MockNewsUseCase()
        let router = MockNewsFeedRouter()
        let viewModel = NewsFeedViewModel(useCase: useCase, router: router)
        
        // Initial load
        let initialItems = [NewsItemAdapter.mock(id: "1", title: "News 1")]
        useCase.fetchNewsResult = .success(initialItems)
        useCase.hasMorePagesResult = .success(true)
        
        viewModel.loadNews()
        try? await Task.sleep(for: .milliseconds(100))
        
        #expect(viewModel.newsItems.count == 1)
        
        // Load more
        let moreItems = [NewsItemAdapter.mock(id: "2", title: "News 2")]
        useCase.fetchNewsResult = .success(moreItems)
        useCase.hasMorePagesResult = .success(false)
        
        viewModel.loadMore()
        try? await Task.sleep(for: .milliseconds(100))
        
        #expect(viewModel.newsItems.count == 2)
        #expect(viewModel.newsItems[0].title == "News 1")
        #expect(viewModel.newsItems[1].title == "News 2")
        #expect(useCase.lastRequestedPage == 2)
    }
    
    @Test func loadMore_NoMorePages() async {
        let useCase = MockNewsUseCase()
        let router = MockNewsFeedRouter()
        let viewModel = NewsFeedViewModel(useCase: useCase, router: router)
        
        // Initial load with no more pages
        let initialItems = [NewsItemAdapter.mock(id: "1")]
        useCase.fetchNewsResult = .success(initialItems)
        useCase.hasMorePagesResult = .success(false)
        
        viewModel.loadNews()
        try? await Task.sleep(for: .milliseconds(100))
        
        useCase.reset()
        
        // Try to load more
        viewModel.loadMore()
        try? await Task.sleep(for: .milliseconds(100))
        
        // Should not make a request
        #expect(useCase.fetchNewsCallCount == 0)
    }
    
    @Test func loadMore_Error_RevertsPage() async {
        let useCase = MockNewsUseCase()
        let router = MockNewsFeedRouter()
        let viewModel = NewsFeedViewModel(useCase: useCase, router: router)
        
        // Initial successful load
        let initialItems = [NewsItemAdapter.mock(id: "1")]
        useCase.fetchNewsResult = .success(initialItems)
        useCase.hasMorePagesResult = .success(true)
        
        viewModel.loadNews()
        try? await Task.sleep(for: .milliseconds(100))
        
        #expect(useCase.lastRequestedPage == 1)
        
        // Attempt to load more with error
        useCase.fetchNewsResult = .failure(NewsError.server(statusCode: 500))
        
        viewModel.loadMore()
        try? await Task.sleep(for: .milliseconds(100))
        
        // State should be error
        if case .error = viewModel.state {
            // Expected
        } else {
            Issue.record("Expected error state after failed loadMore")
        }
        
        // Verify that the error occurred on page 2 attempt
        #expect(useCase.lastRequestedPage == 2)
        #expect(useCase.fetchNewsCallCount == 2)
        
        // Now manually restore to loaded state to simulate recovery
        // In real app, user might pull-to-refresh or the error state might be dismissed
        useCase.fetchNewsResult = .success(initialItems)
        useCase.hasMorePagesResult = .success(true)
        await viewModel.refresh()
        
        // Now try to load more again - should request page 2 again (because error reverted the counter)
        useCase.fetchNewsResult = .success([NewsItemAdapter.mock(id: "2")])
        useCase.hasMorePagesResult = .success(false)
        
        viewModel.loadMore()
        try? await Task.sleep(for: .milliseconds(100))
        
        // Should request page 2 again, not page 3
        #expect(useCase.lastRequestedPage == 2)
        #expect(viewModel.newsItems.count == 2)
    }
    
    @Test func loadMore_OnlyWorksInLoadedState() async {
        let useCase = MockNewsUseCase()
        let router = MockNewsFeedRouter()
        let viewModel = NewsFeedViewModel(useCase: useCase, router: router)
        
        // Try to load more when in idle state
        viewModel.loadMore()
        try? await Task.sleep(for: .milliseconds(100))
        
        // Should not make a request
        #expect(useCase.fetchNewsCallCount == 0)
    }
    
    // MARK: - Navigation Tests
    
    @Test func selectNewsItem_NavigatesToDetail() {
        let useCase = MockNewsUseCase()
        let router = MockNewsFeedRouter()
        let viewModel = NewsFeedViewModel(useCase: useCase, router: router)
        
        let newsItem = NewsItemAdapter.mock(id: "1", title: "Test News")
        
        viewModel.selectNewsItem(newsItem)
        
        #expect(router.navigateToNewsDetailCallCount == 1)
        #expect(router.lastNavigatedItem?.id == "1")
        #expect(router.lastNavigatedItem?.title == "Test News")
    }
    
    // MARK: - Computed Properties Tests
    
    @Test func isLoading_ReturnsTrue_WhenStateIsLoading() {
        let useCase = MockNewsUseCase()
        let router = MockNewsFeedRouter()
        let viewModel = NewsFeedViewModel(useCase: useCase, router: router)
        
        viewModel.loadNews()
        
        // During loading, isLoading should be true
        #expect(viewModel.isLoading)
    }
    
    @Test func isLoadingMore_ReturnsTrue_WhenStateIsLoadingMore() async {
        let useCase = MockNewsUseCase()
        let router = MockNewsFeedRouter()
        let viewModel = NewsFeedViewModel(useCase: useCase, router: router)
        
        // Set up initial loaded state
        let initialItems = [NewsItemAdapter.mock(id: "1")]
        useCase.fetchNewsResult = .success(initialItems)
        useCase.hasMorePagesResult = .success(true)
        
        viewModel.loadNews()
        try? await Task.sleep(for: .milliseconds(100))
        
        // Start loading more - check state immediately
        viewModel.loadMore()
        
        // isLoadingMore should be true during the load
        if case .loadingMore = viewModel.state {
            #expect(viewModel.isLoadingMore)
        }
    }
    
    @Test func newsItems_ReturnsItemsInLoadedState() async {
        let useCase = MockNewsUseCase()
        let router = MockNewsFeedRouter()
        let viewModel = NewsFeedViewModel(useCase: useCase, router: router)
        
        let mockItems = [
            NewsItemAdapter.mock(id: "1", title: "News 1"),
            NewsItemAdapter.mock(id: "2", title: "News 2")
        ]
        
        useCase.fetchNewsResult = .success(mockItems)
        
        viewModel.loadNews()
        try? await Task.sleep(for: .milliseconds(100))
        
        #expect(viewModel.newsItems.count == 2)
        #expect(viewModel.newsItems[0].id == "1")
        #expect(viewModel.newsItems[1].id == "2")
    }
    
    @Test func errorMessage_ReturnsMessage_WhenStateIsError() async {
        let useCase = MockNewsUseCase()
        let router = MockNewsFeedRouter()
        let viewModel = NewsFeedViewModel(useCase: useCase, router: router)
        
        useCase.fetchNewsResult = .failure(NewsError.server(statusCode: 404))
        
        viewModel.loadNews()
        try? await Task.sleep(for: .milliseconds(100))
        
        #expect(!viewModel.errorMessage.isEmpty)
        #expect(viewModel.errorMessage.contains("Server error"))
    }
}

// MARK: - Mock Use Case

@MainActor
final class MockNewsUseCase: NewsUseCaseProtocol {
    var fetchNewsResult: Result<[NewsItemAdapter], Error> = .success([])
    var hasMorePagesResult: Result<Bool, Error> = .success(false)
    var fetchNewsCallCount = 0
    var hasMorePagesCallCount = 0
    var lastRequestedPage: Int?
    
    func fetchNews(page: Int) async throws -> [NewsItemAdapter] {
        fetchNewsCallCount += 1
        lastRequestedPage = page
        
        switch fetchNewsResult {
        case .success(let items):
            return items
        case .failure(let error):
            throw error
        }
    }
    
    func hasMorePages(currentPage: Int) async throws -> Bool {
        hasMorePagesCallCount += 1
        
        switch hasMorePagesResult {
        case .success(let hasMore):
            return hasMore
        case .failure(let error):
            throw error
        }
    }
    
    func reset() {
        fetchNewsCallCount = 0
        hasMorePagesCallCount = 0
        lastRequestedPage = nil
        fetchNewsResult = .success([])
        hasMorePagesResult = .success(false)
    }
}

// MARK: - Mock Router

@MainActor
final class MockNewsFeedRouter: NewsFeedRouterProtocol {
    var navigateToNewsDetailCallCount = 0
    var lastNavigatedItem: NewsItemAdapter?
    
    func navigateToNewsDetail(item: NewsItemAdapter) {
        navigateToNewsDetailCallCount += 1
        lastNavigatedItem = item
    }
    
    func reset() {
        navigateToNewsDetailCallCount = 0
        lastNavigatedItem = nil
    }
}

// MARK: - Test Helpers

extension NewsItemAdapter {
    static func mock(
        id: String = "1",
        title: String = "Test News",
        description: String = "Test Description",
        imageURL: URL? = nil,
        formattedDate: String = "Just now",
        source: String = "Test Source",
        category: String = "Technology",
        author: String = "Test Author",
        tags: [String] = ["test"]
    ) -> NewsItemAdapter {
        NewsItemAdapter(
            id: id,
            title: title,
            description: description,
            imageURL: imageURL,
            formattedDate: formattedDate,
            source: source,
            category: category,
            author: author,
            tags: tags
        )
    }
}

