# Flex Gym Inventory

Flex Gym Inventory is a lightweight, powerful mobile app designed for home and small gym owners to track, manage, and organize their equipment. 

Built in Flutter for iOS and Android.

## Description



## Build in Public

This app is being developed in public to share the process, learn out loud, and invite feedback from fellow lifters and developers.

Follow along:
•	Instagram: @flxinv.app
•	Bluesky: @flxinvapp.bsky.social
•	Twitter/X: @flxinvapp


## Features

- Add and manage multiple gym locations
- Track equipment with custom categories
- View detailed equipment info and history
- Export inventory to CSV
- Light and dark mode UI
- Adaptive UI for both iOS and Android
- Designed with simplicity and speed in mind

---

## Getting Started

### Installation

When realeased, download from the Apple AppStore or the Google Play Store.

## Folder Structure

- **`lib/`**: Main application code, organized as follows:
  - **`config/`**: Configuration files (e.g., `size_config.dart` for responsive design).
  - **`constant/`**: Centralized constants for consistency.
  - **`enum/`**: Enumerations like `view_state.dart` for managing UI states.
  - **`routes/`**: Navigation management with `routes.dart`.
  - **`service/`**: Utility and service classes (e.g., `navigation_service.dart`).
  - **`src/`**: Screen-specific components and widgets.
    - **`screens/`**: Contains all screen files.
    - **`widgets/`**: Contains all widget files.
    - **`models/`**: Contains all model files.
    - **`controllers/`**: Contains all controller files.
  - **`themes/`**: Centralized theme files for consistent styling.
    - **`app_theme.dart`**: Main theme file.
  - **`view_models/`**: ViewModel classes for state management.
  - **`assets/`**: Contains all assets like images and fonts.
    - **`images/`**: Contains all image files.
    - **`fonts/`**: Contains all font files.
    - **`icons/`**: Contains all icon files.
  - **`logging_handler.dart`**: Centralized logging handler for consistent logging practices.
  - **`main.dart`**: Entry point of the application.
  - **`pubspec.yaml`**: Dependency management and asset declaration.
  - **`README.md`**: Project documentation and guidelines.

### Requirements

- Flutter SDK
- Dart 3.x
- Hive + hive_flutter
- Run on iOS Simulator or Android Emulator

### File Structure

## License

This project is shared for transparency and learning purposes only.
All code, designs, and assets are copyrighted and not licensed for reuse, modification, or redistribution without explicit permission from the author.

If you’re interested in contributing or collaborating, please reach out directly.

### Run the App

```bash
flutter pub get
flutter run