//
//  CheckoutViewModel.swift
//  enuygun-ios-case
//
//  Created by Ahmet Ozen on 15.01.2026.
//

import Foundation

@MainActor
final class CheckoutViewModel {

    enum State {
        case idle
        case loading
    }

    enum DeliveryOption: Int, CaseIterable {
        case normal
        case express

        var title: String {
            switch self {
            case .normal: return "Normal"
            case .express: return "Express"
            }
        }

        var fee: Double {
            switch self {
            case .normal: return 0.0
            case .express: return 4.99
            }
        }

        var etaText: String {
            switch self {
            case .normal: return "3–5 business days"
            case .express: return "Tomorrow"
            }
        }
    }

    // MARK: - Dependencies
    private let cartStore: CartStoreProtocol

    init(cartStore: CartStoreProtocol = CartStore.shared) {
        self.cartStore = cartStore
    }

    private(set) var state: State = .idle {
        didSet { onUpdate?() }
    }

    private(set) var delivery: DeliveryOption = .normal {
        didSet { onUpdate?() }
    }

    var onUpdate: (() -> Void)?
    var onPaymentSuccess: (() -> Void)?
    var onPaymentFailure: ((_ message: String) -> Void)?

    // MARK: - Derived

    var isCartEmpty: Bool { cartStore.items.isEmpty }

    var subtotal: Double {
        cartStore.items.reduce(0.0) { result, item in
            let p = discountedPrice(for: item.product)
            return result + p * Double(item.quantity)
        }
    }

    var subtotalText: String { money(subtotal) }

    var deliveryFeeText: String {
        delivery.fee == 0 ? "Free" : money(delivery.fee)
    }

    var total: Double { subtotal + delivery.fee }
    var totalText: String { money(total) }

    var deliveryEtaText: String { delivery.etaText }

    // MARK: - UI inputs

    func setDelivery(_ option: DeliveryOption) {
        delivery = option
    }

    func amountTextBeforePay() -> String {
        totalText
    }

    // MARK: - Payment

    func pay(fullName: String?, cardNumber: String?, expiry: String?, cvv: String?, address: String?) {
        guard !isCartEmpty else {
            onPaymentFailure?("Your cart is empty.")
            return
        }

        let name = (fullName ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let card = (cardNumber ?? "").replacingOccurrences(of: " ", with: "")
        let exp  = (expiry ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let cvv  = (cvv ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let addr = (address ?? "").trimmingCharacters(in: .whitespacesAndNewlines)

        guard name.count >= 2 else { onPaymentFailure?("Please enter your full name."); return }
        guard card.count >= 12 else { onPaymentFailure?("Please enter a valid card number."); return }
        guard exp.count >= 4 else { onPaymentFailure?("Please enter expiry (MM/YY)."); return }
        guard cvv.count >= 3 else { onPaymentFailure?("Please enter CVV."); return }
        guard addr.count >= 5 else { onPaymentFailure?("Please enter your address."); return }

        state = .loading

        Task { [weak self] in
            guard let self else { return }
            try? await Task.sleep(nanoseconds: 900_000_000)

            self.cartStore.clear()
            self.state = .idle
            self.onPaymentSuccess?()
        }
    }

    // MARK: - Helpers

    private func discountedPrice(for product: Product) -> Double {
        guard let d = product.discountPercentage, d > 0 else { return product.price }
        return product.price * (1 - d / 100)
    }

    private func money(_ value: Double) -> String {
        String(format: "$%.2f", value)
    }
}
