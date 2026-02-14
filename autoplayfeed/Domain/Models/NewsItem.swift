//
//  NewsItem.swift
//  autoplayfeed
//
//  Created by Claude on 14.02.2026.
//

import Foundation

struct NewsItem: Identifiable {
    let id: String
    let title: String
    let description: String?
    let url: String
    let imageUrl: String?
    let source: String
    let publishedDate: Date
    let author: String?
    let category: String?
}
