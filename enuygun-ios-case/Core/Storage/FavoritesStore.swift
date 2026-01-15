//
//  FavoritesStore.swift
//  enuygun-ios-case
//
//  Created by Ahmet Ozen on 15.01.2026.
//
import Foundation

final class FavoritesStore {
    static let shared = FavoritesStore()

    private let storageKey = "favorite_products_v1"

    private(set) var favorites: [Product] = []
    var onChange: (() -> Void)?

    private init() {
        load()
    }

    func isFavorite(_ product: Product) -> Bool {
        favorites.contains(where: { $0.id == product.id })
    }

    func toggle(_ product: Product) {
        if isFavorite(product) {
            favorites.removeAll { $0.id == product.id }
        } else {
            favorites.insert(product, at: 0)
        }
        save()
        onChange?()
    }

    // MARK: - Persistence
    private func save() {
        do {
            let data = try JSONEncoder().encode(favorites)
            UserDefaults.standard.set(data, forKey: storageKey)
        } catch {
            print("FavoritesStore save error:", error)
        }
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else { return }
        do {
            favorites = try JSONDecoder().decode([Product].self, from: data)
        } catch {
            print("FavoritesStore load error:", error)
            favorites = []
        }
    }
}
