# DashBoardFinalProject Architecture and State Flow Documentation

## 1. Project Purpose

`DashBoardFinalProject` is a SwiftUI admin dashboard for managing:

- Catalog data (categories and products)
- Order status updates
- Real-time chat with users

The app uses Firebase as the backend:

- Firestore for catalog, orders, and user profiles
- Realtime Database for chat streams and message sending

---

## 2. Tech Stack

- Language: Swift
- UI: SwiftUI
- State management: `ObservableObject` + `@Published` + SwiftUI property wrappers
- Concurrency: Swift Concurrency (`async/await`, `Task`)
- Backend SDKs:
  - `FirebaseCore`
  - `FirebaseFirestore`
  - `FirebaseDatabase`
- Testing: `XCTest`

---

## 3. Folder and Module Layout

```text
DashBoardFinalProject/
  App/
    DashBoardFinalProjectApp.swift
  Models/
    Category.swift
    Product.swift
    Variant.swift
    Review.swift
    Order.swift
    OrderStatus.swift
    ChatConversation.swift
    ChatMessage.swift
    UserProfile.swift
  Screens/
    Dashboard/
      Builder/
        DashboardBuilder.swift
      View/
        ContentView.swift
        DashboardTab.swift
      ViewModel/
        MessagesViewModel.swift
      Components/
        DashboardHeader.swift
        DashboardTabs.swift
        StatsGrid.swift
        StatCard.swift
        CatalogSection.swift
        CategoryCard.swift
        ProductCard.swift
        VariantSection.swift
        ReviewSection.swift
        PreviewRow.swift
        ReviewRow.swift
        OrdersSection.swift
        OrderRow.swift
        StatusPill.swift
        MessagesSection.swift
        SectionBox.swift
        StarRating.swift
    Catalog/
      ViewModel/
        CatalogViewModel.swift
      Components/
        CategoryBadge.swift
        CategorySelector.swift
      View/
        CategoryListView.swift
        ProductListView.swift
    Orders/
      ViewModel/
        OrdersViewModel.swift
      View/
        OrdersListView.swift
    Shared/
      Components/
        CardHeader.swift
        InputField.swift
        TextAreaField.swift
        PriceGrid.swift
        PrimaryButton.swift
        SuccessButton.swift
        SmallButton.swift
        ToastOverlay.swift
      State/
        ToastMessage.swift
  Services/
    ServiceContainer.swift
    CatalogRepository.swift
    OrdersRepository.swift
    ChatRepository.swift
    UserProfilesRepository.swift
    Firestore/
      FirestoreCatalogRepository.swift
      FirestoreOrdersRepository.swift
      FirestoreUserProfilesRepository.swift
    Realtime/
      RealtimeChatRepository.swift
  Theme/
    DashboardTheme.swift
    AppFont.swift
```

---

## 4. Architecture Overview

The architecture is layered and mostly follows:

- View (SwiftUI screens/components)
- ViewModel (`ObservableObject` state + use cases)
- Repository Protocols (abstractions)
- Repository Implementations (Firebase adapters)
- Backend (Firestore, RTDB)

### 4.1 Layer Diagram

```text
SwiftUI Views
  -> call ViewModel intents (methods)
  -> bind to @Published state

ViewModels (@MainActor)
  -> depend on repository protocols
  -> validate input
  -> perform async work
  -> publish updated UI state / toast state

Repository Protocols
  -> CatalogRepository
  -> OrdersRepository
  -> ChatRepository
  -> UserProfilesRepository

Repository Implementations
  -> FirestoreCatalogRepository
  -> FirestoreOrdersRepository
  -> FirestoreUserProfilesRepository
  -> RealtimeChatRepository

Firebase
  -> Firestore collections
  -> Realtime Database nodes
```

---

## 5. Composition Root and Dependency Injection

### 5.1 App Entry

`DashBoardFinalProject/App/DashBoardFinalProjectApp.swift`

- Configures Firebase in `AppDelegate.application(_:didFinishLaunchingWithOptions:)`
- Loads the app root with `DashboardBuilder.build()`

### 5.2 Builder

