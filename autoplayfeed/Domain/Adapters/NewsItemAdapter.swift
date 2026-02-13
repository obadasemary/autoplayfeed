//
//  NewsItemAdapter.swift
//  autoplayfeed
//
//  Created by Claude Code on 13.02.2026.
//

import Foundation

/// Presentation model for NewsItem with formatted data for views
struct NewsItemAdapter: Identifiable, Sendable, Equatable {
    let id: String
    let title: String
    let description: String
    let imageURL: URL?
    let formattedDate: String
    let source: String
    let category: String
    let author: String
    let tags: [String]

    /// Creates an adapter from a domain NewsItem
    static func from(_ domain: NewsItem) -> NewsItemAdapter {
        NewsItemAdapter(
            id: domain.id,
            title: domain.title,
            description: domain.description,
            imageURL: URL(string: domain.imageURL),
            formattedDate: formatDate(domain.publishedDate),
            source: domain.source,
            category: domain.category,
            author: domain.author,
            tags: domain.tags
        )
    }

    // MARK: - Private Formatting

    private static func formatDate(_ date: Date) -> String {
        let now = Date()
        let interval = now.timeIntervalSince(date)

        // Less than 1 minute
        if interval < 60 {
            return "Just now"
        }

        // Less than 1 hour
        if interval < 3600 {
            let minutes = Int(interval / 60)
            return "\(minutes) minute\(minutes == 1 ? "" : "s") ago"
        }

        // Less than 24 hours
        if interval < 86400 {
            let hours = Int(interval / 3600)
            return "\(hours) hour\(hours == 1 ? "" : "s") ago"
        }

        // Less than 7 days
        if interval < 604800 {
            let days = Int(interval / 86400)
            return "\(days) day\(days == 1 ? "" : "s") ago"
        }

        // More than 7 days - show formatted date
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}
