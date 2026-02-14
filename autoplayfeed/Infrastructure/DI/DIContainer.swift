//
//  DIContainer.swift
//  autoplayfeed
//
//  Created by Claude Code on 13.02.2026.
//

import Foundation
import Observation

/// Dependency injection container for managing service instances
@MainActor
@Observable
final class DIContainer {
    private var services: [ObjectIdentifier: Any] = [:]

    /// Registers a service instance for a given type
    /// - Parameters:
    ///   - type: The protocol or type to register
    ///   - instance: The instance to register
    func register<T>(_ type: T.Type, _ instance: T) {
        let key = ObjectIdentifier(type)
        services[key] = instance
    }

    /// Resolves and returns a registered service
    /// - Parameter type: The type to resolve
    /// - Returns: The resolved instance
    /// - Throws: DIError if the service is not registered
    func requireResolve<T>(_ type: T.Type) throws -> T {
        let key = ObjectIdentifier(type)

        guard let service = services[key] as? T else {
            throw DIError.serviceNotFound(String(describing: type))
        }

        return service
    }

    /// Resolves a service if available, returns nil otherwise
    /// - Parameter type: The type to resolve
    /// - Returns: The resolved instance or nil
    func resolve<T>(_ type: T.Type) -> T? {
        let key = ObjectIdentifier(type)
        return services[key] as? T
    }
}

/// Dependency injection errors
enum DIError: Error, CustomStringConvertible {
    case serviceNotFound(String)

    var description: String {
        switch self {
        case .serviceNotFound(let typeName):
            return "Service not found: \(typeName)"
        }
    }
}
