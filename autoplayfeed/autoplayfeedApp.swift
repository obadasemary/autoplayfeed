//
//  autoplayfeedApp.swift
//  autoplayfeed
//
//  Created by Abdelrahman Mohamed on 13.02.2026.
//

import SwiftUI

@main
struct autoplayfeedApp: App {
    private let composition = AppComposition.shared

    var body: some Scene {
        WindowGroup {
            NewsFeedBuilder(container: composition.container)
                .buildNewsFeedView()
        }
    }
}