`DashBoardFinalProject/Screens/Dashboard/Builder/DashboardBuilder.swift`

- Pulls dependencies from `ServiceContainer.shared`
- Injects repositories into `ContentView` initializer

### 5.3 Service Container

`DashBoardFinalProject/Services/ServiceContainer.swift`

- Singleton composition object
- Wires protocol instances to concrete implementations:
  - `catalogRepository -> FirestoreCatalogRepository`
  - `ordersRepository -> FirestoreOrdersRepository`
  - `chatRepository -> RealtimeChatRepository`
  - `userProfilesRepository -> FirestoreUserProfilesRepository`

### 5.4 DI Characteristics

- Constructor injection at `ContentView` boundary
- Protocol-oriented view model dependencies
- Easy to mock repositories in tests
- Singleton container is simple but globally scoped

---

## 6. Domain Models

`DashBoardFinalProject/Models/*`

- `Category`: `id`, `title`, `slug`, `icon`
- `Product`: `id`, `title`, `description`, `categoryIds`, `basePrice`, `discountPrice`, `quantity`, `variants`, `reviews`
- `Variant`: name + value options
- `Review`: author, stars, optional message
- `Order`: order number, customer, total, status
- `OrderStatus`: `.onDelivery` / `.delivered`
- `ChatConversation`: user-level chat summary (`lastText`, `lastTime`)
- `ChatMessage`: message payload (`isFromAdmin`, timestamp)
- `UserProfile`: display name and email

Design note:

- Models are mostly plain value types with `Identifiable` and `Hashable`.
- Repository layer is responsible for mapping backend documents to these models.

---

## 7. State Management Strategy

### 7.1 Ownership Rules in This Project

- Root screen (`ContentView`) owns long-lived view models via `@StateObject`
- Child sections observe those view models via `@ObservedObject`
- Reusable inputs receive local write access via `@Binding`
- Short-lived local UI state uses `@State` (example: selected order status in `OrderRow`)

### 7.2 State Ownership Matrix

| State | Owner | Wrapper | Primary Mutators | Primary Readers |
| --- | --- | --- | --- | --- |
| `catalogViewModel` | `ContentView` | `@StateObject` | `ContentView` init | Catalog components |
| `ordersViewModel` | `ContentView` | `@StateObject` | `ContentView` init | Orders components |
| `messagesViewModel` | `ContentView` | `@StateObject` | `ContentView` init | Messages components |
| `activeTab` | `ContentView` | `@State` | `DashboardTabs` binding | Root tab switch |
| `toastQueue` / `activeToast` | `ContentView` | `@State` | `enqueueToast`, `presentNextToastIfNeeded` | `ToastOverlay` |
| Catalog form/list state | `CatalogViewModel` | `@Published` | Catalog VM methods | Catalog screen tree |
| Orders list + status pipeline | `OrdersViewModel` | `@Published` | `loadOrders`, `updateStatus` | Orders screen tree |
| Conversations/messages state | `MessagesViewModel` | `@Published` | listener callbacks + VM methods | Messages screen tree |
| `selectedStatus` row-local | `OrderRow` | `@State` | picker + sync from `order.status` | row only |

---

## 8. ViewModel Deep Dive

## 8.1 CatalogViewModel

File: `DashBoardFinalProject/Screens/Catalog/ViewModel/CatalogViewModel.swift`

### Responsibilities

- Load categories and products
- Manage category and product forms
- Manage in-memory variants and reviews before product save
- Validate user inputs
- Persist category/product through repository
- Emit toast feedback

### State Groups

- Data state:
  - `categories`, `products`, `productsCount`
- Selection state:
  - `selectedCategoryIds`
- Category form:
  - `categoryTitle`, `categorySlug`, `categoryIcon`
- Product form:
  - `productTitle`, `productDescription`, `productBasePrice`, `productDiscountPrice`, `productQuantity`
- Draft nested entities:
  - `variantName`, `variantValues`, `variants`
  - `reviewUser`, `reviewStars`, `reviewMessage`, `reviews`
- Feedback:
  - `toast`

### Behavior Notes

- `categoryTitle` auto-generates slug through `didSet`.
- On successful add actions, it reloads backend data and clears form state.
- Toast dismissal uses a cancellable task to avoid race conditions.

