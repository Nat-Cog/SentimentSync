# SentimentVibe - Mood-Based Content Suggestion iOS App

SentimentVibe is an iOS application that provides personalized content recommendations based on your current emotional state. Built using SwiftUI, the app offers a seamless user experience with dynamic content presentation for various emotions.

## Features

- **Welcome Screen**: A friendly welcome screen greets users upon launch
- **Emotion Selection**: Choose from 9 different emotions including happy, sad, angry, scared, romantic, relaxed, lost, stressed, and sleepy
- **Content Suggestions**: Receive tailored recommendations for each emotion including:
  - YouTube videos
  - Motivational quotes
  - Song recommendations
  - Article suggestions
- **Detailed Content View**: Tap on any suggestion to view more details and access the content
- **Fresh Content**: A "Not feeling these?" button allows users to select a different emotion for new suggestions

## Technical Implementation

- Built with **SwiftUI**
- Supports **iOS 16+**
- Follows Apple Human Interface Guidelines
- Uses **NavigationStack** for seamless navigation
- Implements **MVVM architecture** for clear separation of concerns
- Features custom UI components and animations

## Project Structure

- **Models**: Data structures for emotions and content items
- **Views**: UI components including welcome, emotion selection, content suggestions, and detail views
- **ViewModels**: Business logic for loading and managing content
- **Resources**: Mock content data in JSON format
- **Extensions**: UI helper extensions
- **Helpers**: Data loading utilities

## Requirements

- iOS 16.0+
- Xcode 15.0+
- Swift 5.9+

## Future Enhancements

- API integration for live content
- User profiles and favorites
- Mood tracking history
- Additional content types
- Advanced content filtering options

## Credits

Created by m_959058