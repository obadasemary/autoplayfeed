//
//  NewsFeedViewModel.swift
//  autoplayfeed
//
//  Created by Claude Code on 13.02.2026.
//

import Foundation
import Observation

/// ViewModel managing news feed state and user interactions
@MainActor
@Observable
final class NewsFeedViewModel {
    // MARK: - State Machine

    enum State: Equatable {
        case idle
        case loading
        case loaded([NewsItemAdapter])
        case error(NewsError)
        case loadingMore([NewsItemAdapter])

        static func == (lhs: State, rhs: State) -> Bool {
            switch (lhs, rhs) {
            case (.idle, .idle), (.loading, .loading):
                return true
            case (.loaded(let lhsItems), .loaded(let rhsItems)):
                return lhsItems == rhsItems
            case (.error, .error):
                return true
            case (.loadingMore(let lhsItems), .loadingMore(let rhsItems)):
                return lhsItems == rhsItems
            default:
                return false
            }
        }
    }

    // MARK: - Properties

    private(set) var state: State = .idle
    private let useCase: NewsUseCaseProtocol
    private let router: NewsFeedRouterProtocol

    private var currentPage = 0
    private var isLoadingPage = false
    private var hasMorePages = true

    /// Error message to display as a toast notification for pagination errors
    private(set) var paginationErrorMessage: String?

    // MARK: - Computed Properties

    var isLoading: Bool {
        if case .loading = state { return true }
        return false
    }

    var isLoadingMore: Bool {
        if case .loadingMore = state { return true }
        return false
    }

    var errorMessage: String {
        if case .error(let newsError) = state {
            return newsError.userMessage
        }
        return ""
    }

    var newsItems: [NewsItemAdapter] {
        switch state {
        case .loaded(let items), .loadingMore(let items):
            return items
        default:
            return []
        }
    }

    // MARK: - Initialization

    init(useCase: NewsUseCaseProtocol, router: NewsFeedRouterProtocol) {
        self.useCase = useCase
        self.router = router
    }

    // MARK: - User Actions

    /// Loads the first page of news
    func loadNews() {
        print("🚀 [ViewModel] loadNews() called")
        guard !isLoadingPage else {
            print("⚠️ [ViewModel] Already loading, skipping")
            return
        }

        isLoadingPage = true
        currentPage = 1
        state = .loading
        print("📊 [ViewModel] State changed to: loading")

        Task {
            defer { isLoadingPage = false }

            do {
                print("🔄 [ViewModel] Fetching page \(currentPage)...")
                let items = try await useCase.fetchNews(page: currentPage)
                print("✅ [ViewModel] Received \(items.count) items")

                hasMorePages = try await useCase.hasMorePages(currentPage: currentPage)
                print("📄 [ViewModel] Has more pages: \(hasMorePages)")

                state = .loaded(items)
                print("📊 [ViewModel] State changed to: loaded with \(items.count) items")
            } catch let error as NewsError {
                print("❌ [ViewModel] NewsError: \(error)")
                print("   User message: \(error.userMessage)")
                state = .error(error)
                print("📊 [ViewModel] State changed to: error")
            } catch {
                print("❌ [ViewModel] Unknown error: \(error.localizedDescription)")
                state = .error(.unknown(error.localizedDescription))
                print("📊 [ViewModel] State changed to: error")
            }
        }
    }

    /// Refreshes the news feed (pull-to-refresh)
    func refresh() async {
        print("🔄 [ViewModel] refresh() called")
        guard !isLoadingPage else {
            print("⚠️ [ViewModel] Already loading, skipping refresh")
            return
        }

        isLoadingPage = true
        currentPage = 1
        print("📊 [ViewModel] Refreshing page 1...")

        defer { isLoadingPage = false }

        do {
            let items = try await useCase.fetchNews(page: 1)
            print("✅ [ViewModel] Refresh received \(items.count) items")

            hasMorePages = try await useCase.hasMorePages(currentPage: 1)
            state = .loaded(items)
            print("📊 [ViewModel] Refresh complete, state: loaded")
        } catch let error as NewsError {
            print("❌ [ViewModel] Refresh error: \(error)")
            state = .error(error)
        } catch {
            print("❌ [ViewModel] Refresh unknown error: \(error.localizedDescription)")
            state = .error(.unknown(error.localizedDescription))
        }
    }

    /// Loads the next page of news (infinite scroll)
    func loadMore() {
        print("📄 [ViewModel] loadMore() called")
        guard !isLoadingPage else {
            print("⚠️ [ViewModel] Already loading, skipping loadMore")
            return
        }
        guard hasMorePages else {
            print("⚠️ [ViewModel] No more pages, skipping loadMore")
            return
        }
        guard case .loaded(let existingItems) = state else {
            print("⚠️ [ViewModel] State is not loaded, skipping loadMore")
            return
        }

        isLoadingPage = true
        currentPage += 1
        print("📊 [ViewModel] Loading page \(currentPage)...")
        state = .loadingMore(existingItems)
        print("📊 [ViewModel] State changed to: loadingMore")

        Task {
            defer { isLoadingPage = false }

            do {
                let newItems = try await useCase.fetchNews(page: currentPage)
                print("✅ [ViewModel] LoadMore received \(newItems.count) new items")

                hasMorePages = try await useCase.hasMorePages(currentPage: currentPage)
                print("📄 [ViewModel] Has more pages: \(hasMorePages)")

                state = .loaded(existingItems + newItems)
                print("📊 [ViewModel] State: loaded with \(existingItems.count + newItems.count) total items")
            } catch let error as NewsError {
                print("❌ [ViewModel] LoadMore error: \(error)")
                paginationErrorMessage = error.userMessage
                state = .loaded(existingItems) // Preserve existing items
                currentPage -= 1 // Revert page on error
                print("⏪ [ViewModel] Reverted to page \(currentPage), keeping \(existingItems.count) items")
            } catch {
                print("❌ [ViewModel] LoadMore unknown error: \(error.localizedDescription)")
                paginationErrorMessage = error.localizedDescription
                state = .loaded(existingItems) // Preserve existing items
                currentPage -= 1 // Revert page on error
                print("⏪ [ViewModel] Reverted to page \(currentPage), keeping \(existingItems.count) items")
            }
        }
    }

    /// Navigates to news detail
    func selectNewsItem(_ item: NewsItemAdapter) {
        print("👆 [ViewModel] Selected news item: \(item.title)")
        router.navigateToNewsDetail(item: item)
    }

    /// Clears the pagination error message (used for dismissing toast notifications)
    func clearPaginationError() {
        paginationErrorMessage = nil
    }
}