## 8.2 OrdersViewModel

File: `DashBoardFinalProject/Screens/Orders/ViewModel/OrdersViewModel.swift`

### Responsibilities

- Load orders from backend
- Update order status in backend
- Coordinate optimistic local status updates
- Serialize status writes per order id
- Emit toast feedback

### Concurrency and Flow

- `updateStatus(orderId:status:)`:
  - immediately applies local status (`setLocalStatus`)
  - stores latest desired state in `pendingStatusByOrderId`
  - starts processing task only if not already in-flight for that order
- `processPendingStatusUpdates(for:)`:
  - drains pending values
  - writes each to repository
  - refreshes orders
  - loops if a newer pending value appears during refresh

### Internal State

- `statusUpdatesInFlight`: active per-order processors
- `pendingStatusByOrderId`: latest desired status by order
- `toastDismissTask`: per-view-model toast timer cancellation

## 8.3 MessagesViewModel

File: `DashBoardFinalProject/Screens/Dashboard/ViewModel/MessagesViewModel.swift`

### Responsibilities

- Load user profiles
- Subscribe to conversations from RTDB
- Subscribe to message stream for selected user
- Send admin messages
- Maintain selected conversation and message draft
- Emit toast feedback

### Listener Lifecycle

- Holds:
  - `conversationsListener`
  - `messagesListener`
- Stops old listeners before replacing them.
- On invalid selected conversation:
  - stops current message listener
  - clears selected id and message list
- On deinit:
  - stops both listeners
  - cancels toast dismiss task

### UI Label Fallback Logic

`label(for:)` resolution order:

1. `displayName` if non-empty
2. `email` if non-empty
3. raw `userId`

---

## 9. Root Screen Architecture

File: `DashBoardFinalProject/Screens/Dashboard/View/ContentView.swift`

### Responsibilities

- Own all feature view models
- Route between tabs
- Host shared dashboard shell
- Aggregate toasts from all domains with queueing

### Tree Overview

```text
ContentView
  NavigationStack
    ZStack
      background
      ScrollView
        VStack
          DashboardHeader
          DashboardTabs(binding: activeTab)
          if .catalog -> StatsGrid + CatalogSection
          if .orders  -> OrdersSection
          if .messages -> MessagesSection
      ToastOverlay(activeToast)
```

### Toast Queue Orchestration

`ContentView` collects toast events via:

- `onChange(of: catalogViewModel.toast?.id)`
- `onChange(of: ordersViewModel.toast?.id)`
- `onChange(of: messagesViewModel.toast?.id)`

Then:

- appends toast into `toastQueue`
- if no active toast, shows next one
- dismisses after 2.5s with cancelable task
- shows queued next toast immediately after dismissal

---

## 10. Screen-Level Architecture

## 10.1 Catalog Tab

### Composition

`ContentView -> CatalogSection -> {CategoryCard, ProductCard}`

`CatalogSection` uses `ViewThatFits`:

- horizontal layout when space permits
- vertical stacking on constrained width

### CategoryCard

- Input bindings:
  - `categoryTitle`, `categorySlug`, `categoryIcon`
- Action:
  - `viewModel.addCategory()`

### ProductCard

- Input bindings:
  - title, description, base/discount price, quantity
- Category selection:
  - `CategorySelector` with `selectedCategoryIds`
- Nested sections:
  - `VariantSection`
  - `ReviewSection`
- Action:
  - `viewModel.addProduct()`

### VariantSection and ReviewSection

- Manage draft in-memory arrays within `CatalogViewModel`
- Add/remove in UI before final product save
- Validation handled in view model methods

## 10.2 Orders Tab

### Composition

`ContentView -> OrdersSection -> ForEach(OrderRow)`

### OrderRow

- Displays immutable order data from parent
- Keeps local picker state (`selectedStatus`)
- Syncs local state from incoming `order.status`
- Emits status changes upward only if value actually changed

### OrdersSection

- Delegates status changes to `OrdersViewModel.updateStatus(...)`
- No detached task in the view layer

## 10.3 Messages Tab

### Composition

