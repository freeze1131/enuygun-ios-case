//
//  ProductDetailViewModel.swift
//  enuygun-ios-case
//
//  Created by Ahmet Ozen on 15.01.2026.
//

import Foundation
import UIKit

final class ProductDetailViewModel {

    // MARK: - Dependencies
    private let favoritesStore: FavoritesStoreProtocol
    private let cartStore: CartStoreProtocol

    // MARK: - State
    let product: Product

    // UI update callback
    var onUpdate: (() -> Void)?

    // MARK: - Init
    init(
        product: Product,
        favoritesStore: FavoritesStoreProtocol = FavoritesStore.shared,
        cartStore: CartStoreProtocol = CartStore.shared
    ) {
        self.product = product
        self.favoritesStore = favoritesStore
        self.cartStore = cartStore
    }

    // MARK: - Derived UI Data

    var titleText: String { product.title }
    var descriptionText: String { product.description }

    var galleryImages: [String] {
        !product.images.isEmpty ? product.images : [product.thumbnail]
    }

    var ratingText: String {
        "★ \(String(format: "%.2f", Double(product.rating)))"
    }

    var categoryTag: String { product.category.capitalized }

    var brandTag: String? {
        guard let brand = product.brand, !brand.isEmpty else { return nil }
        return brand
    }

    // MARK: - Pricing

    var displayPriceText: String {
        let price = discountedPrice ?? product.price
        return String(format: "$%.2f", Double(price))
    }

    var oldPriceText: NSAttributedString? {
        guard let discount = product.discountPercentage, discount > 0 else { return nil }
        let text = String(format: "$%.2f", Double(product.price))
        return NSAttributedString(
            string: text,
            attributes: [.strikethroughStyle: NSUnderlineStyle.single.rawValue]
        )
    }

    var discountText: String? {
        guard let discount = product.discountPercentage, discount > 0 else { return nil }
        return "%\(Int(discount)) OFF"
    }

    private var discountedPrice: Double? {
        guard let discount = product.discountPercentage, discount > 0 else { return nil }
        return product.price * (1 - discount / 100)
    }

    // MARK: - Favorite

    var isFavorite: Bool {
        favoritesStore.isFavorite(product)
    }

    func toggleFavorite() {
        favoritesStore.toggle(product)
        onUpdate?()
    }

    // MARK: - Cart

    func addToCart() {
        cartStore.add(product)
    }

    // MARK: - Meta

    var metaText: String {
        let category = product.category.capitalized
        let brand = brandTag ?? "-"
        return "Category: \(category)\nBrand: \(brand)"
    }
}
