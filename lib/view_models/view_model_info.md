# Recommended View Models for Flex Gym Inventory

## What is a View Model?
A **View Model** is a class that manages the state, business logic, and data-fetching for a specific screen or feature in your app. It acts as a bridge between your UI (widgets) and your data sources (databases, APIs, etc.), keeping your UI code clean and focused on presentation. View models:
- Hold and update UI state
- Expose data to widgets
- Handle user actions and business logic
- Make your code more testable and maintainable

## Suggested View Models

1. **DashboardViewModel**  
   Manages dashboard stats, summaries, and quick actions.

2. **GymListViewModel**  
   Handles listing, filtering, and managing multiple gyms.

3. **GymDetailViewModel**  
   Manages a single gym’s details, stats, and actions.

4. **EquipmentListViewModel**  
   Handles listing, searching, and filtering equipment.

5. **EquipmentDetailViewModel**  
   Manages a single equipment item’s details and actions.

6. **WishlistListViewModel**  
   Handles listing and managing wishlist items.

7. **WishlistDetailViewModel**  
   Manages a single wishlist item’s details and actions.

8. **UserProfileViewModel**  
   Handles user info, settings, and profile management.

9. **SettingsViewModel**  
   Manages app-wide settings, preferences, and theme toggles.

10. **AuthViewModel**  
    Handles login, signup, and authentication state.

11. **UpgradesViewModel**  
    Manages and displays planned upgrades.

12. **NavigationViewModel**  
    Handles bottom navigation and routing state (if not handled by a package).

---

You may not need all of these immediately, but this structure will help keep your app modular, scalable, and easy to maintain as it grows.