`ContentView -> MessagesSection -> {conversationList, chatThread}`

### Responsive Layout

- Compact width: vertical stack
- Regular width: two-column layout

### Conversation List

- Binds to `viewModel.conversations`
- Highlights selected conversation
- User selection triggers `selectConversation(userId)`

### Chat Thread

- Shows selected user label from profile/user id fallback
- Binds input to `viewModel.messageText`
- Sends with button tap or text submit
- Disables input/send when no user selected

### ChatMessagesView

- Displays message bubbles based on `isFromAdmin`
- Scrolls to latest message on array change

---

## 11. Stats and Secondary Navigation

`StatsGrid` provides quick navigation:

- Categories -> `CategoryListView`
- Products -> `ProductListView`
- Orders -> `OrdersListView`

Additional note:

- Revenue card is currently static (`$0`) and not backed by state/repository data.

---

## 12. Repository Layer Details

## 12.1 Catalog Repository

Protocol: `CatalogRepository`

Implementation: `FirestoreCatalogRepository`

Capabilities:

- Fetch category and product collections
- Add category and product
- Save variants into product document map
- Save reviews into `products/{id}/reviews` subcollection

Current mapping limitation:

- `fetchProducts()` returns `variants: []` and `reviews: []`
- Reviews are written but not read back in current implementation

## 12.2 Orders Repository

Protocol: `OrdersRepository`

Implementation: `FirestoreOrdersRepository`

Capabilities:

- Fetch order list
- Update single order status field

Mapping behavior:

- Handles numeric/string conversion for `orderNumber` and totals
- Reads customer name from nested `shippingAddress.name`

## 12.3 Chat Repository

Protocol: `ChatRepository`

Implementation: `RealtimeChatRepository`

Capabilities:

- Observe conversation summaries under `messages` node
- Observe message list per `userId`
- Send admin message with server timestamp

Listener abstraction:

- `ChatListener` wrapper provides idempotent `stop()`

## 12.4 User Profiles Repository

Protocol: `UserProfilesRepository`

Implementation: `FirestoreUserProfilesRepository`

Capabilities:

- Fetch all user profiles from `users` collection
- Return dictionary keyed by user id

---

## 13. End-to-End State Flows

## 13.1 Add Category Flow

```text
CategoryCard button tap
  -> CatalogViewModel.addCategory()
      -> validate title/slug
      -> repository.addCategory(...)
      -> loadData()
      -> clearCategoryForm()
      -> toast(.success) or toast(.error)
  -> ContentView toast queue receives toast id change
  -> ToastOverlay displays message
```

## 13.2 Add Product Flow

```text
ProductCard save tap
  -> CatalogViewModel.addProduct()
      -> validate required fields + category selection
      -> compose Product with in-memory variants/reviews
      -> repository.addProduct(...)
      -> loadData()
      -> clearProductForm()
      -> toast feedback
```

## 13.3 Update Order Status Flow

```text
OrderRow picker change
  -> OrdersSection callback
  -> OrdersViewModel.updateStatus(orderId,status)
      -> optimistic local status update
      -> queue latest desired status
      -> per-order async processor writes queued status
      -> refresh list
      -> success/error toast
```

## 13.4 Messages Real-time Flow

```text
MessagesViewModel init
  -> start()
      -> loadProfiles()
      -> listenForConversations()
          -> on conversations change:
             - update list
             - auto select first if none selected
             - clear invalid selected conversation
             - attach message listener for selected user

Send action
  -> sendMessage()
      -> validate selected user + non-empty text
      -> repository.sendAdminMessage(...)
      -> clear input or show error toast
```

## 13.5 Toast Aggregation Flow

```text
Feature VM sets toast
  -> ContentView onChange detects new toast id
  -> enqueueToast()
  -> presentNextToastIfNeeded()
  -> active toast shown in ToastOverlay
  -> dismiss task clears active toast after 2.5s
  -> next queued toast shown
```

---

## 14. Concurrency and Threading Notes

- All three view models are `@MainActor`.
- Repository calls are async and invoked from main actor contexts.
- Listener callbacks from RTDB are bounced into `Task { @MainActor ... }`.
- Toast timers use cancellable `Task<Void, Never>` to avoid stale timers clearing newer toasts.
- Orders status updates use per-order processing gates to avoid parallel write races.

