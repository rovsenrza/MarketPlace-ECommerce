# MarketPlace-ECommerce
# FinalProject iOS App

A UIKit e-commerce application built with a modular architecture (`Coordinator + MVVM + Builder`) and a Firebase-backed data layer.

## Overview

This project delivers a full shopping flow:

- authentication (email/password, Google, Apple)
- product discovery and search
- filtering and category browsing
- product details with variant selection and reviews
- cart, checkout, shipping, and payment management
- order history and order details
- notifications
- wishlist
- profile and settings
- help center and real-time support chat

Current codebase size:

- `160` Swift files
- `22` screen modules
- `17` service implementations

## Architecture

### 1. Coordinator layer

Navigation is centralized in coordinators:

- `AppCoordinator` decides auth flow vs main flow
- `AuthCoordinator` handles login/register routing
- `MainTabCoordinator` handles tab-based app routing and deep screen flows

Routes are modeled as enums (`HomeRoute`, `CheckoutRoute`, etc.), which keeps navigation explicit and maintainable.

### 2. Builder layer

Each screen has a `Builder` that wires `VC + VM + dependencies` from `ServiceContainer`.

### 3. MVVM presentation layer

ViewModels manage screen state and business interactions:

- `@Published` state for UI updates
- `async/await` for async work
- `Task` + `@MainActor` for thread-safe UI state updates

### 4. Service layer

Firebase access is encapsulated behind protocols and concrete services:

- `AuthenticationServiceProtocol` / `FirebaseAuthService`
- `FirestoreServiceProtocol` / `FirestoreService`
- `CartService`, `WishlistService`, `OrdersService`, `PaymentsService`
- `ShippingAddressService`, `NotificationsService`, `ReviewService`
- `UserService`, `StorageService`, `ChatService`, etc.

`ServiceContainer` is the project-wide dependency provider.

### 5. UI layer

- UIKit programmatic UI
- reusable UI components under `UIComponents/`
- layout with SnapKit (`snp.makeConstraints`)
- compositional layouts for Home and Help Center sections

## Tech Stack

- Swift 5
- UIKit
- Combine
- SnapKit
- Firebase (Auth, Firestore, Storage, Realtime Database, Core)
- GoogleSignIn
- Kingfisher

## Project Structure

```text
FinalProject/
├── AppDelegate.swift
├── SceneDelegate.swift
├── Coordinators/
├── Models/
├── Services/
├── Screens/
├── UIComponents/
├── Extensions/
├── Assets.xcassets/
└── GoogleService-Info.plist
```

## Main Features by Module

- `HomeScreen`: featured carousel, categories, new arrivals, notification badge
- `BrowseScreen` + `CategoryDetailScreen`: category-first discovery
- `SearchResultScreen` + `FilterScreen`: search + sort/filter pipelines
- `ProductDetailsScreen`: variants, quantity, add-to-cart, wishlist, reviews
- `CartScreen` + `CheckoutScreen`: pricing summary, delivery options, order placement
- `PaymentsScreen` + `ShippingAddressScreen`: CRUD + default selection
- `MyOrderScreen` + `OrderDetailScreen` + `OrderSuccessScreen`: order lifecycle
- `NotificationsScreen`: read/unread state and detail pages
- `ProfileScreen` + `SettingsScreen`: profile data, avatar updates, password changes
- `HelpCenterScreen` + `MessageScreen`: FAQs + real-time support chat

## Getting Started

### Prerequisites

- macOS
- Xcode (with iOS 16.6+ deployment support)

### Run

1. Clone the repository.
2. Open `FinalProject.xcodeproj` in Xcode.
3. Let Swift Package Manager resolve dependencies.
4. Select scheme `FinalProject`.
5. Build and run on a simulator/device.

## Firebase Setup Notes

If you run this app on your own Firebase project:

1. Create an iOS app in Firebase Console.
2. Replace `FinalProject/GoogleService-Info.plist` with your own config.
3. Update URL scheme in `FinalProject/Info.plist` (`CFBundleURLTypes`) for Google Sign-In.
4. Enable auth providers you use:
   - Email/Password
   - Google
   - Apple
5. Configure Firestore/Storage/Realtime Database.
6. Update Realtime DB URL in `FinalProject/Services/ChatService.swift` if needed.

Expected Firestore paths used by services include:

- `users`
- `orders`
- `metadata/orderCounter`
- `categories`
- `products`
- `products/{productId}/reviews`
- `users/{uid}/cart`
- `users/{uid}/wishlist`
- `users/{uid}/payments`
- `users/{uid}/shippingAddresses`
- `users/{uid}/notifications`

Realtime Database path for chat:

- `messages/{uid}`

## Notes

- Launch screen uses storyboard (`Base.lproj/LaunchScreen.storyboard`), while app UI is otherwise code-driven.
- The repository includes `Presentation/` assets (slide deck + generator script) for project presentation.

