//
//  NewsItemDTO.swift
//  autoplayfeed
//
//  Created by Claude Code on 13.02.2026.
//

import Foundation

/// Data Transfer Object for a news item matching API response structure
struct NewsItemDTO: Codable {
    let id: String
    let title: String
    let description: String
    let imageURL: String
    let publishedDate: String
    let source: String
    let category: String
    let author: String
    let tags: [String]
}
