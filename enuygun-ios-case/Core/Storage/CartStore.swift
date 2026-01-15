//
//  CartStore.swift
//  enuygun-ios-case
//
//  Created by Ahmet Ozen on 15.01.2026.
//

import Foundation

final class CartStore {
    static let shared = CartStore()

    private(set) var items: [CartItem] = [] {
        didSet {
            save()
            onChange?()
        }
    }
    
    var totalItemsCount: Int {
        items.reduce(0) { $0 + $1.quantity }
    }


    var onChange: (() -> Void)?

    private let storageKey = "cart_items_v1"

    private init() {
        load()
    }

    // MARK: - Public API

    func add(_ product: Product) {
        if let idx = items.firstIndex(where: { $0.product.id == product.id }) {
            items[idx].quantity += 1
        } else {
            items.append(CartItem(product: product, quantity: 1))
        }
    }

    func remove(productId: Int) {
        items.removeAll { $0.product.id == productId }
    }

    func setQuantity(productId: Int, quantity: Int) {
        guard let idx = items.firstIndex(where: { $0.product.id == productId }) else { return }
        items[idx].quantity = max(1, quantity)
    }

    func increase(productId: Int) {
        guard let idx = items.firstIndex(where: { $0.product.id == productId }) else { return }
        items[idx].quantity += 1
    }

    func decrease(productId: Int) {
        guard let idx = items.firstIndex(where: { $0.product.id == productId }) else { return }
        let newQty = items[idx].quantity - 1
        if newQty <= 0 {
            remove(productId: productId)
        } else {
            items[idx].quantity = newQty
        }
    }

    func clear() {
        items = []
    }

    var subtotal: Double {
        items.reduce(0) { $0 + $1.lineTotal }
    }

    var count: Int {
        items.reduce(0) { $0 + $1.quantity }
    }

    // MARK: - Persistence

    private func save() {
        do {
            let data = try JSONEncoder().encode(items)
            UserDefaults.standard.set(data, forKey: storageKey)
        } catch {
            print("CartStore save error: \(error)")
        }
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else { return }
        do {
            items = try JSONDecoder().decode([CartItem].self, from: data)
        } catch {
            print("CartStore load error: \(error)")
            items = []
        }
    }
}

