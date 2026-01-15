//
//  CartStore.swift
//  enuygun-ios-case
//
//  Created by Ahmet Ozen on 15.01.2026.
//

import Foundation

struct CartItem {
    let product: Product
    var quantity: Int
}

final class CartStore {
    static let shared = CartStore()
    private init() {}

    private(set) var items: [CartItem] = []
    var onChange: (() -> Void)?

    func add(_ product: Product) {
        if let idx = items.firstIndex(where: { $0.product.id == product.id }) {
            items[idx].quantity += 1
        } else {
            items.insert(CartItem(product: product, quantity: 1), at: 0)
        }
        onChange?()
    }
}
