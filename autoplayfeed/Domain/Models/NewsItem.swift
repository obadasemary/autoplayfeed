//
//  NewsItem.swift
//  autoplayfeed
//
//  Created by Claude Code on 13.02.2026.
//

import Foundation

/// Domain model representing a single news item
struct NewsItem: Sendable, Identifiable {
    let id: String
    let title: String
    let description: String
    let imageURL: String
    let publishedDate: Date
    let source: String
    let category: String
    let author: String
    let tags: [String]
}
