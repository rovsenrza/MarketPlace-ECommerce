# FinalProject iOS Application
## Comprehensive Architecture, Module, Service, Workflow, and Stateflow Documentation

Version: 1.0  
Date: February 12, 2026  
Platform: iOS (UIKit, Swift, Firebase)

---

## Table of Contents

1. Document Purpose and Scope
2. Executive Summary
3. Product Context and Domain
4. Codebase Hierarchy and Module Boundaries
5. Architecture Patterns and Why They Were Chosen
6. Application Bootstrap and Runtime Lifecycle
7. Dependency Injection and Composition
8. Navigation Architecture and Route Modeling
9. Data Model Layer
10. Service Layer Deep Dive
11. Screen and ViewModel Documentation (All Pages)
12. End-to-End Workflow Narratives
13. Stateflow and Dataflow Analysis
14. UI Architecture and Reusable Component System
15. Concurrency, Reactive Streams, and Threading Strategy
16. Error Handling Strategy
17. Security and Data Sensitivity Considerations
18. Scalability and Maintainability Assessment
19. Testing Strategy and Recommended Coverage
20. Future Architecture Roadmap
21. Appendix A: Full Screen-to-VM-to-Service Mapping
22. Appendix B: Service Method Reference

---

## 1. Document Purpose and Scope

This document is a full technical architecture and implementation guide for the `FinalProject` iOS application. It is intended for:

- current maintainers who need deep context for safe changes,
- incoming developers who need onboarding documentation,
- reviewers who need a code-aligned architecture reference,
- future refactors that require a baseline of current design decisions.

The document covers:

- application hierarchy,
- design patterns,
- coordinators and route graph,
- all pages/screens,
- all ViewModels,
- all major services,
- data flow and state flow,
- critical user workflows,
- technical debt, risks, and evolution opportunities.

The content is grounded in the current source under:

- `FinalProject/Coordinators`
- `FinalProject/Screens`
- `FinalProject/Services`
- `FinalProject/Models`
- `FinalProject/UIComponents`

---

## 2. Executive Summary

`FinalProject` is a modular UIKit e-commerce application using a **Coordinator + MVVM + Builder + Service Abstraction** architecture.

Core architectural strengths:

- Navigation ownership is centralized in coordinators, especially `MainTabCoordinator`.
- Screen logic is separated from business/data logic using dedicated VMs.
- Services are protocol-driven and hide Firebase implementation details from most UI modules.
- Shared states (`CartVM`, `WishlistVM`) are reused across screens, minimizing duplicated synchronization code.
- UI is primarily programmatic with reusable component primitives under `UIComponents`.

Core architectural tradeoffs:

- `MainTabCoordinator` is feature-rich and may become a future split point.
- Testing surface is currently broad but not yet formalized as test targets.
- Service container is global by default, but builders now accept `AppServices` injection for better testability.

Overall, this architecture is strong for an expanding UIKit commerce product and has a clear path toward improved modularization and test automation.

---

## 3. Product Context and Domain

The application implements an end-to-end shopping and account experience with the following domain capabilities:

- authentication (email/password, Google, Apple),
- product browsing (home feed, browse categories, category detail),
- search and filter,
- wishlist,
- cart and pricing,
- checkout, shipping, payment,
- order management,
- notifications,
- profile and settings,
- help center and live support chat.

From an architecture perspective, the domain is split into bounded functional areas:

- Identity and Account
- Catalog and Discovery
- Commerce (cart, payment, shipping, checkout)
- Post-purchase (orders, notifications)
- Support (FAQ + chat)

The codebase mirrors this product decomposition through `Screens/`, `Services/`, and coordinator route enums.

---

## 4. Codebase Hierarchy and Module Boundaries

Top-level runtime structure:

- `AppDelegate` configures Firebase.
- `SceneDelegate` creates window and starts `AppCoordinator`.
- `AppCoordinator` decides Auth flow vs Main flow.
- `MainTabCoordinator` builds tab roots and handles all feature navigation.

Primary folder hierarchy:

- `Coordinators/`: app-level flow orchestration
- `Screens/`: feature modules (VC + VM + Builder + Cells/Views)
- `Services/`: data access and external integration
- `Models/`: domain/data contracts
- `UIComponents/`: reusable visual primitives
- `Extensions/`: shared utility extensions

Practical boundary contracts:

- Screens call services only through their VMs.
- VMs depend on protocols, not concrete Firebase classes.
- Coordinators own screen transitions and deep linking of routes.
- Builders wire concrete dependencies into VMs/VCs.

---

## 5. Architecture Patterns and Why They Were Chosen

### 5.1 Coordinator Pattern

Purpose:

- isolate navigation from view controllers,
- model route transitions with explicit enums,
- simplify deep navigation from multiple tab origins.

Used in:

- `AppCoordinator`
- `AuthCoordinator`
- `MainTabCoordinator`
- `HelpCenterCoordinator`

Benefits:

- keeps VCs focused on rendering and user interactions,
- reduces navigation duplication,
- enables route-based documentation and reasoning.

### 5.2 MVVM Pattern

Purpose:

- move state/business logic out of VCs,
- expose state through `@Published` for reactive binding,
- formalize async operations.

Common VM shape:

- `@Published isLoading`
- `@Published errorMessage`
- domain collections/properties
- async service calls
- transform and validation methods

### 5.3 Builder Pattern

Purpose:

- centralize feature assembly,
- keep constructors lightweight,
- inject dependencies cleanly.

Current approach:

- each module has `*Builder.swift`,
- builders now accept `services: AppServices = ServiceContainer.shared` where needed,
- supports both default runtime composition and test-time override.

### 5.4 Service Abstraction Pattern

Purpose:

- encapsulate Firebase APIs,
- keep data storage details outside UI layers,
- simplify mocking and testing.

Mechanism:

- protocol per service (`*ServiceProtocol`),
- concrete implementation in `Services/`,
- consumed by VMs via protocol constructor injection.

### 5.5 Reactive + Structured Concurrency Hybrid

Purpose:

- combine streaming updates (Combine) with async requests (`async/await`),
- simplify long-lived listeners and one-shot operations.

Examples:

- cart and wishlist listeners use Combine publishers,
- login/register/checkout operations use async tasks,
- chat stream uses `AsyncThrowingStream`.

---

## 6. Application Bootstrap and Runtime Lifecycle

### 6.1 Launch Sequence

1. `AppDelegate.application(_:didFinishLaunchingWithOptions:)`
2. `ServiceContainer.shared.firebaseConfigurationService.configure()`
3. `SceneDelegate.scene(_:willConnectTo:options:)`
4. Instantiate `AppCoordinator(window:)`
5. `AppCoordinator.start()` decides root flow.

### 6.2 Auth Gate

`AppCoordinator` checks `authService.isAuthenticated`:

- true -> `showMainFlow()`
- false -> `showAuthFlow()`

Transition events:

- Auth success callback from `AuthCoordinator` switches to main tabs.
- Logout callback from `MainTabCoordinator` switches back to auth.

This yields a clean and explicit session lifecycle.

---

## 7. Dependency Injection and Composition

### 7.1 AppServices Contract

`AppServices` defines all primary dependencies:

- auth, firestore, user
- catalog, category, review
- cart, wishlist
- payments, shipping, orders, notifications
- chat, filter
- pricing calculator

### 7.2 ServiceContainer

`ServiceContainer` provides lazy singleton instances of concrete services. It is the default production composition root.

Key composition chain examples:

- `UserService` <- `FirestoreService` + `StorageService` + `AuthService`
- `CartService` <- `FirestoreService`
- `WishlistService` <- `FirestoreService`
- `PricingCalculator` as stateless utility dependency

### 7.3 Builder Injection Strategy

Builders now expose injectable signatures, e.g.:

- `LoginBuilder.build(services: AppServices = ServiceContainer.shared, ...)`
- `BrowseBuilder.build(services: AppServices = ServiceContainer.shared, ...)`
- `ProfileBuilder.build(services: AppServices = ServiceContainer.shared, ...)`

This preserves convenience while enabling test composition.

---

## 8. Navigation Architecture and Route Modeling

### 8.1 High-level Coordinators

