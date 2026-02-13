# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a SwiftUI iOS application built with Xcode. The project uses a standard Xcode project structure (not a workspace) and follows modern SwiftUI patterns.

## Build & Test Commands

### Building
```bash
# Build for debug
xcodebuild -project autoplayfeed.xcodeproj -scheme autoplayfeed -configuration Debug build

# Build for release
xcodebuild -project autoplayfeed.xcodeproj -scheme autoplayfeed -configuration Release build

# Clean build folder
xcodebuild -project autoplayfeed.xcodeproj -scheme autoplayfeed clean
```

### Testing
```bash
# Run all tests (unit + UI)
xcodebuild -project autoplayfeed.xcodeproj -scheme autoplayfeed test

# Run only unit tests
xcodebuild -project autoplayfeed.xcodeproj -scheme autoplayfeed -only-testing:autoplayfeedTests test

# Run only UI tests
xcodebuild -project autoplayfeed.xcodeproj -scheme autoplayfeed -only-testing:autoplayfeedUITests test

# Run a specific test
xcodebuild -project autoplayfeed.xcodeproj -scheme autoplayfeed -only-testing:autoplayfeedTests/autoplayfeedTests/example test
```

Note: Unit tests use Swift Testing framework, while UI tests use XCTest.

## Project Structure

```
autoplayfeed/
├── autoplayfeed/              # Main app target
│   ├── autoplayfeedApp.swift  # App entry point (@main)
│   ├── ContentView.swift      # Root view
│   └── Assets.xcassets/       # Asset catalog
├── autoplayfeedTests/         # Unit tests (Swift Testing)
└── autoplayfeedUITests/       # UI tests (XCTest)
```

## Architecture

- **App Entry**: `autoplayfeedApp.swift` defines the app lifecycle with `@main` attribute
- **Root View**: `ContentView.swift` is the main view loaded by the app
- **Testing Strategy**:
  - Unit tests use Swift Testing framework (modern `@Test` macro)
  - UI tests use XCTest framework with `XCUIApplication`

## Development Conventions

- This project uses SwiftUI exclusively (no UIKit)
- Follow SwiftUI best practices as defined in the swiftui-expert-skill
- Use Swift Concurrency (async/await, actors) as defined in the swift-concurrency skill
- UI tests use `@MainActor` annotations for test methods
