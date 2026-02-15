import Foundation

final class HelpCenterVM {
    let categories: [HelpCenterCategory]
    let orderStatus: HelpCenterCategory
    let trendingQuestions: [HelpCenterQuestion]

    init() {
        categories = [
            HelpCenterCategory(
                title: "Shipping",
                subtitle: "Tracking, delivery times & carriers",
                iconName: "truck.box",
                detailTitle: "Shipping Overview",
                detailBody: "Find delivery windows, carrier updates, and tracking tips for every order. You can also learn how to update delivery instructions and manage split shipments."
            ),
            HelpCenterCategory(
                title: "Returns",
                subtitle: "Refunds, labels & exchange policy",
                iconName: "arrow.uturn.left",
                detailTitle: "Returns & Refunds",
                detailBody: "Start a return in minutes, generate a prepaid label, and track the status of your refund. Exchanges are processed as a new shipment once the return is received."
            ),
            HelpCenterCategory(
                title: "Account",
                subtitle: "Password reset & privacy settings",
                iconName: "person.crop.circle",
                detailTitle: "Account Help",
                detailBody: "Manage your profile, reset your password, and update privacy preferences. You can also review connected devices and sign out remotely."
            ),
            HelpCenterCategory(
                title: "Payments",
                subtitle: "Billing history & payment methods",
                iconName: "creditcard",
                detailTitle: "Payments & Billing",
                detailBody: "Update payment methods, download receipts, and understand pending charges. If a payment fails, try a different card or confirm billing details."
            )
        ]

        orderStatus = HelpCenterCategory(
            title: "Order Status",
            subtitle: "Cancellations, modifications & status updates",
            iconName: "shippingbox",
            detailTitle: "Order Status",
            detailBody: "Check the real-time status of your order, request changes before it ships, and see estimated delivery updates in one place."
        )

        trendingQuestions = [
            HelpCenterQuestion(
                title: "How do I track my international order?",
                detailTitle: "Tracking International Orders",
                detailBody: "International tracking updates can take 24-48 hours to appear. Use the tracking page in your account and watch for customs scans once the package arrives in the destination country."
            ),
            HelpCenterQuestion(
                title: "Can I change my delivery address?",
                detailTitle: "Change Delivery Address",
                detailBody: "If your order is still processing, you can update the delivery address from the order details screen. Once shipped, address changes depend on the carrier and may be limited."
            ),
            HelpCenterQuestion(
                title: "What is your refund processing time?",
                detailTitle: "Refund Processing Time",
                detailBody: "Refunds are typically issued within 3-5 business days after the return is received. Your bank may take additional time to post the credit."
            )
        ]
    }
}