- `AppCoordinator`: root auth/main decision
- `AuthCoordinator`: login/register stack
- `MainTabCoordinator`: tab roots + feature routes
- `HelpCenterCoordinator`: optional isolated help flow

### 8.2 Route Enums

Core route enums in `MainTabCoordinator`:

- `HomeRoute`
- `BrowseRoute`
- `CategoryDetailRoute`
- `SearchResultRoute`
- `CartRoute`
- `CheckoutRoute`
- `PaymentsRoute`
- `ShippingAddressRoute`
- `MyOrderRoute`
- `OrderDetailRoute`
- `ProductDetailRoute`
- `NotificationsRoute`
- `WishlistRoute`
- `HelpCenterRoute`
- `ProfileRoute`

### 8.3 Navigation Ownership Rules

- VCs emit routes, not push logic.
- Coordinator translates route to destination.
- Route payload carries state needed by target.
- Tab switching is coordinator-owned (`.goToHome` routes) for consistency.

### 8.4 Filter Flow Decoupling

Filter apply action is carried as a callback in routes:

- `HomeRoute.filter(..., onApply: (FilterQuery) -> Void)`
- `CategoryDetailRoute.filter(..., onApply: (FilterQuery) -> Void)`

This removed concrete VC casting and tightened module boundaries.

---

## 9. Data Model Layer

Primary models and roles:

- `User`: identity and profile data
- `Product`: catalog entity, pricing, variants, ratings
- `Category`: taxonomy node
- `Review`: user feedback
- `CartItem`: product + quantity + selected variants
- `WishlistItem`: tracked product reference
- `ShippingAddress`: delivery destination
- `PaymentMethod`: billing instrument
- `Order`: transaction aggregate
- `OrderItem`: denormalized line item snapshot
- `AppNotification`: user-facing event record
- `FilterQuery`: local filter/sort state object

Notable model behavior:

- Product includes computed price/rating helpers.
- FilterQuery carries sort/category/price range in one object.
- CartItem supports variant equality matching.

Persistence note:

- most persisted entities use Firestore Codable mapping (`@DocumentID`).

---

## 10. Service Layer Deep Dive

This section documents each major service’s responsibility, data boundaries, and usage patterns.

### 10.1 FirestoreService

Responsibility:

- generic CRUD and listener abstraction over Firestore.

API classes:

- document operations (`getDocument`, `setDocument`, `updateDocument`, `deleteDocument`)
- collection operations (`getDocuments`, `addDocument`)
- listeners (`listenToCollection`, `listenToDocument`)

Design impact:

- centralizes Firestore glue code,
- reduces repetitive Firebase boilerplate across feature services.

### 10.2 FirebaseAuthService

Responsibility:

- all authentication operations and error mapping.

Capabilities:

- sign up/sign in,
- Google sign-in,
- Apple sign-in,
- password reset,
- display name/password updates,
- account deletion,
- sign out,
- current user mapping to domain `User`.

Pattern:

- maps Firebase `AuthErrorCode` into project-level `AuthError`.

### 10.3 UserService

Responsibility:

- user profile fetch/update and profile image handling.

Key flows:

- fetches from Firestore and falls back to auth user,
- syncs profile display name into Firebase Auth,
- uploads/removes image in Firebase Storage,
- stores `photoURL` in Firestore.

### 10.4 CatalogService

Responsibility:

- fetch categories and products with attached reviews.

Behavior:

- reads `products` and enriches each with `products/{id}/reviews`.

### 10.5 CategoryService

Responsibility:

- fetch single category by id.

Used by:

- product detail to resolve category display name.

### 10.6 ReviewService

Responsibility:

- streaming and writing product reviews.

Behavior:

- listens ordered by `createdAt` descending,
- submits with server timestamp.

### 10.7 CartService

Responsibility:

- cart storage, enrichment, update, and streaming.

Key logic:

- merges items with same product + same variants,
- validates stock against latest product snapshot,
- supports real-time cart updates via publisher,
- checkout operation currently clears cart.

### 10.8 WishlistService

Responsibility:

- wishlist CRUD and real-time enriched stream.

Key logic:

- enriches each wishlist item with product and reviews,
- returns sorted by `addedAt` descending,
- handles streaming via merged per-item product fetches.

### 10.9 PaymentsService

Responsibility:

- payment method CRUD and default management.

Key logic:

- ensures single default by clearing previous defaults.

### 10.10 ShippingAddressService

Responsibility:

- shipping address CRUD and default management.

Key logic:

- same single-default guarantee pattern as payment service.

### 10.11 OrdersService

Responsibility:

- order creation, fetch, and order-number generation.

Key logic:

- writes order to global `orders` and `users/{uid}/orders`,
- generates sequence-like order numbers using `metadata/orderCounter`.

### 10.12 NotificationsService

Responsibility:

- notifications CRUD and order status sync.

Key logic:

- marks notifications read,
- generates “Order Delivered” notifications on first transition to delivered,
- caches prior status in `UserDefaults` per user.

### 10.13 ChatService

Responsibility:

- support chat stream and message send over Realtime Database.

Data path:

- `messages/{uid}`

Pattern:

- `AsyncThrowingStream` for incoming messages,
- async bridge around `setValue` for sends.

### 10.14 FilterService

Responsibility:

- deterministic filtering and sorting pipeline for product lists.

Features:

- category + price filters,
- multiple sort modes: A-Z, popularity, newest, price ascending/descending, suitability.

### 10.15 StorageService

Responsibility:

- Firebase Storage upload/delete/url operations.

### 10.16 AppleSignInHelper

Responsibility:

- Apple sign-in request lifecycle, nonce generation, SHA256 nonce hash.

### 10.17 PricingCalculator (in ServiceContainer file)

Responsibility:

- subtotal/tax/shipping/total computation,
- free-shipping progress calculation.

Used by:

- cart and checkout modules.

---

## 11. Screen and ViewModel Documentation (All Pages)

This section covers every page-level screen module, including purpose, VM state/dependencies, and navigation role.

## 11.1 Authentication and Onboarding

### Login Screen

Files:

- `LoginVC`, `LoginVM`, `LoginBuilder`

Purpose:

- authenticate existing users,
- handle password recovery,
- provide Google/Apple sign-in entries.

VM state:

- `email`, `password`
- `isLoading`, `errorMessage`, `isAuthenticated`

VM dependencies:

- `AuthenticationServiceProtocol`

VM logic highlights:

- form validation using regex and min length,
- `login()` async sign-in,
- `forgotPassword()` async reset,
- social auth methods for Google and Apple.

Routes/events:

- on success triggers `onAuthenticated` closure,
- register CTA triggers `onRegisterRequested`.

### Register Screen

Files:

- `RegisterVC`, `RegisterVM`, `RegisterBuilder`

Purpose:

- create new account,
- capture name/email/password,
- support social sign-in fallback.

VM state:

- `fullName`, `email`, `password`
- `isLoading`, `errorMessage`, `isAuthenticated`
- password strength enum.

VM dependencies:

- `AuthenticationServiceProtocol`
- `UserServiceProtocol`

VM logic highlights:

- rich validation for all fields,
- `signUp()` creates auth account and user document,
- Google/Apple sign-in mirrors Login VM.

Routes/events:

- on success triggers authenticated callback,
- existing-account CTA triggers login callback.

## 11.2 Discovery and Catalog

### Home Screen

Files:

- `HomeVC`, `HomeVM`, `HomeBuilder`

Purpose:

- primary discovery feed,
- featured products, category pills, product grid,
- notification badge and entry points to browse/search/filter/product detail.

VM state:

- `featuredProducts`, `categories`, `allProducts`, `filteredProducts`
- category selection (`selectedCategoryIndex`, `selectedCategoryId`)
- `filterQuery`, `unreadNotificationsCount`
- `isLoading`, `errorMessage`

VM dependencies:

- `CatalogServiceProtocol`
- `NotificationsServiceProtocol`
- `AuthenticationServiceProtocol`
- `FilterServiceProtocol`

Workflow:

- fetches categories + products concurrently,
- applies filter pipeline,
- refreshes unread notification count,
- publishes state consumed by diffable data source.

Navigation routes emitted:

- notifications,
- browse,
- product detail,
- search,
- filter sheet with callback-based `onApply`.

### Browse Screen

Files:

