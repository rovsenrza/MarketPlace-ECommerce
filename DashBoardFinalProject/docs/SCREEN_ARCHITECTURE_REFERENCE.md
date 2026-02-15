# Screen Architecture Reference

## 1. Purpose

This file is a practical reference for:

- Screen composition
- Component contracts (inputs/outputs)
- Event routing
- State read/write boundaries

Use this during feature additions and refactors to quickly understand where each mutation belongs.

---

## 2. Root Shell

File: `DashBoardFinalProject/Screens/Dashboard/View/ContentView.swift`

### Responsibilities

- Owns feature view models (`CatalogViewModel`, `OrdersViewModel`, `MessagesViewModel`)
- Owns shell UI state (`activeTab`)
- Routes tab content
- Aggregates all feature toasts into a queue

### Root Contract

| Concern | Owner | Notes |
| --- | --- | --- |
| Feature dependency injection | `ContentView` init | Receives repositories from builder |
| Feature state lifetime | `@StateObject` fields | One VM instance per app scene |
| Tab selection | `@State activeTab` | Driven by `DashboardTabs` binding |
| Toast presentation | `@State toastQueue/activeToast` | Serial display of toasts from all VMs |

---

## 3. Screen Composition Trees

## 3.1 Catalog Tab Tree

```text
ContentView (activeTab == .catalog)
  StatsGrid
    NavigationLink -> CategoryListView
    NavigationLink -> ProductListView
    NavigationLink -> OrdersListView
  CatalogSection
    CategoryCard
      InputField x3
      PrimaryButton
    ProductCard
      InputField
      TextAreaField
      CategorySelector
        CategoryBadge (ForEach)
      PriceGrid
        InputField x2
      VariantSection
        TextField x2
        SmallButton
        PreviewRow (ForEach)
      ReviewSection
        TextField x3
        SmallButton
        ReviewRow (ForEach)
          StarRating
      SuccessButton
```

## 3.2 Orders Tab Tree

```text
ContentView (activeTab == .orders)
  OrdersSection
    CardHeader
    ForEach(orders)
      OrderRow
        StatusPill
        Picker(OrderStatus)
```

## 3.3 Messages Tab Tree

```text
ContentView (activeTab == .messages)
  MessagesSection
    CardHeader
    conversationList
      ForEach(conversations) button rows
    chatThread
      selected user header + Refresh button
      ChatMessagesView
      input + Send button
```

---

## 4. Component Contracts

## 4.1 Dashboard Components

| Component | File | Inputs | Emits / Calls | Notes |
| --- | --- | --- | --- | --- |
| `DashboardHeader` | `DashboardHeader.swift` | none | none | Static header |
| `DashboardTabs` | `DashboardTabs.swift` | `@Binding activeTab` | mutates `activeTab` | Pure tab selector |
| `StatsGrid` | `StatsGrid.swift` | `categories`, `products`, `orders` | navigation only | No mutation |
| `CatalogSection` | `CatalogSection.swift` | `@ObservedObject CatalogViewModel` | none directly | Delegates to child cards |
| `OrdersSection` | `OrdersSection.swift` | `@ObservedObject OrdersViewModel` | `updateStatus` | No local async work |
| `MessagesSection` | `MessagesSection.swift` | `@ObservedObject MessagesViewModel` | `selectConversation`, `loadProfiles`, `sendMessage` | Includes private `ChatMessagesView` |

## 4.2 Catalog Components

| Component | File | Inputs | Emits / Calls | State Ownership |
| --- | --- | --- | --- | --- |
| `CategoryCard` | `CategoryCard.swift` | `CatalogViewModel` | `addCategory()` | Form state is VM-owned |
| `ProductCard` | `ProductCard.swift` | `CatalogViewModel` | `addProduct()` | Form state is VM-owned |
| `VariantSection` | `VariantSection.swift` | `CatalogViewModel` | `addVariant/removeVariant` | Draft variants in VM |
| `ReviewSection` | `ReviewSection.swift` | `CatalogViewModel` | `addReview/removeReview` | Draft reviews in VM |
| `CategorySelector` | `CategorySelector.swift` | categories + selected set + `onToggle` | `onToggle(id)` | Stateless renderer |
| `CategoryBadge` | `CategoryBadge.swift` | title + selected flag | none | Stateless renderer |
| `PreviewRow` | `PreviewRow.swift` | title + subtitle + remove closure | remove closure | Stateless renderer |
| `ReviewRow` | `ReviewRow.swift` | review + remove closure | remove closure | Stateless renderer |
| `StarRating` | `StarRating.swift` | integer stars | none | Stateless renderer |