---

## 15. UI System and Shared Components

### Theme

`DashBoardFinalProject/Theme/DashboardTheme.swift`

- Centralized color tokens and gradients
- Shared `dashboardCard()` modifier for cards

### Typography

`DashBoardFinalProject/Theme/AppFont.swift`

- Unified `Font.app(size, weight)` helper
- Montserrat family for all weights

### Shared Controls

`Screens/Shared/Components/*`

- `CardHeader`: section heading shell
- `InputField`, `TextAreaField`, `PriceGrid`: form primitives
- `PrimaryButton`, `SuccessButton`, `SmallButton`: action controls
- `ToastOverlay`: bottom-right toast presentation

---

## 16. Testing Coverage

Current tests in `DashBoardFinalProjectTests/DashBoardFinalProjectTests.swift`:

- `testMessagesLabelFallsBackFromDisplayNameToEmailToUserId`
- `testCatalogToggleCategoryAddsThenRemovesCategoryId`

Coverage characteristics:

- Unit-level behavior tests with protocol mocks
- No direct tests yet for:
  - order status serialization behavior
  - toast queueing behavior in `ContentView`
  - message listener invalidation and lifecycle

---

## 17. Known Gaps and Technical Risks

1. Order status failure path edge case:
- In `OrdersViewModel`, if a write fails while a newer pending status was queued during in-flight processing, the pending value may remain until another status change triggers processing.

2. Order success toast after refresh:
- `loadOrders()` handles its own errors; after refresh call in processing loop, success toast can still be emitted even if reload failed.

3. Catalog product read model mismatch:
- Variants and reviews are persisted but not reconstructed in `fetchProducts()`.

4. Revenue stat is static:
- `StatsGrid` revenue is hard-coded to `$0`.

5. Limited automated test surface:
- Current tests are small and do not cover complex async/state transitions.

---

## 18. Suggested Improvement Backlog (Prioritized)

1. Fix orders failure-path queue drain and success-toast semantics.
2. Add dedicated `ToastCoordinator` object to reduce root view responsibilities.
3. Expand unit tests for:
   - order update serialization
   - toast queue sequencing
   - listener lifecycle behavior
4. Add repository read support for product variants/reviews.
5. Introduce feature-scoped state structs and action methods for more explicit intent modeling.
6. Add loading/error states per major section (catalog/orders/messages).

---

## 19. How to Extend This Architecture

To add a new feature tab:

1. Create models and repository protocol methods.
2. Add repository implementation in `Services/Firestore` or `Services/Realtime`.
3. Add dependency to `ServiceContainer`.
4. Create a `@MainActor` view model with `@Published` state and intent methods.
5. Inject it from `ContentView` (or a new builder boundary if refactoring).
6. Build screen components with `@ObservedObject` and `@Binding`.
7. Emit `ToastMessage` from view model for user feedback.
8. Add tests with protocol mocks.

---

## 20. Quick Reference: State Mutation Entry Points

### Catalog

- `loadData()`
- `addCategory()`
- `toggleCategory(id:)`
- `addVariant()`, `removeVariant(id:)`
- `addReview()`, `removeReview(id:)`
- `addProduct()`

### Orders

- `loadOrders()`
- `updateStatus(orderId:status:)`

### Messages

- `start()`
- `loadProfiles()`
- `listenForConversations()`
- `selectConversation(_:)`
- `listenForMessages(userId:)`
- `sendMessage()`

### Root Orchestrator

- `enqueueToast(_:)`
- `presentNextToastIfNeeded()`

---

## 21. Summary

The project uses a clean and understandable SwiftUI MVVM architecture with protocol-based repositories and Firebase-backed data sources. State ownership is mostly well-defined:

- long-lived feature state in `@StateObject` view models
- child observation through `@ObservedObject`
- direct control bindings via `@Binding`
- short-lived local UI state via `@State`

The latest structure includes stronger handling for toast timing and order update serialization, and provides a solid baseline for scaling with additional screens and data domains.
