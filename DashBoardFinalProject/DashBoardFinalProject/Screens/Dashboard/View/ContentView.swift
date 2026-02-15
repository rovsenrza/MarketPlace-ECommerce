import SwiftUI

struct ContentView: View {
    @StateObject private var catalogViewModel: CatalogViewModel
    @StateObject private var ordersViewModel: OrdersViewModel
    @StateObject private var messagesViewModel: MessagesViewModel
    @State private var activeTab: DashboardTab = .catalog
    @State private var toastQueue: [ToastMessage] = []
    @State private var activeToast: ToastMessage?
    @State private var toastDismissTask: Task<Void, Never>?

    init(
        catalogRepository: CatalogRepository,
        ordersRepository: OrdersRepository,
        chatRepository: ChatRepository,
        userProfilesRepository: UserProfilesRepository
    ) {
        _catalogViewModel = StateObject(wrappedValue: CatalogViewModel(repository: catalogRepository))
        _ordersViewModel = StateObject(wrappedValue: OrdersViewModel(repository: ordersRepository))
        _messagesViewModel = StateObject(
            wrappedValue: MessagesViewModel(
                chatRepository: chatRepository,
                userProfilesRepository: userProfilesRepository
            )
        )
    }

    var body: some View {
        NavigationStack {
            ZStack {
                DashboardTheme.background
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        DashboardHeader()

                        DashboardTabs(activeTab: $activeTab)

                        if activeTab == .catalog {
                            StatsGrid(
                                categories: catalogViewModel.categories,
                                products: catalogViewModel.products,
                                orders: ordersViewModel.orders
                            )

                            CatalogSection(viewModel: catalogViewModel)
                        } else if activeTab == .orders {
                            OrdersSection(viewModel: ordersViewModel)
                        } else {
                            MessagesSection(viewModel: messagesViewModel)
                        }
                    }
                    .padding(24)
                    .frame(maxWidth: 1200)
                    .frame(maxWidth: .infinity)
                }

                ToastOverlay(message: activeToast)
            }
            .navigationBarTitleDisplayMode(.inline)
        }
        .onChange(of: catalogViewModel.toast?.id) { _ in
            enqueueToast(catalogViewModel.toast)
        }
        .onChange(of: ordersViewModel.toast?.id) { _ in
            enqueueToast(ordersViewModel.toast)
        }
        .onChange(of: messagesViewModel.toast?.id) { _ in
            enqueueToast(messagesViewModel.toast)
        }
        .onDisappear {
            toastDismissTask?.cancel()
            toastDismissTask = nil
            toastQueue.removeAll()
            activeToast = nil
        }
    }

    private func enqueueToast(_ message: ToastMessage?) {
        guard let message else { return }
        toastQueue.append(message)
        presentNextToastIfNeeded()
    }

    private func presentNextToastIfNeeded() {
        guard activeToast == nil, !toastQueue.isEmpty else { return }
        let nextToast = toastQueue.removeFirst()
        activeToast = nextToast

        toastDismissTask?.cancel()
        toastDismissTask = Task { @MainActor in
            do {
                try await Task.sleep(nanoseconds: 2_500_000_000)
            } catch {
                return
            }

            guard activeToast?.id == nextToast.id else { return }
            activeToast = nil
            presentNextToastIfNeeded()
        }
    }
}

#Preview {
    DashboardBuilder.build()
}
