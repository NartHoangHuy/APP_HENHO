# App Hen Ho - Dating App

## Overview
App Hen Ho is a mobile dating application built with Flutter. The app allows users to create profiles, browse potential matches, chat with other users, and manage their preferences.

## Features
- User authentication (login, registration, logout)
- Profile creation and editing
- Browsing potential matches
- Chat functionality with matched users
- User preferences and settings

## Project Structure
```
app_henho
├── lib
│   ├── main.dart                # Entry point of the application
│   ├── models
│   │   └── user.dart            # User model class
│   ├── screens
│   │   ├── home_screen.dart      # Main interface for browsing matches
│   │   ├── profile_screen.dart    # User profile management
│   │   ├── chat_screen.dart       # Chat interface with matches
│   │   └── match_screen.dart      # Display matched users
│   ├── widgets
│   │   ├── user_card.dart         # Widget for displaying user information
│   │   └── chat_bubble.dart       # Widget for chat messages
│   ├── services
│   │   ├── auth_service.dart      # Authentication logic
│   │   └── match_service.dart     # Matching logic
│   └── utils
│       └── constants.dart         # Application constants
├── pubspec.yaml                  # Flutter project configuration
└── README.md                     # Project documentation
```

## Setup Instructions
1. Clone the repository:
   ```
   git clone <repository-url>
   ```
2. Navigate to the project directory:
   ```
   cd app_henho
   ```
3. Install dependencies:
   ```
   flutter pub get
   ```
4. Run the application:
   ```
   flutter run
   ```

## Usage
- Create an account or log in to an existing account.
- Complete your profile with relevant information.
- Browse through potential matches and start chatting with users you are interested in.

## Contributing
Contributions are welcome! Please open an issue or submit a pull request for any improvements or features you would like to add.

## License
This project is licensed under the MIT License. See the LICENSE file for details.