- `BrowseVC`, `BrowseVM`, `BrowseBuilder`

Purpose:

- category-first discovery entry.

VM state:

- `categories`, `isLoading`, `errorMessage`

VM dependency:

- `CatalogServiceProtocol`

Routes emitted:

- `.categoryDetail(.category(category))`
- `.categoryDetail(.trending)`
- `.categoryDetail(.flashSales)`
- `.categoryDetail(.megaDeals)`

### Category Detail Screen

Files:

- `CategoryDetailVC`, `CategoryDetailVM`, `CategoryDetailBuilder`

Purpose:

- list products scoped by selected browse mode (category/trending/flash/mega).

VM state:

- `allProducts`, `filteredProducts`, `categories`
- `searchText`, `filterQuery`
- `isLoading`, `errorMessage`

VM dependencies:

- `CatalogServiceProtocol`
- `FilterServiceProtocol`

Key logic:

- mode-specific product base filtering,
- text search over title/brand,
- filter query application with shared service.

Routes emitted:

- filter sheet with callback apply,
- product detail.

### Search Result Screen

Files:

- `SearchResultVC`, `SearchResultVM`, `SearchResultBuilder`

Purpose:

- dedicated search UI with debounced-like fetch workflow.

VM state:

- `searchText`, `products`, `isLoading`, `errorMessage`

VM dependency:

- `CatalogServiceProtocol`

Logic:

- cancels previous search task,
- trims query,
- sleeps 300ms to reduce rapid churn,
- filters by title/brand/description.

Routes emitted:

- product detail,
- close.

### Filter Sheet

Files:

- `FilterVC`, `FilterVM`, `FilterBuilder`

Purpose:

- reusable bottom-sheet filter/sort input.

VM state:

- `selectedSort`, `selectedCategoryId`, `minPriceText`, `maxPriceText`
- `showsAllCategories`

Logic:

- emits normalized `FilterQuery`,
- auto-swaps min/max if user enters reversed range.

Integration:

- invoked from Home and CategoryDetail via coordinator.

## 11.3 Product and Social Proof

### Product Detail Screen

Files:

- `ProductDetailVC`, `ProductDetailVM`, `ProductDetailBuilder`

Purpose:

- product image/details,
- variant selection,
- quantity control,
- wishlist toggle,
- add to cart,
- review summary and access.

VM state:

- `product`
- `selectedVariants`, `quantity`
- `isInWishlist`, `categoryName`
- `errorMessage`, `isLoading`, `variantSelectionChanged`

VM dependencies:

- abstract stores/protocol adapters:
  - `WishlistStateStore`
  - `CartActionHandler`
- services:
  - `CategoryServiceProtocol`
  - `ReviewServiceProtocol`

Architecture note:

- VM depends on narrow behavior protocols instead of concrete `WishlistVM`/`CartVM` types directly, improving decoupling.

Routes emitted:

- back,
- reviews sheet.

### Reviews Screen

Files:

- `ReviewsVC`, `ReviewsVM`, `ReviewsBuilder`

Purpose:

- display and submit product reviews.

VM state:

- `reviews`, `selectedStars`, `reviewText`
- `isLoading`, `errorMessage`

VM dependencies:

- `ReviewServiceProtocol`
- `AuthenticationServiceProtocol`

Logic:

- real-time review listener,
- validation before submit (stars, text, auth),
- clears form after successful submit.

## 11.4 Cart and Checkout

### Cart Screen

Files:

- `CartVC`, `CartVM`, `CartBuilder`

Purpose:

- render cart items,
- quantity updates/removal,
- clear cart,
- dynamic pricing,
- checkout entry.

VM state:

- `cartItems`, `isLoading`, `errorMessage`

VM dependencies:

- `CartServiceProtocol`
- `AuthenticationServiceProtocol`

Screen-level dependencies:

- `PricingCalculatorProtocol`

Key behaviors:

- listener-backed cart updates,
- free-shipping progress UI,
- start-shopping route now emits `.goToHome` (coordinator handles tab switch).

Routes emitted:

- checkout,
- goToHome.

### Checkout Screen

Files:

- `CheckoutVC`, `CheckoutVM`, `CheckoutBuilder`

Purpose:

- select shipping/payment/defaults,
- delivery option selection,
- price summary,
- order placement.

VM state:

- selected `shippingAddress`, `paymentMethod`, `selectedDelivery`
- computed totals: `subtotal`, `shippingFee`, `tax`, `total`, `totalItems`
- `isLoading`, `errorMessage`

VM dependencies:

- `CartServiceProtocol`
- `PaymentsServiceProtocol`
- `ShippingAddressServiceProtocol`
- `OrdersServiceProtocol`
- `NotificationsServiceProtocol`
- `AuthenticationServiceProtocol`
- `PricingCalculatorProtocol`

Core order flow:

1. validate auth + shipping + payment,
2. generate order number,
3. build `Order` from cart snapshot,
4. persist order,
5. clear cart,
6. push “Order Accepted” notification,
7. return order to UI for success navigation.

Routes emitted:

- add/select shipping,
- add/select payment,
- order success.

### Add New Shipping Screen

Files:

- `AddNewShippingVC`, `AddNewShippingVM`, `AddNewShippingBuilder`

Purpose:

- create or edit shipping address.

VM state:

- `isSaving`, `errorMessage`

Dependencies:

- `ShippingAddressServiceProtocol`
- `AuthenticationServiceProtocol`

Logic:

- supports edit mode by `existingId`,
- handles default address update semantics.

### Add New Payment Screen

Files:

- `AddNewPaymentVC`, `AddNewPaymentVM`, `AddNewPaymentBuilder`

Purpose:

- add payment card method.

VM state:

- `isSaving`, `errorMessage`

Dependencies:

- `PaymentsServiceProtocol`
- `AuthenticationServiceProtocol`

Logic:

- builds `PaymentMethod` and persists.

### Shipping Address List Screen

Files:

- `ShippingAddressVC`, `ShippingAddressVM`, `ShippingAddressBuilder`

Purpose:

- list/manage addresses,
- delete/set default,
- route to add/edit screen.

VM state:

- `addresses`, `isLoading`, `errorMessage`

Dependencies:

- `ShippingAddressServiceProtocol`
- `AuthenticationServiceProtocol`

Routes emitted:

- `.addOrEditAddress(address?)`

### Payments List Screen

Files:

- `PaymentsVC`, `PaymentsVM`, `PaymentsBuilder`

Purpose:

- list/manage payment methods,
- delete/set default,
- route to add payment.

VM state:

- `payments`, `isLoading`, `errorMessage`

Dependencies:

- `PaymentsServiceProtocol`
- `AuthenticationServiceProtocol`

Routes emitted:

- `.addNewPayment`

### Order Success Screen

Files:

- `OrderSuccessVC`, `OrderSuccessVM`, `OrderSuccessBuilder`

Purpose:

- confirmation and completion state for successful checkout.

VM state:

- immutable `orderNumber`.

Integration:

- coordinator presents full-screen,
- dismiss action resets tab to Home.

## 11.5 Orders and Notifications

### My Orders Screen

Files:

- `MyOrderVC`, `MyOrderVM`, `MyOrderBuilder`

Purpose:

- list user order history,
- open order details,
- empty state with “go to store”.

VM state:

- `orders`, `isLoading`, `errorMessage`

Dependencies:

- `OrdersServiceProtocol`
- `NotificationsServiceProtocol`
- `AuthenticationServiceProtocol`

Logic:

- fetches orders,
- syncs order-status notifications from status transitions.

Routes emitted:

- `.orderDetail(order)`
- `.goToHome`

### Order Detail Screen

Files:

- `OrderDetailVC`, `OrderDetailVM`, `OrderDetailBuilder`

Purpose:

- show order-level summary and line items,
- tap-through from line item to product detail.

VM dependencies:

- `FirestoreServiceProtocol`

Logic:

- fetches product by id for order item selection.

Routes emitted:

- `.productDetail(product)`

### Notifications Screen

Files:

- `NotificationsVC`, `NotificationsVM`, `NotificationsBuilder`

Purpose:

- user notifications feed with read/unread transitions.

VM state:

- `notifications`, `isLoading`, `errorMessage`

Dependencies:

- `NotificationsServiceProtocol`
- `AuthenticationServiceProtocol`

Logic:

- load notifications,
- mark specific entry as read,
- local array patch for immediate UI update.

Routes emitted:

- `.detail(notification)`

### Notification Detail Screen

Files:

- `NotificationDetailVC`, `NotificationDetailVM`, `NotificationDetailBuilder`

Purpose:

- display full notification details.

VM state:

- immutable notification payload.

## 11.6 Wishlist and Profile

### Wishlist Screen

Files:

- `WishlistVC`, `WishlistVM`, `WishlistBuilder`

Purpose:

- render favorite products,
- remove favorites,
- route to product details,
- empty-state CTA to home.

VM state:

- `wishlistItems`, `categories`, `isLoading`, `errorMessage`

Dependencies:

- `WishlistServiceProtocol`
- `FirestoreServiceProtocol`
- `AuthenticationServiceProtocol`

Logic:

- optimistic add/remove toggles,
- listener setup with user switching safeguards,
- category fetch for product card labeling.

Routes emitted:

- `.productDetail(product)`
- `.goToHome`

### Profile Screen

Files:

- `ProfileVC`, `ProfileVM`, `ProfileBuilder`

Purpose:

- display profile data and hub links to user account modules.

VM state:

- `user`, `isLoading`, `errorMessage`

Dependencies:

- `UserServiceProtocol`
- `AuthenticationServiceProtocol`

Logic:

- fetch user data,
- update/remove profile image,
- sign out via auth service.

Routes emitted:

- settings,
- orders,
- wishlist,
- payments,
- notifications,
- shipping address,
- help center,
- logout callback.

### Settings Screen

Files:

- `SettingsVC`, `SettingsVM`, `SettingsBuilder`

Purpose:

- account settings: profile name and password updates, logout.

VM state:

- `isLoading`, `errorMessage`, `successMessage`, `currentUser`

Dependencies:

- `UserServiceProtocol`
- `AuthenticationServiceProtocol`

Logic:

- validate and update display name,
- validate and update password with recent-login error awareness,
- logout path.

## 11.7 Help and Support

### Help Center Screen

Files:

- `HelpCenterVC`, `HelpCenterVM`, `HelpCenterBuilder`

Purpose:

- structured support categories, order status help, trending questions.

VM state:

- static support content arrays.

Routes emitted:

- detail article,
- chat.

### Help Center Detail Screen

Files:

- `HelpCenterDetailVC`, `HelpCenterDetailVM`, `HelpCenterDetailBuilder`

Purpose:

- detailed article view and optional chat escalation.

VM state:

- `title`, `subtitle`, `body`.

### Message (Support Chat) Screen

Files:

- `MessageVC`, `MessageVM`, `MessageBuilder`

Purpose:

- realtime chat between user and support/admin.

VM state:

- `messages`, `inputText`, `errorMessage`
- metadata: support name and online status

Dependencies:

- `ChatServiceProtocol`
- `AuthenticationServiceProtocol`

Logic:

- starts/stops async stream task,
- deduplicates by `message.id`,
- sends user-authored messages with sender metadata.

---

## 12. End-to-End Workflow Narratives

### 12.1 App Launch and Session Resolution

- Firebase configured.
- App coordinator starts.
- Auth check splits experience:
  - unauthenticated -> Login/Register
  - authenticated -> Tab shell

This keeps startup deterministic and explicit.

### 12.2 Authentication Workflow

1. User enters login credentials or social auth.
2. VM validates and sends auth request.
3. VM updates `isLoading`, then success/error.
4. VC observes `isAuthenticated` and triggers callback.
5. Coordinator swaps root flow to main tabs.

Register flow mirrors this and additionally creates user document.

### 12.3 Discovery to Product Detail Workflow

1. Home loads categories/products.
2. User taps category/filter/search.
3. Route emitted to coordinator.
4. Coordinator pushes target module or presents filter sheet.
5. User selects product -> Product Detail.

State continuity:

- shared wishlist/cart VMs keep favorite/cart indicators consistent between screens.

### 12.4 Wishlist Interaction Workflow

1. Product card favorite toggled.
2. `WishlistVM.toggleWishlistAsync` chooses add/remove.
3. Optimistic UI mutation in VM.
4. Service persistence call.
5. On failure, VM rollback + error.

### 12.5 Cart and Checkout Workflow

1. Product Detail -> `CartVM.addToCart`.
2. Cart service validates stock and merges duplicates.
3. Cart screen reacts via listener publisher.
4. User proceeds to checkout.
5. Checkout VM refreshes default shipping/payment.
6. Place order builds order aggregate and persists.
7. Cart cleared.
8. Notification generated.
9. Order success screen presented.

### 12.6 Order and Notification Sync Workflow

1. Orders loaded in My Orders.
2. Notifications service compares cached status vs current.
3. First delivered transition creates “Order Delivered” notification.
4. Notifications screen displays feed.
5. Opening detail marks read.

### 12.7 Help Escalation Workflow

1. User opens Help Center.
2. Selects category/trending question for detail.
3. If issue unresolved, user opens chat.
4. Message VM streams realtime support messages.

---

## 13. Stateflow and Dataflow Analysis

Stateflow in this app is **feature-local with selected shared shards**.

### 13.1 Shared State Shards

- `CartVM` (shared across home/product/cart/checkout/tab badge)
- `WishlistVM` (shared across home/category/search/product/wishlist)

Benefits:

- single source of truth for favorites/cart,
- reduced re-fetch storms,
- consistent badges and button states.

### 13.2 Feature-Local State

Each VM typically has:

- `isLoading`
- `errorMessage`
- domain payload fields

Transition model example:

- Idle -> Loading -> Success
- Idle -> Loading -> Error
- Success -> Loading (refresh)

### 13.3 Route-Driven State Transfers

Routes carry payloads that avoid hidden shared mutable dependencies:

- `Product` object for product details,
- `Order` object for order details,
- `FilterQuery` + `onApply` callback for filter flow.

### 13.4 Dataflow Boundaries

- VC emits user intent.
- VM transforms intent to service call.
- Service reads/writes backend.
- VM publishes new state.
- VC renders state.
- Coordinator handles navigation side-effects.

### 13.5 Stateflow Example: Filter

- Home/Category emits route `.filter(..., onApply: callback)`.
- Coordinator presents Filter screen.
- Filter VM builds new `FilterQuery`.
- onApply callback updates source VM query.
- source VM recomputes filtered list.

This flow avoids coordinator casts and keeps state ownership at source VM.

---

## 14. UI Architecture and Reusable Component System

UI strategy:

- UIKit programmatic views,
- SnapKit layout constraints,
- diffable data sources for list-like UI,
- compositional layouts for advanced sections.

### 14.1 Reusable UI Libraries in Project

Under `UIComponents`:

- Buttons: `PrimaryButton`, `SocialLoginButton`, `IconButton`, etc.
- Labels/Typography: `TitleLabel`, `SubtitleLabel`, `SectionHeaderLabel`, `AppTypography`
- Inputs: `InsetTextField`
- Loaders: `LoadingView`, `SectionLoadingView`
- Generic views: `CardView`, `BadgeView`, `EmptyStateView`, `InfoCard`, `SummaryRowView`
- Tab bar customization: `MainTabBarController`, `CartButton`

### 14.2 Feature-level UI Modularity

Most screen modules contain:

- feature cells,
- feature section item enums,
- feature-specific layout builders.

Examples:

- Home has its own section enum + layout builder.
- Help Center has a dedicated compositional layout builder.

This balances global reuse and feature autonomy.

---

## 15. Concurrency, Reactive Streams, and Threading Strategy

### 15.1 `@MainActor` VM Discipline

Most VMs are marked `@MainActor`, ensuring that published state mutations are UI-safe by default.

### 15.2 Async/Await for Operations

Used for:

- auth operations,
- CRUD requests,
- checkout sequence,
- profile updates.

Benefits:

- linear readable workflows,
- simpler error propagation,
- easier cancellation integration.

### 15.3 Combine for Ongoing Streams

Used for:

- Firestore listeners (cart/wishlist/reviews/document/collection),
- UI subscriptions to `@Published` states,
- tab badge updates.

### 15.4 AsyncThrowingStream for Chat

