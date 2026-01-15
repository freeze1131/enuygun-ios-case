//
//  CartViewModel.swift
//  enuygun-ios-case
//
//  Created by Ahmet Ozen on 15.01.2026.
//

import Foundation
import UIKit

final class CartViewModel {

    // MARK: - Dependencies
    private let cartStore = CartStore.shared

    // MARK: - State
    private(set) var items: [CartItem] = [] {
        didSet { onUpdate?() }
    }

    var onUpdate: (() -> Void)?

    // MARK: - Init
    init() {
        load()
    }

    // MARK: - Public API

    func load() {
        items = cartStore.items
    }

    var isEmpty: Bool {
        items.isEmpty
    }

    var subtotalText: String {
        let subtotal = items.reduce(0.0) { result, item in
            let price = discountedPrice(for: item.product)
            return result + price * Double(item.quantity)
        }
        return String(format: "$%.2f", subtotal)
    }

    func increaseQuantity(at index: Int) {
        guard index < items.count else { return }
        cartStore.increase(productId: items[index].product.id)
        load()
    }

    func decreaseQuantity(at index: Int) {
        guard index < items.count else { return }

        let item = items[index]
        if item.quantity <= 1 {
            // confirmation gerekecek
            return
        }

        cartStore.decrease(productId: item.product.id)
        load()
    }

    func shouldConfirmRemove(at index: Int) -> Bool {
        guard index < items.count else { return false }
        return items[index].quantity <= 1
    }

    func removeItem(at index: Int) {
        guard index < items.count else { return }
        cartStore.remove(productId: items[index].product.id)
        load()
    }
    
    func cellViewData(at index: Int) -> CartItemCellViewData {
        let item = items[index]
        let product = item.product

        let quantityText = "\(item.quantity)"

        let price = product.price
        let discount = product.discountPercentage ?? 0

        if discount > 0 {
            let discounted = price * (1 - discount / 100)

            let priceText = String(format: "$%.2f", discounted)
            let old = String(format: "$%.2f", price)
            let oldPrice = NSAttributedString(
                string: old,
                attributes: [.strikethroughStyle: NSUnderlineStyle.single.rawValue]
            )
            let discountText = "  %\(Int(discount)) OFF  "

            return CartItemCellViewData(
                title: product.title,
                quantityText: quantityText,
                priceText: priceText,
                oldPriceText: oldPrice,
                discountText: discountText,
                isDiscountHidden: false,
                imageURL: product.thumbnail
            )
        } else {
            let priceText = String(format: "$%.2f", price)

            return CartItemCellViewData(
                title: product.title,
                quantityText: quantityText,
                priceText: priceText,
                oldPriceText: nil,
                discountText: nil,
                isDiscountHidden: true,
                imageURL: product.thumbnail
            )
        }
    }


    // MARK: - Helpers

    func displayPrice(for index: Int) -> String {
        let item = items[index]
        let price = discountedPrice(for: item.product)
        return String(format: "$%.2f", price)
    }

    func oldPriceText(for index: Int) -> NSAttributedString? {
        let product = items[index].product
        guard let discount = product.discountPercentage, discount > 0 else {
            return nil
        }

        let text = String(format: "$%.2f", product.price)
        return NSAttributedString(
            string: text,
            attributes: [.strikethroughStyle: NSUnderlineStyle.single.rawValue]
        )
    }

    func discountText(for index: Int) -> String? {
        guard let discount = items[index].product.discountPercentage else {
            return nil
        }
        return "%\(Int(discount)) OFF"
    }

    private func discountedPrice(for product: Product) -> Double {
        guard let discount = product.discountPercentage, discount > 0 else {
            return product.price
        }
        return product.price * (1 - discount / 100)
    }
}
