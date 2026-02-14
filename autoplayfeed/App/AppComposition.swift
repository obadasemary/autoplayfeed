//
//  AppComposition.swift
//  autoplayfeed
//
//  Created by Claude Code on 13.02.2026.
//

import Foundation

/// Centralized dependency injection composition
@MainActor
final class AppComposition {
    static let shared = AppComposition()

    let container = DIContainer()

    private init() {
        print("🏗️ [AppComposition] Initializing...")
        registerDependencies()
        print("✅ [AppComposition] Dependencies registered successfully")
    }

    /// Registers all dependencies in the correct order
    private func registerDependencies() {
        print("📦 [AppComposition] Registering dependencies...")

        // MARK: - Phase 1: Infrastructure Layer
        // Register network service (no dependencies)
        print("   ✓ Registering NetworkService")
        container.register(
            NetworkService.self,
            URLSessionNetworkService(session: .shared)
        )

        // MARK: - Phase 2: Data Layer
        // Resolve infrastructure and register repository
        print("   ✓ Resolving NetworkService")
        let networkService = try! container.requireResolve(NetworkService.self)
        print("   ✓ Registering NewsRepository")
        container.register(
            NewsRepositoryProtocol.self,
            NewsRepository(networkService: networkService)
        )

        // MARK: - Phase 3: Domain Layer
        // Register use case (resolves repository lazily from container)
        print("   ✓ Registering NewsUseCase")
        container.register(
            NewsUseCaseProtocol.self,
            NewsUseCase(container: container)
        )

        // MARK: - Phase 4: Presentation Layer
        // Views are composed via builders (not registered in container)
        print("   ✓ All dependencies registered")
    }
}
