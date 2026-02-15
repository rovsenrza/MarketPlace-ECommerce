# MarketPlace-ECommerce

Monorepo for a Firebase-backed commerce system with:

- customer iOS app (`FinalProject`)
- admin iOS dashboard app (`DashBoardFinalProject`)
- two web dashboard prototypes (`dashboard.html` variants)

## Repository Analysis Snapshot (February 15, 2026)

- 2 Xcode projects, 3 targets, 2 runnable iOS schemes
- 221 Swift files total
- `FinalProject`: 162 Swift files, 22 screen modules, 17 service implementations
- `DashBoardFinalProject`: 58 Swift files + 1 test file
- Shared backend contract: Firestore + Realtime Database

## What Is In This Repository

| Path | Deliverable | Stack | Purpose |
| --- | --- | --- | --- |
| `FinalProject/` | Customer app | UIKit, Coordinator + MVVM + Builder, Combine, SnapKit, Firebase | End-user shopping flow |
| `DashBoardFinalProject/` | Admin dashboard app | SwiftUI, ViewModel + Repository, Combine, Firebase | Catalog/order/chat operations for admins |
| `DashBoardFinalProject/dashboard.html` | Web dashboard prototype (v1) | Vanilla HTML/CSS/JS + Firebase Web SDK | Browser-based admin prototype |
| `WebsiteDashBoardFinalProject/dashboard.html` | Web dashboard prototype (v2) | Vanilla HTML/CSS/JS + Firebase Web SDK | Extended prototype (adds mirrored order updates + notification write) |

## Feature Coverage

### Customer iOS app (`FinalProject`)

- email/password + Google + Apple authentication
- home feed, browse, search, filtering
- product details with variants and reviews
- cart, checkout, pricing summary, order placement
- payment method and shipping address management
- order history, order details, order success flow
- notifications, wishlist, profile/settings
- help center + real-time support chat

### Admin iOS app (`DashBoardFinalProject`)

- create categories and products
- attach product variants and reviews during product creation
- inspect orders and update status (`on_delivery` / `delivered`)
- view conversations and respond in real time from admin chat

### Web prototypes

- manage catalog, orders, and chat in browser
- both prototypes target the same Firebase project shape
- `WebsiteDashBoardFinalProject/dashboard.html` includes extra writebacks on delivery state change

## Architecture Summary

### `FinalProject` (customer app)

- app bootstrap: `AppDelegate` configures Firebase, `SceneDelegate` starts `AppCoordinator`
- navigation: `AppCoordinator` -> `AuthCoordinator` or `MainTabCoordinator`
- route modeling: route enums per domain (`HomeRoute`, `CheckoutRoute`, `ProfileRoute`, etc.)
- presentation: MVVM with builder-based module assembly
- data layer: protocol-first services via `ServiceContainer`

Primary frameworks used in source:

- `UIKit`, `Combine`, `SnapKit`
- `FirebaseCore`, `FirebaseAuth`, `FirebaseFirestore`, `FirebaseStorage`, `FirebaseDatabase`
- `GoogleSignIn`, `Kingfisher`

### `DashBoardFinalProject` (admin app)

- app bootstrap: SwiftUI app with `@UIApplicationDelegateAdaptor`, Firebase configured in app delegate
- composition root: `DashboardBuilder` + `ServiceContainer`
- root state owner: `ContentView` holds `CatalogViewModel`, `OrdersViewModel`, `MessagesViewModel`
- data layer: repository interfaces + Firestore/Realtime implementations

Primary frameworks used in source:

- `SwiftUI`, `Combine`
- `FirebaseCore`, `FirebaseFirestore`, `FirebaseDatabase`

## Firebase Data Contract

Firestore collections/paths used across apps:

- `users`
- `categories`
- `products`
- `products/{productId}/reviews`
- `orders`
- `metadata/orderCounter`
- `users/{uid}/cart`
- `users/{uid}/wishlist`
- `users/{uid}/payments`
- `users/{uid}/shippingAddresses`
- `users/{uid}/notifications`
- `users/{uid}/orders`

Realtime Database path:

- `messages/{uid}`

## Run Locally

### Prerequisites

- macOS with Xcode installed
- network access for Swift Package Manager dependency resolution
- Firebase project configured for Auth + Firestore + Storage + Realtime Database

### Run customer app

1. Open `FinalProject/FinalProject.xcodeproj`.
2. Select scheme `FinalProject`.
3. Build and run.

### Run admin app

1. Open `DashBoardFinalProject/DashBoardFinalProject.xcodeproj`.
2. Select scheme `DashBoardFinalProject`.
3. Build and run.

Build setting note:

- `FinalProject` target is configured with iOS deployment target `16.6`.
- `DashBoardFinalProject` currently inherits project-level deployment target `26.2` from the checked-in `.pbxproj`.

### Run web dashboard prototypes

Serve the repository over a local HTTP server (required for ES module imports), then open one of:

- `/DashBoardFinalProject/dashboard.html`
- `/WebsiteDashBoardFinalProject/dashboard.html`

## Firebase Setup Checklist

1. Replace iOS config files:
   - `FinalProject/FinalProject/GoogleService-Info.plist`
   - `DashBoardFinalProject/DashBoardFinalProject/GoogleService-Info.plist`
2. Update the Google Sign-In URL scheme in `FinalProject/FinalProject/Info.plist` (`CFBundleURLTypes`) if you use your own Firebase project.
3. Ensure Firestore and Realtime Database rules permit the required reads/writes.
4. Confirm Realtime Database URL:
   - `FinalProject/FinalProject/Services/ChatService.swift`
   - `DashBoardFinalProject/DashBoardFinalProject/Services/Realtime/RealtimeChatRepository.swift`

## Documentation Map

- `FinalProject/README.md`
- `FinalProject/docs/FinalProject_Architecture_Workflow_Documentation.md`
- `DashBoardFinalProject/docs/README.md`
- `DashBoardFinalProject/docs/ARCHITECTURE_AND_STATE_FLOW.md`
- `DashBoardFinalProject/docs/SCREEN_ARCHITECTURE_REFERENCE.md`

## Testing Status

- `DashBoardFinalProject` includes an XCTest target (`DashBoardFinalProjectTests`) with focused view model tests.
- `FinalProject` currently has no dedicated test target in this repository snapshot.
