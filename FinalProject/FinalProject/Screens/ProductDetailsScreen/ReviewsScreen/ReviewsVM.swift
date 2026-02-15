import Combine
import Foundation

@MainActor
final class ReviewsVM: ObservableObject {
    @Published var reviews: [Review] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var selectedStars: Int = 0
    @Published var reviewText: String = ""
    
    private let product: Product
    private let reviewService: ReviewServiceProtocol
    private let authService: AuthenticationServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(
        product: Product,
        reviewService: ReviewServiceProtocol,
        authService: AuthenticationServiceProtocol
    ) {
        self.product = product
        self.reviewService = reviewService
        self.authService = authService
        fetchReviews()
    }
    
    func fetchReviews() {
        guard let productId = product.id else { return }
        
        isLoading = true
        cancellables.removeAll()

        reviewService.listenToReviews(productId: productId)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    guard let self = self else { return }

                    if case .failure(let error) = completion {
                        self.errorMessage = error.localizedDescription
                    }
                    self.isLoading = false
                },
                receiveValue: { [weak self] reviews in
                    self?.reviews = reviews
                    self?.isLoading = false
                }
            )
            .store(in: &cancellables)
    }
    
    func submitReview() async throws {
        guard let productId = product.id else {
            throw NSError(domain: "ReviewsVM", code: -1, userInfo: [NSLocalizedDescriptionKey: "Product ID not found"])
        }
         guard selectedStars > 0 else {
            throw NSError(domain: "ReviewsVM", code: -2, userInfo: [NSLocalizedDescriptionKey: "Please select a rating"])
        }
         guard !reviewText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw NSError(domain: "ReviewsVM", code: -3, userInfo: [NSLocalizedDescriptionKey: "Please write a review"])
        }
        guard let currentUser = authService.currentUser else {
            throw NSError(domain: "ReviewsVM", code: -4, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])
        }
        
        let userName = currentUser.displayName ?? "Anonymous"
        
        let review = Review(
            id: nil,
            userName: userName,
            stars: selectedStars,
            message: reviewText,
            createdAt: nil
        )

        try await reviewService.submitReview(productId: productId, review: review)
        
        selectedStars = 0
        reviewText = ""
    }
    
    func selectStars(_ count: Int) {
        selectedStars = count
    }
}
