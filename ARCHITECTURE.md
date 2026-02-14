# Architecture Documentation

## Table of Contents

1. [Overview](#overview)
2. [Architectural Principles](#architectural-principles)
3. [Layer Structure](#layer-structure)
4. [Directory Structure](#directory-structure)
5. [Dependency Management](#dependency-management)
6. [Data Flow](#data-flow)
7. [Design Patterns](#design-patterns)
8. [Navigation](#navigation)
9. [State Management](#state-management)
10. [Testing Strategy](#testing-strategy)
11. [Common Patterns](#common-patterns)
12. [API Reference](#api-reference)
13. [Important Constraints](#important-constraints)
14. [Best Practices Summary](#best-practices-summary)
15. [Conclusion](#conclusion)

---

## Overview

**autoplayfeed** is a native iOS application built with **Swift 6.0** and **SwiftUI**, following **Clean Architecture** principles. The app displays a news feed with features including infinite scroll pagination, pull-to-refresh, and detailed news views.

### Technology Stack
- **Language**: Swift 6.0 (strict concurrency enabled)
- **UI Framework**: SwiftUI with `@Observable` macro
- **Minimum Deployment**: iOS 17.0+
- **Build System**: Xcode 16+
- **Project Structure**: Single Xcode project with organized directories
- **Architecture**: Clean Architecture with layered design
- **Testing**: Swift Testing Framework (unit tests) and XCTest (UI tests)

---

## Architectural Principles

### 1. Clean Architecture
The application strictly follows Clean Architecture, separating concerns into distinct layers with clear dependency directions.

**Dependency Rule**: Dependencies point inward. Outer layers depend on inner layers, never the reverse.

```plaintext
┌─────────────────────────────────────────────┐
│   Presentation Layer (Views & ViewModels)  │
│    (NewsFeedView, NewsFeedViewModel, etc.)  │
└──────────────────┬──────────────────────────┘
                   │ depends on
                   ↓
┌─────────────────────────────────────────────┐
│      Domain Layer (Use Cases & Models)      │
│      (NewsUseCase, NewsItem, protocols)     │
└──────────────────┬──────────────────────────┘
                   │ depends on
                   ↓
┌─────────────────────────────────────────────┐
│          Data Layer (Repository)            │
│    (NewsRepository, URLSessionNetworkService)│
└─────────────────────────────────────────────┘
```

### 2. Protocol-Oriented Design
All inter-layer communication happens through protocols, enabling:
- Testability (easy mocking)
- Flexibility (swap implementations)
- Decoupling (layers don't know concrete types)

**Key Protocols**:
- `NetworkService` - HTTP client abstraction
- `NewsRepositoryProtocol` - Data access abstraction
- `NewsUseCaseProtocol` - Business logic abstraction
- `NewsFeedRouterProtocol` - Navigation abstraction

### 3. Dependency Injection
All dependencies are:
- Registered in `AppComposition.swift`
- Resolved through `DIContainer`
- Injected via constructors (never accessed globally)

### 4. Unidirectional Data Flow

Data flows in one direction:

```plaintext
User Action → ViewModel → UseCase → Repository → NetworkService
                ↓             ↓          ↓            ↓
             Update       Business    Data        HTTP
              State        Logic     Access      Request
                ↓             ↓          ↓            ↓
             SwiftUI      Transform   Map DTOs   Network
              View         Models    to Models   Response
```

### 5. Actor Isolation
- Most classes are `@MainActor` to ensure UI updates on main thread
- Critical for preventing data races in Swift 6's strict concurrency model
- **Do not remove `@MainActor` without careful consideration**

---

## Layer Structure

### Presentation Layer

**Location**: `autoplayfeed/Presentation/`

**Responsibility**: UI rendering, user interaction, view state management

**Components**:

- SwiftUI Views (`NewsFeedView`, `NewsItemRowView`, `ErrorView`, `LoadingView`)
- ViewModels (`NewsFeedViewModel` - manages view state, coordinates with use cases)
- Builders (`NewsFeedBuilder` - composes views with dependencies)
- Routers (`NewsFeedRouter` - handles navigation)

**Rules**:

- Views are stateless and declarative
- ViewModels hold state and handle business logic coordination
- No direct network or repository access
- Communicate only with use cases

### Domain Layer

**Location**: `autoplayfeed/Domain/`

**Responsibility**: Application-specific business rules, data transformation

**Components**:

- Use Cases (`NewsUseCase` - implements `NewsUseCaseProtocol`)
- Domain Models (`NewsItem`, `NewsPageResponse`)
- Adapters (`NewsItemAdapter` - maps domain models to presentation models)
- Errors (`NewsError` - business-level error handling)
- Protocols (`NewsUseCaseProtocol`)

**Rules**:

- No UI dependencies (no SwiftUI imports in use cases/models)
- No knowledge of data sources
- Pure business logic only
- Framework-independent

### Data Layer

**Location**: `autoplayfeed/Data/`

**Responsibility**: Data access, external service communication

**Components**:

- Repositories (`NewsRepository` - implements `NewsRepositoryProtocol`)
- API Definitions (`NewsAPI` - endpoint definitions)
- DTOs (`NewsItemDTO`, `NewsPageResponseDTO` - data transfer objects)

**Rules**:

- Implements repository protocols defined in domain layer
- Handles network calls via `NetworkService`
- Maps external DTOs to domain models
- No business logic

### Infrastructure Layer

**Location**: `autoplayfeed/Infrastructure/`

**Responsibility**: Low-level infrastructure services

**Components**:

- Dependency Injection (`DIContainer`)
- Network Layer (`NetworkService`, `URLSessionNetworkService`, `Endpoint`)

**Rules**:

- Generic, reusable implementations
- No business logic
- No knowledge of domain models

---

## Directory Structure

The application uses a single Xcode project with organized directories following Clean Architecture layers:

```plaintext
autoplayfeed/
├── autoplayfeed.xcodeproj          # Xcode project file
├── autoplayfeed/                   # Main app target
│   ├── App/                        # Application composition
│   │   └── AppComposition.swift    # DI container setup
│   │
│   ├── Infrastructure/             # Low-level infrastructure
│   │   ├── DI/
│   │   │   └── DIContainer.swift   # Dependency injection container
│   │   └── Network/
│   │       ├── NetworkService.swift           # Protocol
│   │       ├── URLSessionNetworkService.swift # Implementation
│   │       └── Endpoint.swift                 # Endpoint protocol
│   │
│   ├── Data/                       # Data access layer
│   │   ├── API/
│   │   │   └── NewsAPI.swift       # API endpoint definitions
│   │   ├── DTOs/
│   │   │   ├── NewsItemDTO.swift
│   │   │   └── NewsPageResponseDTO.swift
│   │   └── Repositories/
│   │       ├── NewsRepositoryProtocol.swift
│   │       └── NewsRepository.swift
│   │
│   ├── Domain/                     # Business logic layer
│   │   ├── Models/
│   │   │   ├── NewsItem.swift
│   │   │   └── NewsPageResponse.swift
│   │   ├── Adapters/
│   │   │   └── NewsItemAdapter.swift
│   │   ├── Errors/
│   │   │   └── NewsError.swift
│   │   └── UseCases/
│   │       ├── NewsUseCaseProtocol.swift
│   │       └── NewsUseCase.swift
│   │
│   ├── Presentation/               # UI layer
│   │   ├── Common/
│   │   │   ├── LoadingView.swift
│   │   │   └── ErrorView.swift
│   │   └── NewsFeed/
│   │       ├── Views/
│   │       │   ├── NewsFeedView.swift
│   │       │   └── NewsItemRowView.swift
│   │       ├── ViewModels/
│   │       │   └── NewsFeedViewModel.swift
│   │       ├── Builder/
│   │       │   └── NewsFeedBuilder.swift
│   │       └── Router/
│   │           ├── NewsFeedRouterProtocol.swift
│   │           └── NewsFeedRouter.swift
│   │
│   ├── Preview/                    # Preview support
│   │   └── DevPreview.swift
│   │
│   ├── autoplayfeedApp.swift       # App entry point (@main)
│   └── Assets.xcassets/            # Asset catalog
│
├── autoplayfeedTests/              # Unit tests (Swift Testing)
└── autoplayfeedUITests/            # UI tests (XCTest)
```

### Key Directory Responsibilities

#### App/

- **AppComposition.swift**: Centralized dependency registration
- Creates and configures `DIContainer`
- Registers dependencies in correct order

#### Infrastructure/

- **DIContainer**: Simple service locator with type-safe resolution
- **NetworkService**: Generic HTTP client abstraction
- **URLSessionNetworkService**: URLSession-based implementation
- **Endpoint**: Protocol for API endpoint definitions

#### Data/

- **NewsAPI**: Endpoint definitions for news feed API
- **DTOs**: Data Transfer Objects matching API response structure
- **NewsRepository**: Implements data access, maps DTOs to domain models

#### Domain/

- **Models**: Core business entities (`NewsItem`, `NewsPageResponse`)
- **Adapters**: Transform domain models to presentation models
- **Errors**: Business-level error definitions (`NewsError`)
- **UseCases**: Business logic implementation (`NewsUseCase`)

#### Presentation/

- **Views**: SwiftUI views (declarative UI)
- **ViewModels**: State management with `@Observable` macro
- **Builders**: Compose views with dependencies from DI container
- **Routers**: Navigation logic abstraction

#### Preview/

- **DevPreview**: Shared preview configuration for SwiftUI previews

---

## Dependency Management

### Registration Flow
Dependencies are registered in [AppComposition.swift](autoplayfeed/App/AppComposition.swift) in a specific order:

```swift
// Phase 1: Infrastructure Layer
container.register(
    NetworkService.self,
    URLSessionNetworkService(session: .shared)
)

// Phase 2: Data Layer
let networkService = try! container.requireResolve(NetworkService.self)
container.register(
    NewsRepositoryProtocol.self,
    NewsRepository(networkService: networkService)
)

// Phase 3: Domain Layer
container.register(
    NewsUseCaseProtocol.self,
    NewsUseCase(container: container)
)

// Phase 4: Presentation Layer (composed via builders)
// Views are built on-demand by NewsFeedBuilder
```

### DIContainer Implementation
The DIContainer is a simple, type-safe service locator:

```swift
@MainActor
@Observable
final class DIContainer {
    private var services: [ObjectIdentifier: Any] = [:]

    func register<T>(_ type: T.Type, _ instance: T)
    func requireResolve<T>(_ type: T.Type) throws -> T
    func resolve<T>(_ type: T.Type) -> T?
}
```

**Key Features**:

- `@MainActor` isolated for thread safety
- `@Observable` for SwiftUI integration
- Type-safe resolution using `ObjectIdentifier`
- Throws `DIError.serviceNotFound` if dependency missing

### Resolution Rules

1. **Registration order matters** - Register dependencies before dependents
2. **Use `requireResolve()`** - Throws error if dependency missing (preferred)
3. **Use `resolve()`** - Returns optional for conditional resolution
4. **No force unwrapping** - Always handle resolution errors gracefully
5. **Constructor injection only** - No property injection

---

## Data Flow

### Example: Loading News Feed (First Page)

```plaintext
1. User Action
   ↓
   NewsFeedView appears (.onAppear)

2. View → ViewModel
   ↓
   NewsFeedViewModel.loadNews()

3. ViewModel State Transition
   ↓
   state = .loading

4. ViewModel → UseCase
   ↓
   NewsUseCase.fetchNews(page: 1)

5. UseCase → Repository
   ↓
   NewsRepository.fetchNews(page: 1)

6. Repository → Network
   ↓
   NetworkService.request(endpoint: NewsAPI.feed(page: 1))

7. Network Response
   ↓
   NewsPageResponseDTO (JSON decoded)

8. Repository Transformation
   ↓
   Maps NewsPageResponseDTO → NewsPageResponse (domain model)

9. UseCase Transformation
   ↓
   Maps NewsItem → NewsItemAdapter (presentation model)

10. ViewModel State Update
    ↓
    state = .loaded([NewsItemAdapter])

11. View Re-renders
    ↓
    NewsFeedView displays news list
```

### Example: Infinite Scroll Pagination

```plaintext
1. User Scrolls to Last Item
   ↓
   NewsItemRowView.onAppear (for last item)

2. View Triggers Load More
   ↓
   NewsFeedViewModel.loadMore()

3. ViewModel Guards
   ↓
   Check: !isLoadingPage && hasMorePages && state == .loaded

4. ViewModel State Transition
   ↓
   currentPage += 1
   state = .loadingMore(existingItems)

5. Fetch New Page
   ↓
   NewsUseCase.fetchNews(page: currentPage)

6. Append Results
   ↓
   state = .loaded(existingItems + newItems)

7. View Updates
   ↓
   List displays additional items with smooth animation
```

---

## Design Patterns

### 1. Builder Pattern
Every feature has a Builder class that composes views with dependencies.

**Purpose**:
- Centralize dependency injection
- Keep views testable
- Decouple view creation from DI container

**Example**: [NewsFeedBuilder.swift](autoplayfeed/Presentation/NewsFeed/Builder/NewsFeedBuilder.swift)
```swift
@MainActor
final class NewsFeedBuilder {
    private let container: DIContainer

    init(container: DIContainer) {
        self.container = container
    }

    func buildNewsFeedView() -> some View {
        do {
            let useCase = try container.requireResolve(NewsUseCaseProtocol.self)
            let router = NewsFeedRouter()
            let viewModel = NewsFeedViewModel(useCase: useCase, router: router)
            return NewsFeedView(viewModel: viewModel)
        } catch {
            fatalError("Failed to build NewsFeedView: \(error)")
        }
    }
}
```

### 2. State Machine Pattern
ViewModels use enum-based state machines for clarity.

**Benefits**:
- Impossible states become impossible
- Clear state transitions
- Easy to test
- Exhaustive switch handling

**Example**: [NewsFeedViewModel.swift](autoplayfeed/Presentation/NewsFeed/ViewModels/NewsFeedViewModel.swift)
```swift
enum State: Equatable {
    case idle
    case loading
    case loaded([NewsItemAdapter])
    case error(NewsError)
    case loadingMore([NewsItemAdapter])
}

func loadNews() {
    guard !isLoadingPage else { return }

    isLoadingPage = true
    currentPage = 1
    state = .loading

    Task {
        defer { isLoadingPage = false }

        do {
            let items = try await useCase.fetchNews(page: currentPage)
            hasMorePages = try await useCase.hasMorePages(currentPage: currentPage)
            state = .loaded(items)
        } catch let error as NewsError {
            state = .error(error)
        } catch {
            state = .error(.unknown(error.localizedDescription))
        }
    }
}
```

**State Transitions**:

```plaintext
idle → loading → loaded ↔ loadingMore
  ↓       ↓         ↓          ↓
  └───────┴─────error──────────┘
```

### 3. Repository Pattern
Abstracts data sources behind protocols.

**Benefits**:
- Swap implementations (network, cache, mock)
- Testability
- Single source of truth for data access

### 4. Adapter Pattern
Transforms data between layers.

**Purpose**:
- Keep layers independent
- Map domain models to presentation models
- Add computed properties optimized for views
- Prevent UI from depending on business logic types

**Example**: [NewsItemAdapter.swift](autoplayfeed/Domain/Adapters/NewsItemAdapter.swift)
```swift
struct NewsItemAdapter: Identifiable, Equatable, Sendable {
    let id: String
    let title: String
    let description: String
    let imageURL: URL?
    let formattedDate: String  // Computed for display
    let source: String
    let category: String
    let author: String
    let tags: [String]

    static func from(_ newsItem: NewsItem) -> NewsItemAdapter {
        NewsItemAdapter(
            id: newsItem.id,
            title: newsItem.title,
            description: newsItem.description,
            imageURL: URL(string: newsItem.imageURL),
            formattedDate: RelativeDateTimeFormatter().localizedString(
                for: newsItem.publishedDate,
                relativeTo: Date()
            ),
            source: newsItem.source,
            category: newsItem.category,
            author: newsItem.author,
            tags: newsItem.tags
        )
    }
}
```

### 5. Protocol-Oriented Programming
All abstractions are protocols, not base classes.

**Benefits**:
- Better testability
- Composition over inheritance
- Value semantics when possible

---

## Navigation

### Protocol-Based Routing
The app uses protocol-based routing for testability and decoupling.

**Pattern**: [NewsFeedRouter.swift](autoplayfeed/Presentation/NewsFeed/Router/NewsFeedRouter.swift)
```swift
protocol NewsFeedRouterProtocol {
    func navigateToNewsDetail(item: NewsItemAdapter)
}

@MainActor
final class NewsFeedRouter: NewsFeedRouterProtocol {
    func navigateToNewsDetail(item: NewsItemAdapter) {
        print("🧭 [Router] Navigating to detail for: \(item.title)")
        // Navigation implementation
        // Can use NavigationStack, NavigationPath, or coordinator pattern
    }
}
```

**Key Concepts**:

- Routers are protocol-based for testability
- Injected into ViewModels via constructor
- ViewModels never directly trigger navigation
- Easy to mock for testing and previews

**Future Enhancement**: Consider adding NavigationPath or coordinator pattern for complex navigation flows.

---

## State Management

### SwiftUI @Observable
The app uses Swift 5.9+ `@Observable` macro instead of `ObservableObject`.

**Usage**:
```swift
@MainActor
@Observable
final class FeedViewModel {
    var state: State = .idle
    var isLoading: Bool { /* computed */ }

    // SwiftUI tracks changes automatically
}
```

**Benefits**:

- Less boilerplate
- Automatic change tracking
- Better performance

### State Machine Pattern
ViewModels manage state transitions explicitly:

```swift
// Initial state
state = .idle

// Loading first page
state = .loading

// Loaded successfully
state = .loaded(characters)

// Loading more pages
state = .loadingMore(existingCharacters)

// Error occurred
state = .error(feedError)
```

---

## Testing Strategy

### Unit Tests
Each SPM package has its own `Tests/` directory.

**Framework**: Swift Testing (modern, built-in)

**Test Structure**:
```
Package/
├── Sources/
│   └── FeatureName/
└── Tests/
    └── FeatureNameTests/
```

### Test Doubles

#### Protocol-Based Mocks
```swift
final class MockNetworkService: NetworkService {
    var stubbedResult: Result<Data, Error>?

    func request<T: Decodable>(endpoint: Endpoint) async throws -> T {
        // Return stubbed data
    }
}
```

#### Fake Use Cases
```swift
final class FakeFeedUseCase: FeedUseCaseProtocol {
    var characters: [CharacterAdapter] = []

    func fetchCharacters(page: Int, status: String?) async throws -> [CharacterAdapter] {
        return characters
    }
}
```

### Testing ViewModels
Test state transitions and business logic:

```swift
@Test
func testLoadCharactersSuccess() async {
    let fakeUseCase = FakeFeedUseCase()
    let viewModel = FeedViewModel(useCase: fakeUseCase, router: mockRouter)

    await viewModel.loadCharacters()

    #expect(viewModel.state == .loaded(fakeUseCase.characters))
}
```

### Testing Repositories
Mock `NetworkService` to test in isolation:

```swift
@Test
func testRepositoryFetchCharacters() async throws {
    let mockNetwork = MockNetworkService()
    let repository = FeedRepository(networkService: mockNetwork)

    let result = try await repository.getCharacters(page: 1)

    #expect(result.count > 0)
}
```

---

## Common Patterns

### 1. Pagination Implementation

**Guard Against Concurrent Requests**:
```swift
private var isLoadingPage = false
private var hasMorePages = true

func loadMore() {
    guard !isLoadingPage else { return }
    guard hasMorePages else { return }
    guard case .loaded(let existingItems) = state else { return }

    isLoadingPage = true
    defer { isLoadingPage = false }

    currentPage += 1
    state = .loadingMore(existingItems)

    // Load next page
}
```

**State Transitions**:
```swift
// First page
currentPage = 1
state = .loading

// Subsequent pages
currentPage += 1
state = .loadingMore(existingItems)

// After successful load
state = .loaded(existingItems + newItems)
```

**Pull-to-Refresh**:
```swift
func refresh() async {
    guard !isLoadingPage else { return }

    isLoadingPage = true
    currentPage = 1
    defer { isLoadingPage = false }

    do {
        let items = try await useCase.fetchNews(page: 1)
        hasMorePages = try await useCase.hasMorePages(currentPage: 1)
        state = .loaded(items)
    } catch let error as NewsError {
        state = .error(error)
    }
}
```

**Infinite Scroll Trigger** (in View):
```swift
ForEach(items) { item in
    NewsItemRowView(item: item)
        .onAppear {
            if item == items.last {
                viewModel.loadMore()
            }
        }
}
```

### 2. Error Mapping

**Domain Error Definition**: [NewsError.swift](autoplayfeed/Domain/Errors/NewsError.swift)
```swift
enum NewsError: Error, Equatable {
    case network(URLError)
    case decoding(String)
    case server(Int)
    case unknown(String)

    var userMessage: String {
        switch self {
        case .network(let urlError):
            if urlError.code == .notConnectedToInternet {
                return "No internet connection. Please check your network."
            }
            return "Network error. Please try again."
        case .decoding:
            return "Failed to parse response. Please try again later."
        case .server(let statusCode):
            return "Server error (\(statusCode)). Please try again later."
        case .unknown(let message):
            return message
        }
    }
}
```

**Repository → UseCase** (Error Mapping):
```swift
do {
    return try await networkService.request(endpoint: endpoint)
} catch let error as URLError {
    throw NewsError.network(error)
} catch let error as DecodingError {
    throw NewsError.decoding(error.localizedDescription)
} catch {
    throw NewsError.unknown(error.localizedDescription)
}
```

**UseCase → ViewModel** (Error Handling):
```swift
catch let error as NewsError {
    state = .error(error)
} catch {
    state = .error(.unknown(error.localizedDescription))
}
```

**ViewModel → View** (Error Display):
```swift
var errorMessage: String {
    if case .error(let newsError) = state {
        return newsError.userMessage
    }
    return ""
}

// In View
if case .error = viewModel.state {
    ErrorView(
        message: viewModel.errorMessage,
        retry: { viewModel.loadNews() }
    )
}
```

### 3. SwiftUI Previews with Fake Use Cases

**Pattern**: Create fake use cases inline in previews for different states

**Loading State**:
```swift
#Preview("Loading") {
    struct FakeLoadingUseCase: NewsUseCaseProtocol {
        func fetchNews(page: Int) async throws -> [NewsItemAdapter] {
            try await Task.sleep(nanoseconds: 1_000_000_000_000) // Never completes
            return []
        }
        func hasMorePages(currentPage: Int) async throws -> Bool { true }
    }

    let viewModel = NewsFeedViewModel(
        useCase: FakeLoadingUseCase(),
        router: NewsFeedRouter()
    )
    Task { @MainActor in viewModel.loadNews() }
    return NewsFeedView(viewModel: viewModel)
}
```

**Loaded State**:
```swift
#Preview("Loaded") {
    struct FakeLoadedUseCase: NewsUseCaseProtocol {
        func fetchNews(page: Int) async throws -> [NewsItemAdapter] {
            [
                NewsItemAdapter(
                    id: "1",
                    title: "Breaking News",
                    description: "Sample description",
                    imageURL: URL(string: "https://picsum.photos/200"),
                    formattedDate: "2 hours ago",
                    source: "Tech News",
                    category: "Technology",
                    author: "John Doe",
                    tags: ["Tech"]
                )
            ]
        }
        func hasMorePages(currentPage: Int) async throws -> Bool { true }
    }

    let viewModel = NewsFeedViewModel(
        useCase: FakeLoadedUseCase(),
        router: NewsFeedRouter()
    )
    Task { @MainActor in viewModel.loadNews() }
    return NewsFeedView(viewModel: viewModel)
}
```

**Error State**:
```swift
#Preview("Error") {
    struct FakeErrorUseCase: NewsUseCaseProtocol {
        func fetchNews(page: Int) async throws -> [NewsItemAdapter] {
            throw NewsError.network(URLError(.notConnectedToInternet))
        }
        func hasMorePages(currentPage: Int) async throws -> Bool { false }
    }

    let viewModel = NewsFeedViewModel(
        useCase: FakeErrorUseCase(),
        router: NewsFeedRouter()
    )
    Task { @MainActor in viewModel.loadNews() }
    return NewsFeedView(viewModel: viewModel)
}
```

### 4. Adding New Endpoints

**Step 1**: Add to [NewsAPI.swift](autoplayfeed/Data/API/NewsAPI.swift):
```swift
enum NewsAPI: Endpoint {
    case feed(page: Int)
    case newsDetail(id: String) // New endpoint

    var path: String {
        switch self {
        case .feed:
            return "/feed"
        case .newsDetail(let id):
            return "/news/\(id)"
        }
    }

    var queryParameters: [String: String]? {
        switch self {
        case .feed(let page):
            return ["page": "\(page)"]
        case .newsDetail:
            return nil
        }
    }
}
```

**Step 2**: Add DTO for response:
```swift
struct NewsDetailDTO: Decodable {
    let id: String
    let title: String
    // ... other fields
}
```

**Step 3**: Add repository method:
```swift
protocol NewsRepositoryProtocol {
    func fetchNews(page: Int) async throws -> NewsPageResponse
    func fetchNewsDetail(id: String) async throws -> NewsItem // New
}
```

**Step 4**: Implement in repository:
```swift
func fetchNewsDetail(id: String) async throws -> NewsItem {
    let dto: NewsDetailDTO = try await networkService.request(
        endpoint: NewsAPI.newsDetail(id: id)
    )
    return NewsItem(from: dto)
}
```

**Step 5**: Expose in use case:
```swift
func fetchNewsDetail(id: String) async throws -> NewsItemAdapter {
    let newsItem = try await repository.fetchNewsDetail(id: id)
    return NewsItemAdapter.from(newsItem)
}
```

### 5. Adding New Features

**Step 1**: Create directory structure:
```bash
# In autoplayfeed/Presentation/
mkdir -p NewFeature/Views
mkdir -p NewFeature/ViewModels
mkdir -p NewFeature/Builder
mkdir -p NewFeature/Router
```

**Step 2**: Create domain layer (if needed):
```bash
# In autoplayfeed/Domain/
mkdir -p UseCases    # Add NewFeatureUseCaseProtocol.swift, NewFeatureUseCase.swift
mkdir -p Models      # Add domain models
mkdir -p Adapters    # Add presentation adapters
```

**Step 3**: Create data layer (if needed):
```bash
# In autoplayfeed/Data/
mkdir -p Repositories  # Add repository protocol and implementation
mkdir -p DTOs         # Add DTOs
mkdir -p API          # Add API endpoint definitions
```

**Step 4**: Create Builder:
```swift
@MainActor
final class NewFeatureBuilder {
    private let container: DIContainer

    init(container: DIContainer) {
        self.container = container
    }

    func buildView() -> some View {
        do {
            let useCase = try container.requireResolve(NewFeatureUseCaseProtocol.self)
            let router = NewFeatureRouter()
            let viewModel = NewFeatureViewModel(useCase: useCase, router: router)
            return NewFeatureView(viewModel: viewModel)
        } catch {
            fatalError("Failed to build NewFeatureView: \(error)")
        }
    }
}
```

**Step 5**: Register in [AppComposition.swift](autoplayfeed/App/AppComposition.swift):
```swift
// In registerDependencies()

// Register repository (if needed)
container.register(
    NewFeatureRepositoryProtocol.self,
    NewFeatureRepository(networkService: networkService)
)

// Register use case
container.register(
    NewFeatureUseCaseProtocol.self,
    NewFeatureUseCase(container: container)
)
```

**Step 6**: Add to app (if root view):
```swift
// In autoplayfeedApp.swift
var body: some Scene {
    WindowGroup {
        NewFeatureBuilder(container: composition.container)
            .buildView()
    }
}
```

---

## Important Constraints

### 1. Project Structure

- **Open**: `autoplayfeed.xcodeproj`
- **NOT a workspace**: Single Xcode project with organized directories
- All code is within the main target (not separate SPM packages)

### 2. @MainActor is Critical

- Most classes are `@MainActor` for thread safety
- Removing can cause data races in Swift 6
- Only remove with careful consideration and testing

### 3. No Force Unwrapping

- Use safe unwrapping: `if let`, `guard let`
- Use `requireResolve()` for DI (throws on failure)
- Handle all optionals gracefully

### 4. Protocol-First Development

- Always define protocols for cross-module dependencies
- Concrete types are implementation details
- Enables testing and flexibility

### 5. Builder Pattern is Mandatory

- Features composed via builder classes
- Never instantiate feature views directly
- Builders encapsulate dependency injection

### 6. External Dependencies

- **None currently**: The project has no external dependencies
- All networking, DI, and infrastructure is custom-built
- Consider adding dependencies carefully (prefer standard library when possible)

---

## API Reference

### News Feed API (Beeceptor Mock)

**Base URL**: `https://mpe2443b81ac89378f84.free.beeceptor.com`

**Authentication**: None required

**Response Format**: JSON

**Implementation**: [NewsAPI.swift](autoplayfeed/Data/API/NewsAPI.swift)

#### Endpoints

##### Get News Feed (Paginated)
```
GET /feed
Query Parameters:
  - page: Int (1-based, required)

Response:
{
  "page": 1,
  "totalPages": 10,
  "items": [
    {
      "id": "1",
      "title": "Breaking News Title",
      "description": "News article description...",
      "imageURL": "https://...",
      "publishedDate": "2026-02-14T10:00:00Z",
      "source": "Tech News",
      "category": "Technology",
      "author": "John Doe",
      "tags": ["Tech", "AI"]
    }
  ]
}
```

**DTO Mapping**: `NewsPageResponseDTO` → `NewsPageResponse` (domain) → `[NewsItemAdapter]` (presentation)

**Error Handling**:

- Network errors → `NewsError.network(URLError)`
- Decoding errors → `NewsError.decoding(String)`
- HTTP errors → `NewsError.server(Int)`
- Unknown errors → `NewsError.unknown(String)`

---

## Best Practices Summary

1. **Separation of Concerns**: Each layer has a single responsibility
2. **Dependency Injection**: All dependencies injected via constructors
3. **Protocol Abstraction**: Communicate through interfaces, not concrete types
4. **Unidirectional Flow**: Data flows outer → inner layers only
5. **State Machines**: Use enums for view state management
6. **Thread Safety**: Use `@MainActor` for UI-related code
7. **Error Handling**: Map errors at each layer boundary
8. **Testing**: Write unit tests with protocol-based mocks
9. **Modular Design**: Each feature is an independent SPM package
10. **Builder Pattern**: Compose features via builder classes

---

## Conclusion

This architecture ensures:

- **Scalability**: Easy to add new features without affecting existing code. Each layer is independent and follows single responsibility principle.
- **Testability**: Protocol-oriented design enables easy mocking. ViewModels can be tested with fake use cases, repositories can be tested with mock network services.
- **Maintainability**: Clear separation of concerns and consistent patterns. Directory structure mirrors architectural layers. Naming conventions are consistent across the codebase.
- **Type Safety**: Leverages Swift 6.0's type system and strict concurrency. `@MainActor` annotations prevent data races. `Sendable` conformance ensures thread safety.
- **Readability**: Predictable structure and naming conventions. State machines make state transitions explicit. Dependency flow is always inward (Presentation → Domain → Data → Infrastructure).
- **Performance**: `@Observable` macro provides efficient change tracking. Async/await for non-blocking operations. Pagination prevents loading entire dataset at once.

### Key Success Factors

1. **Single Xcode Project**: Simpler build configuration, easier to navigate than workspace with multiple packages
2. **Organized Directories**: Clear layer separation through directory structure
3. **Builder Pattern**: Centralized dependency composition keeps views clean
4. **State Machines**: Impossible states become impossible, reducing bugs
5. **Protocol Abstraction**: Every layer communicates through protocols, enabling flexibility and testing
6. **Dependency Injection**: All dependencies are registered and resolved through DIContainer
7. **Error Handling**: Errors are mapped at layer boundaries with user-friendly messages
8. **SwiftUI Best Practices**: `@Observable` macro, `@MainActor` isolation, declarative views

By following these principles and patterns, the **autoplayfeed** codebase remains clean, testable, and production-ready.