## 4.3 Orders Components

| Component | File | Inputs | Emits / Calls | State Ownership |
| --- | --- | --- | --- | --- |
| `OrderRow` | `OrderRow.swift` | `order`, `onStatusChange` | `onStatusChange(newStatus)` | Local `@State selectedStatus` for picker |
| `StatusPill` | `StatusPill.swift` | `OrderStatus` | none | Stateless renderer |
| `OrdersListView` | `OrdersListView.swift` | `[Order]` | none | Read-only navigation destination |

## 4.4 Messages Components

| Component | File | Inputs | Emits / Calls | State Ownership |
| --- | --- | --- | --- | --- |
| `MessagesSection` | `MessagesSection.swift` | `MessagesViewModel` | message sends, conversation selection | VM-owned app state |
| `ChatMessagesView` (private) | `MessagesSection.swift` | `[ChatMessage]` | auto scroll side effect | Internal helper |

## 4.5 Shared Components

| Component | File | Inputs | Mutation Capability |
| --- | --- | --- | --- |
| `InputField` | `InputField.swift` | `@Binding text` and config | can mutate bound text |
| `TextAreaField` | `TextAreaField.swift` | `@Binding text` | can mutate bound text |
| `PriceGrid` | `PriceGrid.swift` | `@Binding basePrice`, `@Binding discountPrice` | can mutate bound text |
| `PrimaryButton` | `PrimaryButton.swift` | title, icon, action | calls provided action |
| `SuccessButton` | `SuccessButton.swift` | title, icon, action | calls provided action |
| `SmallButton` | `SmallButton.swift` | icon, color, action | calls provided action |
| `CardHeader` | `CardHeader.swift` | title/subtitle/icon/gradient | read-only |
| `ToastOverlay` | `ToastOverlay.swift` | optional `ToastMessage` | read-only |

---

## 5. Event Routing Map

## 5.1 Catalog Events

| UI Event | Route | VM Method | Repository Call | State Updates |
| --- | --- | --- | --- | --- |
| Category title typing | `InputField -> binding` | `categoryTitle didSet` | none | auto `categorySlug` |
| Add category tap | `PrimaryButton` | `addCategory()` | `addCategory`, then fetch lists | clear category form, toast |
| Category badge tap | `CategorySelector` | `toggleCategory(id:)` | none | mutate selected id set |
| Add variant tap | `SmallButton` | `addVariant()` | none | append to `variants` |
| Remove variant tap | `PreviewRow` | `removeVariant(id:)` | none | remove from `variants` |
| Add review tap | `SmallButton` | `addReview()` | none | append to `reviews` |
| Remove review tap | `ReviewRow` | `removeReview(id:)` | none | remove from `reviews` |
| Save product tap | `SuccessButton` | `addProduct()` | `addProduct`, then fetch lists | clear product form, toast |

## 5.2 Orders Events

| UI Event | Route | VM Method | Repository Call | State Updates |
| --- | --- | --- | --- | --- |
| Picker value changed | `OrderRow -> OrdersSection` | `updateStatus(orderId:status:)` | `updateOrderStatus` | optimistic local update + queued writes + reload + toast |

## 5.3 Messages Events

| UI Event / Lifecycle | Route | VM Method | Repository Call | State Updates |
| --- | --- | --- | --- | --- |
| VM init | `Task { await start() }` | `start()` | fetch profiles + subscribe conversations | initialize profiles and listeners |
| Conversation selected | button tap | `selectConversation(userId)` | subscribe message stream | update `selectedUserId`, swap listener |
| Send tapped/submitted | button/onSubmit | `sendMessage()` | `sendAdminMessage` | clear `messageText` on success |
| Refresh tapped | button tap | `loadProfiles()` | fetch profiles | update profile map |
| Conversation removed upstream | listener callback | in `listenForConversations()` | none | stop message listener, clear selection/messages |