Used where backend API is callback-observer based (Realtime DB). VM manages lifecycle with `start()/stop()` task control.

### 15.5 Task Cancellation Patterns

Present in:

- search VM (cancels old query),
- cart/wishlist fetch/listener setup,
- message stream restart.

This reduces stale updates and race conditions.

---

## 16. Error Handling Strategy

Current strategy is user-facing and VM-centric:

- service throws typed or raw errors,
- VM catches and maps to `errorMessage`,
- VC renders alerts/inline messages.

Strengths:

- simple and consistent per screen,
- clear UI ownership of error rendering.

Improvement opportunities:

- standardized domain error envelope,
- cross-cutting telemetry hooks,
- retry metadata (retryable/non-retryable).

---

## 17. Security and Data Sensitivity Considerations

Handled today:

- Firebase-authenticated user access patterns,
- per-user collections for cart/wishlist/payments/addresses/notifications,
- no direct secret embedding in VM logic.

Potential enhancements:

- mask card data handling in memory/UI logs,
- enforce stricter Firestore security rules for user-scoped paths,
- explicit PII redaction in diagnostics,
- centralized input sanitization helpers.

---

## 18. Scalability and Maintainability Assessment

### 18.1 Current Scalability Strengths

- protocolized service layer,
- route-based coordinator flow,
- shared VMs for cross-screen consistency,
- modular screen folders.

### 18.2 Pressure Points

- `MainTabCoordinator` is large and aggregates many route handlers.
- no dedicated test target coverage visible in project.
- expanding service logic may benefit from repository/use-case decomposition.

### 18.3 Recommended Modularization Path

1. Split `MainTabCoordinator` into feature coordinators per tab.
2. Introduce use-case layer for complex domain transactions.
3. Add test doubles for `AppServices` and start VM unit coverage.
4. Introduce analytics/event bus abstraction for observability.

---

## 19. Testing Strategy and Recommended Coverage

A practical staged plan:

### Stage 1: VM Unit Tests

Priority modules:

- `CheckoutVM` (highest business risk),
- `CartVM`, `WishlistVM`,
- `LoginVM`, `RegisterVM`,
- `NotificationsVM`.

Test focus:

- state transitions,
- validation and error mapping,
- route-triggering conditions,
- async cancellation behavior.

### Stage 2: Service Contract Tests

With emulator/fake backends:

- cart merge/stock rules,
- default address/payment invariants,
- order number generation monotonicity,
- notification status-sync logic.

### Stage 3: Coordinator Integration Tests

Use spy router to verify:

- route-to-destination mapping,
- back/close behavior,
- modal vs push transitions.

### Stage 4: Critical UI Smoke Tests

Automate core journeys:

- login -> browse -> add cart -> checkout -> success,
- profile settings update,
- wishlist add/remove,
- notification read flow.

---

## 20. Future Architecture Roadmap

### Near-term (1-2 iterations)

- add test target and initial VM suites,
- split `MainTabCoordinator` by domain,
- standardize error model and user-facing copy.

### Mid-term (3-6 iterations)

- introduce domain use-cases,
- add offline cache strategy for catalog and wishlist,
- add feature flags for controlled rollout.

### Long-term

- evaluate modular targets/packages,
- evolve towards independent feature teams,
- optionally introduce SwiftUI in leaf components while preserving coordinator-based navigation.

---

## 21. Appendix A: Full Screen-to-VM-to-Service Mapping

| Screen Module | VM | Core Services/Dependencies | Primary Outbound Routes |
|---|---|---|---|
| Login | `LoginVM` | `AuthenticationServiceProtocol` | authenticated, register |
| Register | `RegisterVM` | `AuthenticationServiceProtocol`, `UserServiceProtocol` | authenticated, login |
| Home | `HomeVM` | catalog, notifications, auth, filter | notifications, browse, product detail, search, filter |
| Browse | `BrowseVM` | catalog | category detail |
| Category Detail | `CategoryDetailVM` | catalog, filter | product detail, filter |
| Search Result | `SearchResultVM` | catalog | product detail, close |
| Filter | `FilterVM` | local query state | apply callback |
| Product Detail | `ProductDetailVM` | wishlist store, cart handler, category, review | back, reviews |
| Reviews | `ReviewsVM` | review, auth | dismiss (modal behavior) |
| Cart | `CartVM` | cart, auth, pricing calculator in VC | checkout, goToHome |
| Checkout | `CheckoutVM` | cart, payments, shipping, orders, notifications, auth, pricing | add/select shipping/payment, success |
| Add New Shipping | `AddNewShippingVM` | shipping, auth | onSaved callback |
| Shipping Address | `ShippingAddressVM` | shipping, auth | add/edit address |
| Add New Payment | `AddNewPaymentVM` | payments, auth | onSaved callback |
| Payments | `PaymentsVM` | payments, auth | add new payment |
| Order Success | `OrderSuccessVM` | order number payload | dismiss callback |
| My Orders | `MyOrderVM` | orders, notifications, auth | order detail, goToHome |
| Order Detail | `OrderDetailVM` | firestore | product detail |
| Notifications | `NotificationsVM` | notifications, auth | notification detail |
| Notification Detail | `NotificationDetailVM` | local payload only | back |
| Wishlist | `WishlistVM` | wishlist, firestore, auth | product detail, goToHome |
| Profile | `ProfileVM` | user, auth | settings/orders/wishlist/payments/notifications/shipping/help/logout |
| Settings | `SettingsVM` | user, auth | logout callback |
| Help Center | `HelpCenterVM` | static content | detail, chat |
| Help Center Detail | `HelpCenterDetailVM` | local payload only | chat callback |
| Message | `MessageVM` | chat, auth | dismiss |

---

## 22. Appendix B: Service Method Reference

### AuthenticationServiceProtocol

- `signUp(email:password:fullName:)`
- `signIn(email:password:)`
- `signInWithGoogle(presentingViewController:)`
- `signInWithApple(nonce:idTokenString:fullName:)`
- `signOut()`
- `resetPassword(email:)`
- `updateDisplayName(_:)`
- `updatePassword(_:)`
- `deleteAccount()`

### FirestoreServiceProtocol

- `getDocument(collection:documentId:)`
- `getDocuments(collection:)`
- `setDocument(collection:documentId:data:merge:)`
- `setData(collection:documentId:data:merge:)`
- `addDocument(collection:data:)`
- `updateDocument(collection:documentId:data:)`
- `deleteDocument(collection:documentId:)`
- `listenToCollection(collection:)`
- `listenToDocument(collection:documentId:)`

### CatalogServiceProtocol

- `fetchCategories()`
- `fetchProductsWithReviews()`

### CategoryServiceProtocol

- `fetchCategory(id:)`

### ReviewServiceProtocol

- `listenToReviews(productId:)`
- `submitReview(productId:review:)`

### CartServiceProtocol

- `fetchCartItems(userId:)`
- `addToCart(userId:cartItem:)`
- `updateCartItemQuantity(userId:cartItemId:quantity:)`
- `removeFromCart(userId:cartItemId:)`
- `clearCart(userId:)`
- `listenToCart(userId:)`
- `checkoutCart(userId:)`

### WishlistServiceProtocol

- `fetchWishlistItems(userId:)`
- `addToWishlist(userId:wishlistItem:)`
- `removeFromWishlist(userId:wishlistItemId:)`
- `isInWishlist(userId:productId:)`
- `listenToWishlist(userId:)`

### PaymentsServiceProtocol

- `fetchPayments(userId:)`
- `addPayment(userId:payment:)`
- `deletePayment(userId:paymentId:)`
- `setDefaultPayment(userId:paymentId:)`

### ShippingAddressServiceProtocol

- `fetchAddresses(userId:)`
- `addAddress(userId:address:)`
- `updateAddress(userId:addressId:data:)`
- `deleteAddress(userId:addressId:)`
- `setDefaultAddress(userId:addressId:)`

### OrdersServiceProtocol

- `createOrder(userId:order:)`
- `fetchOrders(userId:)`
- `nextOrderNumber()`

### NotificationsServiceProtocol

- `addNotification(userId:notification:)`
- `fetchNotifications(userId:)`
- `markNotificationRead(userId:notificationId:)`
- `syncOrderStatusNotifications(userId:orders:)`

