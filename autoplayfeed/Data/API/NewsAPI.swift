//
//  NewsAPI.swift
//  autoplayfeed
//
//  Created by Claude Code on 13.02.2026.
//

import Foundation

/// API endpoint definitions for news feed
enum NewsAPI: Endpoint {
    case feed(page: Int)

    var baseURL: String {
        "https://autoplay.free.beeceptor.com"
    }

    var path: String {
        switch self {
        case .feed:
            return "/feed"
        }
    }

    var method: HTTPMethod {
        .get
    }

    var queryParameters: [String: String]? {
        switch self {
        case .feed(let page):
            return ["page": "\(page)"]
        }
    }
}
