//
//  FavoritesViewModel.swift
//  enuygun-ios-case
//
//  Created by Ahmet Ozen on 15.01.2026.
//

import Foundation
import UIKit

final class FavoritesViewModel {

    // MARK: - Dependencies
    private let favoritesStore = FavoritesStore.shared
    private let cartStore = CartStore.shared

    // MARK: - Output
    var onUpdate: (() -> Void)?

    private(set) var items: [Product] = [] {
        didSet { onUpdate?() }
    }

    // MARK: - Init
    init() {
        load()
    }

    // MARK: - Public
    func load() {
        items = favoritesStore.all()
    }

    var isEmpty: Bool {
        items.isEmpty
    }

    func product(at index: Int) -> Product {
        items[index]
    }

    func remove(at index: Int) {
        let product = items[index]
        favoritesStore.remove(product)
        load()
    }

    func addToCart(at index: Int) {
        let product = items[index]
        cartStore.add(product)
    }

    // MARK: - Cell ViewData (MVVM clean)

    struct CellViewData {
        let title: String
        let priceText: String
        let oldPriceText: NSAttributedString?
        let discountBadgeText: String?
        let imageURL: String
    }

    func cellViewData(at index: Int) -> CellViewData {
        let p = items[index]
        let price = p.price

        if let discount = p.discountPercentage, discount > 0 {
            let discounted = price * (1 - discount / 100)

            let priceText = String(format: "$%.2f", discounted)
            let old = String(format: "$%.2f", price)

            let oldAttr = NSAttributedString(
                string: old,
                attributes: [.strikethroughStyle: NSUnderlineStyle.single.rawValue]
            )

            let badge = "%\(Int(discount))"

            return CellViewData(
                title: p.title,
                priceText: priceText,
                oldPriceText: oldAttr,
                discountBadgeText: badge,
                imageURL: p.thumbnail
            )
        } else {
            return CellViewData(
                title: p.title,
                priceText: String(format: "$%.2f", price),
                oldPriceText: nil,
                discountBadgeText: nil,
                imageURL: p.thumbnail
            )
        }
    }
}

