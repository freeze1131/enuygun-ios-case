//
//  FavoritesStore.swift
//  enuygun-ios-case
//
//  Created by Ahmet Ozen on 15.01.2026.
//
import Foundation


protocol FavoritesStoreProtocol: AnyObject {
    func isFavorite(_ product: Product) -> Bool
    func toggle(_ product: Product)

    func all() -> [Product]
    func remove(_ product: Product)
}


final class FavoritesStore: FavoritesStoreProtocol {
    static let shared = FavoritesStore()

    private let storageKey = "favorite_products_v1"

    private(set) var favorites: [Product] = []
    var onChange: (() -> Void)?

    private init() {
        load()
    }

    // MARK: - Queries
    func isFavorite(_ product: Product) -> Bool {
        favorites.contains(where: { $0.id == product.id })
    }

    func all() -> [Product] {
        favorites
    }

    // MARK: - Mutations
    func toggle(_ product: Product) {
        if isFavorite(product) {
            favorites.removeAll { $0.id == product.id }
        } else {
            favorites.insert(product, at: 0)
        }
        persistAndNotify()
    }

    func add(_ product: Product) {
        guard !isFavorite(product) else { return }
        favorites.insert(product, at: 0)
        persistAndNotify()
    }

    func remove(_ product: Product) {
        favorites.removeAll { $0.id == product.id }
        persistAndNotify()
    }

    func remove(productId: Int) {
        favorites.removeAll { $0.id == productId }
        persistAndNotify()
    }

    func clear() {
        favorites.removeAll()
        persistAndNotify()
    }

    // MARK: - Persistence
    private func persistAndNotify() {
        save()
        onChange?()
    }

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
