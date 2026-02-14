# Screenshots

This directory contains screenshots for the main README.

## Required Screenshots

Please capture the following screenshots from the iOS Simulator and save them in this directory:

### 1. News Feed (`news-feed.png`)
- **What to show**: Main news feed list view with multiple articles
- **How to capture**:
  1. Launch the app in iOS Simulator
  2. Wait for the news feed to load completely
  3. Ensure at least 3-4 articles are visible
  4. Press `Cmd + S` in the Simulator to save screenshot
  5. Rename to `news-feed.png`

### 2. Article Detail (`article-detail.png`)
- **What to show**: Detailed view of a single article
- **How to capture**:
  1. Tap on any article in the feed
  2. Wait for the detail view to load
  3. Scroll to show the full article content (if needed)
  4. Press `Cmd + S` in the Simulator
  5. Rename to `article-detail.png`

### 3. Loading State (`loading-state.png`) - Optional
- **What to show**: Loading spinner when fetching news
- **How to capture**:
  1. Kill and restart the app
  2. Quickly press `Cmd + S` to capture the loading state
  3. Rename to `loading-state.png`

### 4. Error State (`error-state.png`) - Optional
- **What to show**: Error view with retry button
- **How to capture**:
  1. Turn off WiFi on your Mac
  2. Kill and restart the app
  3. Wait for the error message to appear
  4. Press `Cmd + S` in the Simulator
  5. Rename to `error-state.png`

## Screenshot Guidelines

- **Device**: Use iPhone 15 Pro or similar modern device
- **Orientation**: Portrait mode
- **Size**: Screenshots should be clear and readable
- **Format**: PNG format preferred
- **Naming**: Use lowercase with hyphens (e.g., `news-feed.png`)

## Quick Capture Commands

If you prefer using command line:

```bash
# Capture screenshot of running simulator
xcrun simctl io booted screenshot news-feed.png

# Or use the macOS screenshot tool
# Press Cmd + Shift + 4, then press Space to capture a window
```

## After Adding Screenshots

Once you've added the screenshots, verify they appear correctly in the main README.md by opening it in a markdown viewer or on GitHub.
