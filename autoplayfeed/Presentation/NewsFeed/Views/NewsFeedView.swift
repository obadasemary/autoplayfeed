//
//  NewsFeedView.swift
//  autoplayfeed
//
//  Created by Claude Code on 13.02.2026.
//

import SwiftUI

/// Main news feed view displaying paginated news items
struct NewsFeedView: View {
    @State private var viewModel: NewsFeedViewModel
    @State private var router: NewsFeedRouter

    init(viewModel: NewsFeedViewModel, router: NewsFeedRouter) {
        self.viewModel = viewModel
        self.router = router
    }

    var body: some View {
        NavigationStack(path: $router.navigationPath) {
            Group {
                switch viewModel.state {
                case .idle, .loading:
                    LoadingView(message: "Fetching news...")

                case .loaded(let items), .loadingMore(let items):
                    newsList(items)

                case .error(let error):
                    ErrorView(
                        message: error.userMessage,
                        retry: { viewModel.loadNews() }
                    )
                }
            }
            .navigationTitle("News Feed")
            .navigationDestination(for: NewsFeedDestination.self) { destination in
                switch destination {
                case .newsDetail(let item):
                    NewsDetailView(item: item)
                }
            }
            .onAppear {
                if case .idle = viewModel.state {
                    viewModel.loadNews()
                }
            }
            .overlay(alignment: .bottom) {
                if let toast = viewModel.toastMessage {
                    Text(toast)
                        .font(.subheadline)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(.red.opacity(0.9), in: RoundedRectangle(cornerRadius: 10))
                        .padding(.bottom, 16)
                        .padding(.horizontal, 16)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .onTapGesture {
                            viewModel.dismissToast()
                        }
                }
            }
            .animation(.easeInOut, value: viewModel.toastMessage)
        }
    }

    // MARK: - Private Views

    @ViewBuilder
    private func newsList(_ items: [NewsItemAdapter]) -> some View {
        List {
            ForEach(items) { item in
                NewsItemRowView(item: item)
                    .onTapGesture {
                        viewModel.selectNewsItem(item)
                    }
                    .onAppear {
                        // Trigger pagination when last item appears
                        if item == items.last {
                            viewModel.loadMore()
                        }
                    }
            }

            // Loading indicator at bottom while loading more
            if viewModel.isLoadingMore {
                HStack {
                    Spacer()
                    ProgressView()
                        .padding()
                    Spacer()
                }
                .listRowSeparator(.hidden)
            }
        }
        .listStyle(.plain)
        .refreshable {
            await viewModel.refresh()
        }
    }
}

#Preview("Loading") {
    let container = DIContainer()
    let mockRouter = NewsFeedRouter()

    // Create a fake use case that never completes
    struct FakeLoadingUseCase: NewsUseCaseProtocol {
        func fetchNews(page: Int) async throws -> [NewsItemAdapter] {
            try await Task.sleep(nanoseconds: 1_000_000_000_000) // Never completes
            return []
        }

        func hasMorePages(currentPage: Int) async throws -> Bool {
            true
        }
    }

    let viewModel = NewsFeedViewModel(
        useCase: FakeLoadingUseCase(),
        router: mockRouter
    )

    Task { @MainActor in
        viewModel.loadNews()
    }

    return NewsFeedView(viewModel: viewModel, router: mockRouter)
}

#Preview("Loaded") {
    let container = DIContainer()
    let mockRouter = NewsFeedRouter()

    // Create a fake use case with sample data
    struct FakeLoadedUseCase: NewsUseCaseProtocol {
        func fetchNews(page: Int) async throws -> [NewsItemAdapter] {
            [
                NewsItemAdapter(
                    id: "1",
                    title: "AI Breakthrough: New Model Achieves Human-Level Performance",
                    description: "Researchers announce a revolutionary AI model that performs on par with humans across multiple benchmarks.",
                    imageURL: URL(string: "https://picsum.photos/200/200?1"),
                    formattedDate: "2 hours ago",
                    source: "Tech News",
                    category: "Technology",
                    author: "Jane Smith",
                    tags: ["AI", "Research"]
                ),
                NewsItemAdapter(
                    id: "2",
                    title: "Global Climate Summit Reaches Historic Agreement",
                    description: "World leaders sign comprehensive climate action plan with binding targets for emissions reduction.",
                    imageURL: URL(string: "https://picsum.photos/200/200?2"),
                    formattedDate: "5 hours ago",
                    source: "World News",
                    category: "Environment",
                    author: "John Doe",
                    tags: ["Climate", "Politics"]
                ),
                NewsItemAdapter(
                    id: "3",
                    title: "New Study Reveals Benefits of Mediterranean Diet",
                    description: "Long-term research shows significant health improvements for those following Mediterranean eating patterns.",
                    imageURL: URL(string: "https://picsum.photos/200/200?3"),
                    formattedDate: "1 day ago",
                    source: "Health Today",
                    category: "Health",
                    author: "Dr. Sarah Johnson",
                    tags: ["Health", "Nutrition"]
                )
            ]
        }

        func hasMorePages(currentPage: Int) async throws -> Bool {
            true
        }
    }

    let viewModel = NewsFeedViewModel(
        useCase: FakeLoadedUseCase(),
        router: mockRouter
    )

    Task { @MainActor in
        viewModel.loadNews()
    }

    return NewsFeedView(viewModel: viewModel, router: mockRouter)
}

#Preview("Error") {
    let container = DIContainer()
    let mockRouter = NewsFeedRouter()

    // Create a fake use case that throws error
    struct FakeErrorUseCase: NewsUseCaseProtocol {
        func fetchNews(page: Int) async throws -> [NewsItemAdapter] {
            throw NewsError.network(URLError(.notConnectedToInternet))
        }

        func hasMorePages(currentPage: Int) async throws -> Bool {
            false
        }
    }

    let viewModel = NewsFeedViewModel(
        useCase: FakeErrorUseCase(),
        router: mockRouter
    )

    Task { @MainActor in
        viewModel.loadNews()
    }

    return NewsFeedView(viewModel: viewModel, router: mockRouter)
}
