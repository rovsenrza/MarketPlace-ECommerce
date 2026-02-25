# MarketPlace-ECommerce

## Layihə Haqqında
Bu repository Firebase backend-i üzərində qurulmuş e-commerce monorepo-sudur və 3 əsas deliverable ehtiva edir:

1. `FinalProject` - müştəri tərəf iOS tətbiqi (UIKit)
2. `DashBoardFinalProject` - admin panel iOS tətbiqi (SwiftUI)
3. `WebsiteDashBoardFinalProject` - web admin prototipi (tək `dashboard.html`)

Texnoloji kontur:

- iOS: `UIKit`, `SwiftUI`, `Combine`, `SnapKit`, `Swift Concurrency`
- Backend: `Firebase Auth`, `Firestore`, `Realtime Database`, `Storage`
- Web prototip: `HTML/CSS/JavaScript` + Firebase Web SDK

Hazırkı kod baza ölçüsü:

- Ümumi Swift fayl sayı: `221`
- `FinalProject`: `162` Swift fayl
- `DashBoardFinalProject`: `59` Swift fayl (test daxil)

## Repository Strukturu
| Yol | Layihə tipi | Platforma/Stack | Məqsəd |
| --- | --- | --- | --- |
| `FinalProject/` | Customer App | iOS, UIKit, Coordinator + MVVM + Builder, Firebase | Son istifadəçi alış-veriş axını |
| `DashBoardFinalProject/` | Admin App | iOS, SwiftUI, ViewModel + Repository, Firebase | Kataloq/sifariş/chat idarəsi |
| `WebsiteDashBoardFinalProject/` | Web Prototype | Web, Vanilla JS + Firebase Web SDK | Brauzerdən admin əməliyyatları üçün prototip |

Aktiv web faylı:

- `WebsiteDashBoardFinalProject/dashboard.html`

## Layihə 1: FinalProject (Customer iOS)
### Arxitektura
`FinalProject` modul arxitektura ilə qurulub:

- `Coordinator + MVVM + Builder + ServiceContainer`
- `AppDelegate` Firebase konfiqurasiyasını edir
- `SceneDelegate` `AppCoordinator` vasitəsilə app flow-u başladır
- `AppCoordinator` istifadəçini auth və ya əsas tab flow-a yönləndirir
- `MainTabCoordinator` route enum-ları ilə bütün əsas naviqasiyanı idarə edir

### Əsas modullar

- Auth: login/register, Google Sign-In, Apple Sign-In
- Home/Browse/Search/Filter
- Product Details + reviews + variant seçimi
- Cart + Checkout + Payment + Shipping
- Orders: history/detail/success
- Notifications
- Profile + Settings
- Help Center + real-time support chat

### Data qatı (service-protocol xəritəsi)

- `AuthenticationServiceProtocol` -> `FirebaseAuthService`
- `FirestoreServiceProtocol` -> `FirestoreService`
- `UserServiceProtocol` -> `UserService`
- `CatalogServiceProtocol` -> `CatalogService`
- `CartServiceProtocol` -> `CartService`
- `WishlistServiceProtocol` -> `WishlistService`
- `OrdersServiceProtocol` -> `OrdersService`
- `PaymentsServiceProtocol` -> `PaymentsService`
- `ShippingAddressServiceProtocol` -> `ShippingAddressService`
- `NotificationsServiceProtocol` -> `NotificationsService`
- `ReviewServiceProtocol` -> `ReviewService`
- `ChatServiceProtocol` -> `ChatService`
- `FilterServiceProtocol` -> `FilterService`

### İstifadə olunan əsas framework-lər

- `UIKit`
- `Combine`
- `SnapKit`
- `FirebaseCore`, `FirebaseAuth`, `FirebaseFirestore`, `FirebaseStorage`, `FirebaseDatabase`
- `GoogleSignIn`
- `Kingfisher`

### Texniki qeydlər

- Xcode target deployment: `iOS 16.6`
- Bundle identifier: `com.rovsenrza.FinalProject`

## Layihə 2: DashBoardFinalProject (Admin iOS)
### Arxitektura
Admin tətbiqi SwiftUI əsaslıdır:

- `SwiftUI + ObservableObject + @Published`
- `ViewModel + Repository` layering
- `DashboardBuilder` composition root rolunu oynayır
- `ServiceContainer` repository implementasiyalarını inject edir

App bootstrap:

- `@UIApplicationDelegateAdaptor` ilə `AppDelegate`
- `FirebaseApp.configure()` app başlanğıcında çağırılır

### Əsas funksiyalar

- Kategoriya əlavə etmə
- Məhsul əlavə etmə (variant və review daxil)
- Sifarişlərin statusunu dəyişmə (`on_delivery` / `delivered`)
- Realtime admin chat (istifadəçi söhbətləri üzərindən cavablama)

### State ownership (qısa)

- `ContentView`:
  - `@StateObject` ilə `CatalogViewModel`, `OrdersViewModel`, `MessagesViewModel`
  - tab state və toast queue idarəsi
- Child komponentlər:
  - `@ObservedObject` və `@Binding` ilə VM state-i render edir

### Repository implementasiyaları

- Firestore:
  - `FirestoreCatalogRepository`
  - `FirestoreOrdersRepository`
  - `FirestoreUserProfilesRepository`
