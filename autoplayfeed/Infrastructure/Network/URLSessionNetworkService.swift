//
//  URLSessionNetworkService.swift
//  autoplayfeed
//
//  Created by Claude Code on 13.02.2026.
//

import Foundation

/// Actor-based implementation of NetworkService using URLSession
actor URLSessionNetworkService: NetworkService {
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func request<T: Decodable>(endpoint: Endpoint) async throws -> T {
        // Build URL
        guard var urlComponents = URLComponents(string: endpoint.baseURL + endpoint.path) else {
            print("❌ [Network] Invalid URL: \(endpoint.baseURL + endpoint.path)")
            throw NetworkError.invalidURL
        }

        // Add query parameters
        if let queryParameters = endpoint.queryParameters {
            urlComponents.queryItems = queryParameters.map {
                URLQueryItem(name: $0.key, value: $0.value)
            }
            print("🔍 [Network] Query parameters: \(queryParameters)")
        }

        guard let url = urlComponents.url else {
            print("❌ [Network] Failed to build URL from components")
            throw NetworkError.invalidURL
        }

        print("🌐 [Network] REQUEST: \(endpoint.method.rawValue) \(url.absoluteString)")

        // Build request
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue

        // Add headers
        endpoint.headers?.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
            print("📋 [Network] Header: \(key) = \(value)")
        }

        // Execute request
        do {
            print("⏳ [Network] Sending request...")
            let (data, response) = try await session.data(for: request)

            // Validate response
            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ [Network] Invalid response type")
                throw NetworkError.invalidResponse
            }

            print("✅ [Network] RESPONSE: Status \(httpResponse.statusCode)")
            print("📦 [Network] Response size: \(data.count) bytes")

            // Log response data as string for debugging
            if let responseString = String(data: data, encoding: .utf8) {
                print("📄 [Network] Response body: \(responseString)")
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                print("❌ [Network] Server error: \(httpResponse.statusCode)")
                throw NetworkError.serverError(statusCode: httpResponse.statusCode)
            }

            // Decode response
            do {
                print("🔄 [Network] Decoding response to \(T.self)...")
                let decoder = JSONDecoder()
                let decoded = try decoder.decode(T.self, from: data)
                print("✅ [Network] Successfully decoded response")
                return decoded
            } catch let decodingError as DecodingError {
                print("❌ [Network] Decoding error: \(decodingError)")
                switch decodingError {
                case .keyNotFound(let key, let context):
                    print("   - Missing key: \(key.stringValue) in \(context.debugDescription)")
                case .typeMismatch(let type, let context):
                    print("   - Type mismatch: expected \(type) in \(context.debugDescription)")
                case .valueNotFound(let type, let context):
                    print("   - Value not found: \(type) in \(context.debugDescription)")
                case .dataCorrupted(let context):
                    print("   - Data corrupted: \(context.debugDescription)")
                @unknown default:
                    print("   - Unknown decoding error")
                }
                throw NetworkError.decodingError(decodingError)
            }
        } catch let urlError as URLError {
            print("❌ [Network] URL error: \(urlError.localizedDescription)")
            throw NetworkError.networkError(urlError)
        } catch let error as NetworkError {
            print("❌ [Network] Network error: \(error)")
            throw error
        } catch {
            print("❌ [Network] Unknown error: \(error.localizedDescription)")
            throw NetworkError.unknown(error.localizedDescription)
        }
    }
}

/// Network-related errors
enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case networkError(URLError)
    case decodingError(DecodingError)
    case serverError(statusCode: Int)
    case unknown(String)
}
