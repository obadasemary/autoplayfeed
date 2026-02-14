//
//  NewsItemDTO.swift
//  autoplayfeed
//
//  Created by Claude on 14.02.2026.
//

import Foundation

struct NewsItemDTO: Codable {
    let id: String
    let title: String
    let description: String?
    let url: String
    let imageUrl: String?
    let source: String
    let publishedDate: String
    let author: String?
    let category: String?

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case url
        case imageUrl = "image_url"
        case source
        case publishedDate = "published_date"
        case author
        case category
    }
}
