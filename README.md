<p align="center">
  <img src="lib/assets/images/fgi_logo_navy.png" alt="Flex Gym Inventory" width="360">
</p>

<p align="center"><strong>A clearer view of every gym and every piece of equipment.</strong></p>

Flex Gym Inventory (FGI) is a mobile inventory app for home gym enthusiasts and small gym owners. Organize multiple gyms, keep equipment details in one place, plan future purchases, and understand your inventory without relying on scattered notes or spreadsheets.

## About

Whether you manage a single garage gym or equipment across several locations, FGI helps keep your inventory organized and easy to review. Each gym has its own equipment list, while wishlists help you keep track of gear you may want to add next.

## Features

### Gym management

- Create, update, and remove gyms.
- Keep equipment organized by gym.
- Record useful gym details such as location and notes.

### Equipment management

- Add, edit, and remove equipment associated with a gym.
- Record quantities and details such as category, brand, model, condition, value, and maintenance notes.
- Review equipment and gym statistics from the dashboard.

### Wishlists

- Save equipment you are considering for a future purchase.
- Organize wishlist entries with details such as category, brand, priority, price, product link, and notes.

### Dashboard and insights

- View a centralized summary of gyms and equipment.
- Explore inventory statistics and category breakdowns.

### Data export

- Create and share a PDF summary of a selected gym's inventory.

### Authentication and account management

- Sign in using passwordless email authentication.
- Complete onboarding and manage account settings.

## Screenshots

Product screenshots will be added here when approved application captures are available.

## Technology

FGI is built with Flutter and Dart for iOS and Android. Its intended v1.0 production stack includes:

- **Flutter and Dart** — cross-platform mobile application development.
- **Supabase** — passwordless authentication and associated backend services.
- **Isar** — on-device persistence for gym, equipment, and wishlist data.
- **RevenueCat** — purchase and restoration handling, and the source of truth for PRO subscription entitlements.
- **Resend** — transactional email delivery for applicable product workflows.

Subscription access is determined by RevenueCat entitlements. Supabase account records and locally stored Isar data are not the authority for whether an account has PRO access.

## Free and PRO

The v1.0 plan structure is:

| Feature | Free | PRO |
| --- | --- | --- |
| Gyms | 1 | Unlimited |
| Equipment items | Up to 20 | Unlimited |
| Wishlists | 1 | Unlimited |
| Gym inventory PDF export | — | Included |
| Priority support | — | Included |

Purchase pricing is configured through the app stores and RevenueCat; prices are not listed here.

## Availability

Flex Gym Inventory is designed for iOS and Android, with iOS prioritized for initial distribution. Official store links will be added here when the listings are available.

## Feedback and support

- **Product support:** Use **Contact Support** in the app or email support@heavydev.co
- **Product feedback:** Use **App Feedback** in the app or email feedback@heavydev.co

## Developer

Flex Gym Inventory is developed and published by **HEAVY DEV Co. LLC**.
Substack: @hevydevco
Bluesky: @heavydevco.bsky.social
X/Twitter: @heavydevco

## License

This repository is authored by the project owner. Contact via repository issues or the social links below for collaboration.