- Realtime Database:
  - `RealtimeChatRepository`

### Test mövcudluğu

- Test target var: `DashBoardFinalProjectTests`
- Mövcud testlər əsasən ViewModel davranışını yoxlayır (məs., label fallback və category toggle)

### Texniki qeydlər

- Bundle identifier: `com.rovsenrza.DashBoardFinalProject`
- Layihə faylında deployment target `26.2` kimi görünür; real cihaz/simulator uyğunluğu üçün bu dəyər ayrıca yoxlanmalıdır.

## Layihə 3: WebsiteDashBoardFinalProject (Web Admin Prototip)
### Struktur

- Tək fayl: `WebsiteDashBoardFinalProject/dashboard.html`
- UI, stil və biznes məntiqi eyni faylda saxlanılır
- Firebase konfiqurasiyası və CRUD əməliyyatları script daxilindədir

### Capability-lər

- Category və product yaratma
- Product variants və reviews daxil etmə
- Orders siyahısı və status update
- Realtime chat və admin mesaj göndərmə
- Statistik kartlar və list overlay-ləri

### Məhdudiyyətlər

- Production-ready arxitektura deyil
- Build sistemi, modul parçalanması və formal test pipeline yoxdur
- Daha çox demo/prototip məqsədinə uyğundur

## Firebase Data Kontraktı
Bu repo daxilində tətbiqlər eyni data modelinə yaxın kontraktla işləyir.

Firestore kolleksiyaları:

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

Realtime Database:

- `messages/{uid}`

Uyğunluq qeydi:

- iOS customer app, iOS admin app və web prototip bu path-lərin üzərində sinxron işləmək üçün eyni sahə adlarına güvənir.

## Quraşdırma və Lokal İşə Salma
### Tələblər

- macOS
- Xcode
- Swift Package Manager üçün internet bağlantısı
- Firebase layihəsi (Auth + Firestore + Storage + Realtime Database)

### FinalProject-i işə salmaq

1. `FinalProject/FinalProject.xcodeproj` faylını açın.
2. Scheme olaraq `FinalProject` seçin.
3. Build və Run edin.

### DashBoardFinalProject-i işə salmaq

1. `DashBoardFinalProject/DashBoardFinalProject.xcodeproj` faylını açın.
2. Scheme olaraq `DashBoardFinalProject` seçin.
3. Build və Run edin.

### Web prototipi işə salmaq

1. Repo kökündə lokal HTTP server başladın (ES modules üçün vacibdir):
   - `python3 -m http.server 8080`
2. Brauzerdə açın:
   - `http://localhost:8080/WebsiteDashBoardFinalProject/dashboard.html`

## Təhlükəsiz Firebase Setup Checklist
Bu README-də həssas dəyərlər paylaşılmır. Real layihə üçün yalnız aşağıdakı yoxlamaları edin:

1. iOS config fayllarını öz Firebase layihənizlə əvəz edin:
   - `FinalProject/FinalProject/GoogleService-Info.plist`
   - `DashBoardFinalProject/DashBoardFinalProject/GoogleService-Info.plist`
2. `FinalProject/FinalProject/Info.plist` daxilində Google Sign-In URL scheme (`CFBundleURLTypes`) dəyərini öz layihənizə uyğunlaşdırın.
3. Firestore və Realtime Database qaydalarının tələb olunan read/write əməliyyatlarına icazə verdiyini yoxlayın.
4. Realtime DB URL istifadə olunan faylları yoxlayın:
   - `FinalProject/FinalProject/Services/ChatService.swift`
   - `DashBoardFinalProject/DashBoardFinalProject/Services/Realtime/RealtimeChatRepository.swift`
5. Web prototipdə Firebase konfiqurasiyası üçün yalnız öz layihənizin dəyərlərindən istifadə edin; gizli dəyərləri public repoya yazmayın.

## Test və Keyfiyyət Statusu
Mövcud vəziyyət:

- `DashBoardFinalProject` üçün XCTest target mövcuddur.
- `FinalProject` üçün ayrıca test target görünmür.

Known gaps və risklər:

- Customer app üçün avtomatlaşdırılmış test coverage artırılmalıdır.
- Admin app deployment target dəyəri praktik iOS target strategiyası ilə yenidən yoxlanmalıdır.
- Web prototip monolit fayl olduğuna görə maintainability riski daşıyır.
- Shared backend kontraktında schema dəyişiklikləri bütün client-lərdə paralel yenilənməlidir.

## Public API/Interface/Type Dəyişiklikləri

- Kod səviyyəsində API/interface/type dəyişikliyi yoxdur.
- Yalnız sənədləşmə yenilənib: kök `README.md` tam strukturlaşdırılıb.
- README onboarding və texniki audit üçün vahid istinad sənədi kimi standartlaşdırılıb.

## Sənədlər Xəritəsi

- `FinalProject/README.md`
- `FinalProject/docs/FinalProject_Architecture_Workflow_Documentation.md`
- `DashBoardFinalProject/docs/README.md`
- `DashBoardFinalProject/docs/ARCHITECTURE_AND_STATE_FLOW.md`
- `DashBoardFinalProject/docs/SCREEN_ARCHITECTURE_REFERENCE.md`