### ChatServiceProtocol

- `messagesStream(userId:)`
- `sendMessage(userId:text:senderId:senderName:isFromAdmin:)`

### StorageServiceProtocol

- `uploadImage(_:path:compressionQuality:)`
- `deleteFile(at:)`
- `getDownloadURL(for:)`

### FilterServiceProtocol

- `applyFilters(products:query:fallbackCategoryId:)`

### PricingCalculatorProtocol

- `makeSummary(cartItems:deliveryFee:applyFreeShippingThreshold:)`
- `makeFreeShippingProgress(subtotal:)`

---

## Closing Notes

This documentation captures the current architecture and implementation shape of `FinalProject` as of February 12, 2026. It is intentionally comprehensive and operationally oriented so it can be used both as onboarding material and as a change-safety reference.

For maintainability, keep this document versioned alongside the codebase and update it whenever:

- a new screen module is introduced,
- coordinator routes change,
- service contracts are modified,
- shared state ownership changes,
- checkout/order/payment logic changes.


---

## 23. Detailed Screen Stateflow Playbooks

This section provides operationally detailed stateflow playbooks for each user-facing page so maintainers can reason about behavior under normal, empty, loading, and failure states.

### 23.1 LoginVC + LoginVM Stateflow

Initial state:

- `email = ""`, `password = ""`
- `isLoading = false`
- `errorMessage = nil`
- `isAuthenticated = false`

Transitions:

1. User edits email/password.
2. Combine binding clears prior `errorMessage`.
3. User taps login.
4. `isFormValid` guard may fail and set validation error.
5. On valid form, VM enters loading state and executes async sign-in.
6. On success: `isAuthenticated = true`; VC callback notifies coordinator.
7. On failure: `errorMessage` set, loading false, remain on same screen.

Failure surfaces:

- invalid email format,
- weak/short password,
- auth service errors mapped through `AuthError`.

Recovery path:

- user edits any field -> clears error,
- retries login or uses social auth.

### 23.2 RegisterVC + RegisterVM Stateflow

Initial state adds `fullName` and password strength calculations.

Transitions:

1. User enters full name/email/password.
2. Form validation derives button enabled state and strength indicator.
3. On submit, VM validates all fields with targeted error messages.
4. VM performs sign-up; on success, writes user document via user service.
5. `isAuthenticated` set true -> coordinator transitions to main flow.

Error handling:

- field-level validation before network call,
- Firebase-auth-mapped errors after network call,
- non-auth failures mapped to generic unexpected error.

State reset behavior:

- editing any bound field clears `errorMessage`.

### 23.3 HomeVC + HomeVM Stateflow

Home has one of the densest state machines because it combines catalog, categories, filter state, and notification badge state.

Primary data states:

- `featuredProducts`
- `categories`
- `allProducts`
- `filteredProducts`
- `selectedCategoryIndex`
- `filterQuery`
- `unreadNotificationsCount`

Flow:

1. `viewDidLoad` -> bind state -> fetch data -> fetch wishlist.
2. VM sets `isLoading = true` and loads mock featured carousel.
3. VM executes concurrent requests (`fetchCategories`, `fetchProductsWithReviews`).
4. VM stores results and applies filter pipeline.
5. VM sets loading false.
6. VC diffable data source refreshes sections.

Notification subflow:

1. `viewWillAppear` triggers unread count refresh.
2. VM fetches notifications for current user.
3. Count of unread is published.
4. VC updates badge visibility and value.

Filtering subflow:

- category taps update selected index and fallback category filter,
- filter sheet returns `FilterQuery` via callback,
- VM recomputes `filteredProducts`.

### 23.4 BrowseVC + BrowseVM Stateflow

Browse is intentionally simple and stable:

- fetch category list,
- render grid/list sections,
- emit route based on tile selection.

States:

- loading state during fetch,
- error state on service failure,
- steady-state list display.

Routing outputs directly model marketing/curated discovery modes:

- trending,
- flash sales,
- mega deals,
- explicit category.

### 23.5 CategoryDetailVC + CategoryDetailVM Stateflow

State dimensions:

- product source mode (`category`, `trending`, `flash`, `mega`),
- filter query,
- search text,
- async catalog load.

Flow:

1. Screen starts by fetching categories and products.
2. Products are first constrained by mode (`baseProducts`).
3. Filter query applies category/price/sort logic.
4. Text search applies title/brand contains logic over filtered base.
5. UI reflects final `filteredProducts`.

This layered pipeline prevents duplicated logic and preserves deterministic ordering:

- mode filter,
- structural filter,
- text filter.

### 23.6 SearchResultVC + SearchResultVM Stateflow

Search state machine:

1. Query changes cancel previous task.
2. Empty query clears products and loading state.
3. Non-empty query enters loading and starts delayed fetch task.
4. Task waits 300ms to avoid burst requests.
5. Product fetch and local filter execute.
6. On completion, `products` updated and loading ends.

Cancellation safety:

- `Task.isCancelled` checks after sleep and after fetch.

### 23.7 FilterVC + FilterVM Stateflow

Filter sheet state is local and transient.

Input state:

- selected sort,
- selected category,
- min/max price text,
- category expansion toggle.

Apply behavior:

- parse text to optional numeric values,
- normalize reversed range,
- emit `FilterQuery` through `onApply` closure.

Ownership model:

- filter sheet never mutates product lists directly,
- source VM remains owner of catalog state.

### 23.8 ProductDetailVC + ProductDetailVM Stateflow

State dimensions:

- selected variant values,
- quantity,
- wishlist status,
- live reviews,
- resolved category display text,
- cart operation error bridge.

Flow components:

1. VM initializes default variants from product metadata.
2. VM subscribes to wishlist stream to keep heart state synced.
3. VM subscribes to review stream to keep rating section current.
4. VM fetches category title for display label.
5. User interactions mutate quantity/variants/wishlist/cart intents.

Important integration detail:

- cart and wishlist are abstracted via minimal behavior protocols, improving flexibility of shared state integration.

### 23.9 ReviewsVC + ReviewsVM Stateflow

Review flow:

1. On init, VM starts review listener and sets loading true.
2. Stream updates replace `reviews` list.
3. User sets stars and review text.
4. Submit validates star count, non-empty text, and authenticated user.
5. On success, form fields reset.

Edge states:

- listener errors appear in `errorMessage`,
- invalid submit throws targeted validation errors.

### 23.10 CartVC + CartVM Stateflow

Cart has a persistent listener-backed model:

1. `fetchCartItems()` guards auth; signed-out clears local state.
2. Initial fetch hydrates cart and sets listener once per user id.
3. Listener streams updates and keeps UI synchronized.
4. UI updates summary values through pricing calculator.

Mutation flows:

- add item,
- update quantity,
- remove item,
- clear cart,
- checkout clear.

Business constraints:

- cart service validates stock and merges variant-equivalent items.

### 23.11 CheckoutVC + CheckoutVM Stateflow

Checkout is the highest-risk transactional stateflow.

Pre-checkout states:

- selected defaults loaded from address and payment services,
- delivery option selected,
- totals recomputed from cart state and selected delivery fee.

Place-order transactional sequence:

1. Validate authentication.
2. Validate shipping address presence.
3. Validate payment method presence.
4. Generate next order number.
5. Snapshot cart items into `OrderItem` list.
6. Create order aggregate.
7. Persist order and user-order mirror.
8. Clear cart.
9. Emit order-accepted notification.
10. Return order and route to success screen.

Any exception keeps user in checkout with surfaced error.

### 23.12 AddNewShippingVC + AddNewShippingVM Stateflow

Two-mode behavior:

- create mode: constructs `ShippingAddress` and adds document,
- edit mode: updates existing document fields and optionally default status.

State transitions:

- idle -> saving -> success/failure.

On success, VC triggers `onSaved` closure, coordinator pops to previous screen.

### 23.13 ShippingAddressVC + ShippingAddressVM Stateflow

State dimensions:

- addresses list,
- loading,
- error.

Flows:

- fetch on appearance,
- delete selected address,
- set selected address as default with local array patch.

Route handoff:

- add/edit action delegates to coordinator route.

### 23.14 AddNewPaymentVC + AddNewPaymentVM Stateflow