---

## 6. State Read/Write Boundaries

## 6.1 Root Boundaries

- `ContentView` writes:
  - `activeTab`
  - toast queue state
- `ContentView` reads:
  - all VM published properties used for rendering

## 6.2 VM Boundaries

- `CatalogViewModel` is the only writer of:
  - catalog data arrays
  - catalog form draft state
  - catalog toast
- `OrdersViewModel` is the only writer of:
  - orders list
  - orders toast
  - internal status update scheduler state
- `MessagesViewModel` is the only writer of:
  - conversations/messages/profiles
  - selected user and message text
  - messages toast
  - listener handles

## 6.3 Child View Boundaries

- Child sections do not own feature data; they render VM state and forward intents.
- Only local exception: `OrderRow.selectedStatus` as local picker cache synchronized with model updates.

---

## 7. Data Dependency Matrix

## 7.1 Catalog Tab Dependencies

| UI Block | Reads | Writes |
| --- | --- | --- |
| `StatsGrid` | `categories`, `products`, `orders` | none |
| `CategoryCard` | category form fields | same fields through bindings + `addCategory` |
| `ProductCard` | product form fields, selected categories, variants, reviews, categories list | same fields through bindings + feature methods |

## 7.2 Orders Tab Dependencies

| UI Block | Reads | Writes |
| --- | --- | --- |
| `OrdersSection` | `orders` | `updateStatus` intent |
| `OrderRow` | `order` | local `selectedStatus`, emits status callback |

## 7.3 Messages Tab Dependencies

| UI Block | Reads | Writes |
| --- | --- | --- |
| Conversation list | `conversations`, `selectedUserId`, profile labels | `selectConversation` |
| Thread header | `selectedUserId` + profile labels | `loadProfiles` |
| Message list | `messages` | none |
| Input/send controls | `messageText`, `selectedUserId` | `messageText` binding + `sendMessage` |

---

## 8. Navigation Contract

Static navigation happens only through:

- `NavigationLink` items in `StatsGrid`

Destinations:

- `CategoryListView`
- `ProductListView`
- `OrdersListView`

No deep-link router exists in this codebase yet. Tab navigation is in-memory state-based (`activeTab`).

---

## 9. Screen-Specific Validation Rules

## 9.1 Catalog Validation

- Category add:
  - title and slug must be non-empty
- Variant add:
  - variant name non-empty
  - at least one parsed value
- Review add:
  - username non-empty
  - stars integer in `1...5`
- Product add:
  - title non-empty
  - base price parse succeeds and is non-negative
  - quantity parse succeeds and is non-negative
  - at least one category selected

## 9.2 Messages Validation

- Message send:
  - trimmed text must be non-empty
  - `selectedUserId` must exist

## 9.3 Orders Validation

- Picker limits status to `OrderStatus.allCases`; no additional client validation needed.

---

## 10. Error and Feedback Surface

All feature errors are currently surfaced through toasts:

- Catalog errors -> `catalogViewModel.toast`
- Orders errors -> `ordersViewModel.toast`
- Messages errors -> `messagesViewModel.toast`

Root queue:

- Ensures no toast is dropped when multiple domains emit close in time.

No inline field-level validation messages are currently used; validation feedback is primarily toast-based.

---

## 11. Quick Refactor Safety Rules

1. Keep feature mutations inside the owning view model.
2. Do not move async backend calls into SwiftUI views.
3. Preserve `@StateObject` ownership at root for feature VMs.
4. Keep `OrderRow` local picker guard (`newValue != order.status`) to avoid redundant writes.
5. Preserve listener cleanup in `MessagesViewModel` when conversation becomes invalid.
6. If replacing toast behavior, maintain queue semantics from `ContentView`.

---

## 12. Add-New-Component Checklist

Before adding a component:

1. Decide whether it is read-only, binding-driven, or intent-driven.
2. Document:
   - input props
   - closures/callbacks
   - state owner
3. Ensure mutation path lands in a view model method.
4. Reuse `DashboardTheme` and `Font.app` for consistency.
5. Add tests if new state transitions are introduced.
