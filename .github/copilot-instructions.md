# Personal and AI Context Instructions

## About Me
I come from a UX and Visual design background. I am learning flutter in an effort to branch out into the development space. I am used to design centered terminology from years of designing user experiences and user interfaces in Figma.

## Copilot's Role


# Flex Gym Inventory App AI Context Instructions

## Project Overview
Flex Gym Inventory is a Flutter-based application designed to help home gym  and small commercial gym owners track and manage their gym equipment inventory. It features multi gym support for users that have multiple gyms. Upgrade planning for users to plan and track upgrades they want to make for their gym(s). Filtering for Gym views to view specific types of equipment quickly and at a glance. The app features a clean, modern design and leverages Flutter's Material and Cupertino widgets for cross-platform compatibility. The project follows a modular structure to ensure maintainability and scalability.

## Key Development Guidelines

### Architecture and State Management
- **Architecture**: The app uses the MVVM architecture with `BaseModel` and `BaseView` as foundational components.
- **State Management**: Transitioning to Riverpod is recommended for improved testability and simplified state handling. Use `ProviderContainer` for testing providers in isolation.

### Folder Structure
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

### Styling and Theming
- **Responsive Design**: Use `size_config.dart` for consistent layouts.
- **Theme Consistency**: Define themes in `lib/theme/app_theme.dart` as a single source of truth.
- **Custom Fonts**: Use `Roboto` and `Roboto Mono` for a modern look.

### Assets
- **Optimization**: Ensure all assets are declared in `pubspec.yaml` and unused assets are removed.
- **Icons**: Prefer the `cupertino_icons` package for iOS and prefer `material_icons` for android.
- **Images**: Compress images in `assets/images/` to reduce app size.

### Testing
- **Coverage**: Add unit tests for critical components and integration tests for navigation and user flows.
- **Framework**: Use Flutter's testing framework and ensure all new features are tested.

### Performance Optimization
- **Lazy Loading**: Implement lazy loading for assets and screens to improve startup time.
- **Build Time**: Optimize `ios/Podfile` and `android/build.gradle` configurations.

## Key Features and Components

### Screens
- **Splash Screen**: The entry point of the app.
- **Dashboard Screen**: Quick access to gym equipment breakdowns at a glance.
- **Upgrades Screen**: List of all future gym equipement purchest planned.
- **Add Gym Screen**: Adds inital or additional gym.
- **Add Equipment Screen**: Adds equipment to specific gyms.
- **Settings Screen**: User information and settings.
- **Upgrade to PRO Screen**: Promotes premium features and subscriptions.

### Components
- **Reusable UI Components**: Buttons, cards, and modals.
- **Custom Widgets**: Tailored widgets like `PageCard` and `CustomSearchBar`.
- **Bottom Navigation Bar**: Easy navigation between main screens.

## Upgrade Notice
The app is undergoing an upgrade. Maintain the existing visual appearance and design unless explicitly instructed otherwise. Follow the recommendations in `rec.md` for optimization and future enhancements.

## Future Enhancements
- Add guided induction techniques and progress tracking features.
- Implement user authentication and profiles.
- Introduce social sharing features for achievements and progress.

## AI-Specific Instructions
- Generate modular, reusable, and well-documented code.
- Adhere to the existing folder structure and coding standards.
- Avoid breaking changes or incompatible syntax.
- Use `logging_handler.dart` instead of `print` or `log` for logging.
- Ensure all new components and features are documented in the project’s `README.md`.

## NOTES
-NEVER CREATE JYPNB files