Behavior is create-focused:

- collect cardholder/card/expiry/cvv/default flag,
- build `PaymentMethod`,
- submit via service.

State transitions:

- idle -> saving -> success/error.

On success:

- optional callback closes flow.

### 23.15 PaymentsVC + PaymentsVM Stateflow

State dimensions:

- payment methods list,
- loading,
- error.

Operations:

- fetch list sorted with default first,
- delete item,
- set default with local map transformation.

Rule enforcement:

- service clears old defaults before setting a new one.

### 23.16 OrderSuccessVC + OrderSuccessVM Stateflow

This module is intentionally minimal:

- displays order number confirmation,
- exposes dismiss path.

Coordinator behavior on dismiss:

- returns user to home tab.

### 23.17 MyOrderVC + MyOrderVM Stateflow

Flow:

1. On appear, VM fetches orders for authenticated user.
2. VM updates list and loading states.
3. VM triggers order-status-to-notification synchronization.
4. VC renders table or empty state.

Navigation actions:

- select order -> route to detail,
- empty-state CTA -> route to home tab via coordinator.

### 23.18 OrderDetailVC + OrderDetailVM Stateflow

State ownership:

- immutable input order,
- transient fetch for product lookups from order items.

Flow:

- user taps order line item,
- VM fetches product by id,
- VC emits route to product detail with fetched product.

### 23.19 NotificationsVC + NotificationsVM Stateflow

Flow:

1. On appear, fetch notifications for user.
2. Render sorted timeline.
3. Selecting notification marks read (if unread).
4. Local list is patched to reflect read state immediately.
5. Detail route emitted.

### 23.20 NotificationDetailVC + NotificationDetailVM Stateflow

Simple read-only module:

- receives immutable notification payload,
- renders detailed content.

### 23.21 WishlistVC + WishlistVM Stateflow

Wishlist flow combines optimistic updates with streaming sync.

Load behavior:

- fetches categories (once), then wishlist items,
- establishes listener per user,
- avoids duplicate listener setup using state guards.

Mutation behavior:

- add/remove/toggle provide async and wrapper methods,
- optimistic insertion/removal with rollback on failure.

UI state:

- loading view,
- collection grid,
- dedicated empty-state view.

Routes:

- product detail,
- go-to-home.

### 23.22 ProfileVC + ProfileVM Stateflow

Flow:

1. On appear, fetch profile data.
2. If Firestore doc missing, fallback to auth user and create doc.
3. Render profile identity + navigation cards.
4. Avatar updates call image upload/removal routines.

Navigation output is broad and profile acts as account hub.

### 23.23 SettingsVC + SettingsVM Stateflow

States:

- loading, error, success feedback, current user.

Operations:

- fetch current user,
- update display name with validation,
- update password with validation and recent-login error path,
- logout.

### 23.24 HelpCenterVC + HelpCenterVM Stateflow

Help center state is static content-backed, no async fetch requirement.

Flow:

- render sections from VM arrays,
- select category/question routes to detailed article,
- “chat” action escalates to live support flow.

### 23.25 HelpCenterDetailVC + HelpCenterDetailVM Stateflow

Pure content state:

- title/subtitle/body immutable payload,
- optional chat callback for escalation.

### 23.26 MessageVC + MessageVM Stateflow

Chat state dimensions:

- message list,
- draft input,
- stream task lifecycle,
- user auth availability.

Lifecycle:

- `start()` begins stream and resets state,
- incoming messages deduped by id,
- `stop()` cancels stream,
- send action validates non-empty text and auth.

Error behavior:

- stream cancellation-safe error surface,
- send errors set `errorMessage`.

---

## 24. Operational Edge Cases and Failure Scenarios

### 24.1 Signed-Out Mid-Session Behavior

Several VMs guard on `authService.currentUser` before network calls.

Observed behavior:

- cart/wishlist/address/payment/notification/order VMs clear or no-op when user is missing.
- chat blocks send/stream and surfaces sign-in requirement.

Recommendation:

- central session invalidation event could proactively route users to auth flow.

### 24.2 Listener Lifecycle and Duplicate Subscription Risks

Handled well in:

- `CartVM` (listener reuse guards + cancellation),
- `WishlistVM` (listener reuse guards + cancellation),
- `MessageVM` (stream task cancellation before restart).

Remaining consideration:

- maintain same defensive pattern in any future listener-driven modules.

### 24.3 Data Consistency Between Local Optimistic State and Backend

Wishlist VM performs optimistic updates and rollback.

Implications:

- better responsiveness,
- temporary inconsistency windows during network delay.

This is acceptable for non-critical data as long as rollback remains robust.

### 24.4 Order Number Generation Concurrency

`OrdersService.nextOrderNumber` reads current counter and writes incremented value.

Potential issue under high concurrency:

- race conditions without transaction semantics.

Recommendation:

- migrate to Firestore transaction/increment operation for strict monotonic guarantees.

### 24.5 Payment and Address Sensitive Data Handling

`PaymentMethod` currently stores `cardNumber` and `cvv` fields in model.

For production hardening:

- avoid storing raw CVV entirely,
- tokenize payment data via payment gateway,
- mask card fields in logs and UI snapshots.

### 24.6 Notification Status Cache in UserDefaults

Order status sync uses `UserDefaults` cache per user.

Risk profile:

- lightweight and effective,
- local cache may drift if app state is reset.

Acceptable for user-facing notification deduplication; not for critical ledger logic.

---

## 25. Architecture Decision Log (Current Snapshot)

### Decision 1: UIKit + Programmatic Layout

Reasoning:

- strong control over custom layouts,
- compositional layout support,
- reduced storyboard coupling.

### Decision 2: Coordinator-First Navigation

Reasoning:

- explicit route graph,
- easier multi-entry navigation,
- better separation from VC.

### Decision 3: Shared Cart and Wishlist VM Instances

Reasoning:

- maintain cross-screen consistency,
- avoid repetitive rehydration.

### Decision 4: Protocolized Service Layer

Reasoning:

- abstract Firebase details,
- allow unit testing with mocks,
- centralize data access rules.

### Decision 5: Builder-Based Module Assembly

Reasoning:

- formal dependency assembly point,
- cleaner VC constructors,
- easier dependency migration and test override.

### Decision 6: Callback-Carried Filter Apply Action

Reasoning:

- remove coordinator reliance on concrete VC casting,
- preserve source VM ownership of filter state.

---

## 26. Suggested Documentation Maintenance Checklist

When changing a module, update this document if any of the following changed:

- new route enum case,
- builder signature,
- VM published state contract,
- service protocol method,
- persistence collection path,
- checkout/order/notification business rules,
- shared VM ownership,
- tab or coordinator topology.

Minimum update items per change:

1. affected section in Screen Documentation,
2. mapping table row in Appendix A,
3. service method list in Appendix B (if service changed),
4. workflow narrative in Section 12 (if user journey changed).

This keeps architecture documentation operational, not stale.


---

## 27. Sequence-Level Interaction Blueprints

This section captures concrete interaction sequences in a pseudo-sequence format to make integration behavior explicit for reviewers and future refactors.

### 27.1 Login Sequence (Email/Password)

Actors:

- `LoginVC`
- `LoginVM`
- `FirebaseAuthService`
- `AuthCoordinator`

Sequence:

1. `LoginVC` user taps login.
2. `LoginVC` invokes `await vm.login()`.
3. `LoginVM` validates local form state.
4. `LoginVM` -> `authService.signIn(email,password)`.
5. `FirebaseAuthService` invokes Firebase Auth sign-in.
6. Result success returns `AuthResult` mapped to domain user.
7. `LoginVM` sets `isAuthenticated = true`.
8. `LoginVC` observes and triggers `onAuthenticated` callback.
9. `AuthCoordinator` forwards callback to `AppCoordinator`.
10. `AppCoordinator` replaces root flow with `MainTabCoordinator`.

Failure sequence:

- if step 5 fails, `FirebaseAuthService` maps error,
- `LoginVM` sets `errorMessage` and `isAuthenticated = false`,
- VC remains in place and prompts retry.

### 27.2 Home Filter Sequence

Actors:

- `HomeVC`
- `MainTabCoordinator`
- `FilterVC`
- `FilterVM`
- `HomeVM`

Sequence:

1. User taps filter button in Home header.
2. `HomeVC` emits `.filter(categories,currentQuery,hideCategoryFilter,onApply)` route.
3. Coordinator receives route and presents Filter module.
4. User edits sort/category/price criteria in Filter UI.
5. `FilterVM.makeQuery()` creates normalized query.
6. `FilterVC` invokes `onApply(query)` callback.
7. Callback executes `HomeVM.applyFilterQuery(query)`.
8. `HomeVM` recomputes filtered products via `FilterService`.
9. `HomeVC` receives published update and applies diffable snapshot.

Architecture result:

- filter is a reusable transient module,
- source VM remains owner of source-of-truth list state.

### 27.3 Add to Cart Sequence from Product Detail

Actors:

- `ProductDetailVC`
- `ProductDetailVM`
- `CartVM` (via `CartActionHandler`)
- `CartService`
- `FirestoreService`

Sequence:

1. User chooses variants and quantity.
2. User taps “Add to Cart”.
3. `ProductDetailVM.addToCart()` forwards payload through `cartHandler`.
4. `CartVM.addToCart(product,quantity,variants)` builds `CartItem`.
5. `CartVM` calls `cartService.addToCart(...)`.
6. `CartService` fetches latest product for stock validation.
7. `CartService` fetches existing cart and checks variant-equivalent item.
8. If match exists, quantity is merged and updated.
9. If no match, new cart document is inserted.
10. Cart listener publishes updated cart list.
11. Cart badge and cart screens update reactively.

### 27.4 Checkout Place Order Sequence

Actors:

- `CheckoutVC`
- `CheckoutVM`
- `OrdersService`
- `CartService`
- `NotificationsService`

Sequence:

1. User taps Place Order.
2. `CheckoutVC` invokes async `placeOrder(cartItems)`.
3. `CheckoutVM` validates auth, shipping, and payment.
4. `CheckoutVM` gets order number from `OrdersService.nextOrderNumber()`.
5. `CheckoutVM` maps cart items to `OrderItem` snapshot.
6. `CheckoutVM` constructs `Order` aggregate including totals.
7. `CheckoutVM` calls `OrdersService.createOrder(userId,order)`.
8. `CheckoutVM` calls `CartService.checkoutCart(userId)` (clear cart).
9. `CheckoutVM` calls `NotificationsService.addNotification(...)` for accepted status.
10. Order returned to VC; VC emits success route.
11. Coordinator presents `OrderSuccessVC` full-screen.

Failure handling:

- any throw keeps user in checkout screen with error display,
- cart is only cleared after successful order creation.

### 27.5 Order Delivered Notification Sync Sequence

Actors:

- `MyOrderVM`
- `OrdersService`
- `NotificationsService`
- `UserDefaults`

Sequence:

1. `MyOrderVM.fetchOrders()` loads orders.
2. VM calls `notificationsService.syncOrderStatusNotifications(userId,orders)`.
3. Service reads cached statuses from `UserDefaults`.
4. For each order, compares current normalized status against cached status.
5. If transition to delivered detected for first time, creates notification.
6. Cache updated and persisted.

This design prevents duplicate delivered notifications on repeated order refreshes.

### 27.6 Support Chat Stream Sequence

Actors:

- `MessageVC`
- `MessageVM`
- `ChatService`
- Realtime Database

Sequence:

1. Screen appears; VM `start()` called.
2. VM verifies authenticated user id.
3. VM starts async stream from `ChatService.messagesStream(userId)`.
4. Realtime DB child-added events produce message payloads.
5. VM deduplicates by id and sorts by timestamp.
6. VC renders updated message list.
7. On send: VM validates input/auth and calls `sendMessage(...)`.
8. DB write triggers stream event back to listeners.

Lifecycle guarantee:

- `stop()` cancels stream task and avoids leaks on dismissal.

---

## 28. Refactoring Blueprints (Pragmatic Evolution Paths)

This section proposes implementation-ready refactoring tracks aligned to current architecture.

### 28.1 Blueprint A: Feature Coordinators per Tab

Current issue:

- `MainTabCoordinator` handles all flows and route enums in one class.

Target shape:

- `HomeCoordinator`
- `BrowseCoordinator`
- `CartCoordinator`
- `WishlistCoordinator`
- `ProfileCoordinator`

Execution plan:

1. Introduce tab-level coordinator protocol and shared route forwarding adapter.
2. Move route enums and handlers per feature into each coordinator file.
3. Keep `MainTabCoordinator` as shell orchestrator for tab instantiation only.
4. Preserve shared VMs (`CartVM`, `WishlistVM`) as injected singleton-like instances.

Benefits:

- smaller files,
- clearer ownership,
- easier parallel feature development.

### 28.2 Blueprint B: Domain Use-Case Layer for Checkout

Current issue:

- checkout transaction is implemented directly in VM.

Target shape:

- `PlaceOrderUseCase`
- `PrepareCheckoutDefaultsUseCase`
- `CalculateOrderTotalsUseCase`

Execution plan:

1. Move validation and transaction steps from `CheckoutVM` into use-case class.
2. Inject service protocols into use-case.
3. Keep `CheckoutVM` as orchestration + published state holder.
4. Unit test use-case deterministically with mocked services.

Benefits:

- higher confidence for transactional flow,
- easier logic reuse if checkout variants are added,
- clearer separation between state and domain operations.

### 28.3 Blueprint C: Unified Error Envelope

Current issue:

- `errorMessage: String?` is simple but not structured.

Target shape:

- `AppError` with fields:
  - `code`
  - `userMessage`
  - `debugMessage`
  - `isRetryable`
  - `sourceLayer`

Execution plan:

1. Introduce `AppError` model and conversion helpers in service layer.
2. Keep UI fallback to string for minimal disruption.
3. Migrate VMs gradually from string errors to `AppError?`.
4. Add centralized error-to-alert renderer.

Benefits:

- consistent UX messages,
- better telemetry and issue triage,
- easier future localization.

### 28.4 Blueprint D: Test Harness with Mock AppServices

Current issue:

- architecture is injectable but tests are not yet formalized.

Target shape:

- test target with `MockAppServices`,
- reusable fake service implementations.

Execution plan:

1. Add `FinalProjectTests` target.
2. Create base test fixture injecting mock services into builders/VMs.
3. Add state-transition tests for top-risk VMs first.
4. Add route emission tests for key VCs/coordinators with spy callbacks.

Benefits:

- protects critical commerce flow,
- reduces regression risk during refactors.

### 28.5 Blueprint E: Observability Layer

Current issue:

- no dedicated app-level telemetry abstraction documented.

Target shape:

- `AnalyticsServiceProtocol`
- `PerformanceTraceServiceProtocol`
- event emission from VM intents and coordinator transitions.

Execution plan:

1. Add analytics protocol and no-op default implementation.
2. Inject into coordinators and selected VMs.
3. Emit events for login success/failure, add-to-cart, checkout steps, order success.
4. Add error event capture with safe redaction.

Benefits:

- data-driven UX iteration,
- production issue diagnosis,
- measurable funnel performance.

### 28.6 Blueprint F: Offline-Friendly Catalog Caching

Current issue:

- catalog/search flows depend on live fetch each time.

Target shape:

- local cache layer for products/categories,
- stale-while-revalidate read strategy.

Execution plan:

1. Add cache protocol and implementation (e.g., file/db-backed).
2. `CatalogService` first returns cache, then refreshes from network.
3. VM updates list twice: cached immediate + remote refresh.
4. Add explicit “last updated” metadata for diagnostics.

Benefits:

- faster perceived performance,
- improved reliability in intermittent network conditions.

---

## 29. Final Technical Summary

The current codebase demonstrates a practical, production-oriented UIKit architecture with clear layering and strong separation of concerns:

- coordinator-owned navigation,
- VM-owned feature state,
- protocolized services for Firebase interactions,
- reusable UI component base,
- increasingly consistent dependency injection.

The architecture is mature enough to scale feature breadth and has a direct upgrade path toward:

- stronger modularization,
- broader test automation,
- richer observability,
- stricter transaction and security hardening.

This document should now serve as the canonical, long-form technical reference for implementation behavior, architecture rationale, and maintainability planning.

