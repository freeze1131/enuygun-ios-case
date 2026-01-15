//
//  FavoritesViewModelTests.swift
//  enuygun-ios-caseTests
//
//  Created by Ahmet Ozen on 16.01.2026.
//
import XCTest
@testable import enuygun_ios_case

final class FavoritesViewModelTests: XCTestCase {

    // MARK: - Mocks

    final class MockFavoritesStore: FavoritesStoreProtocol {
        private(set) var favorites: [Product] = []

        func isFavorite(_ product: Product) -> Bool {
            favorites.contains(where: { $0.id == product.id })
        }

        func toggle(_ product: Product) {
            if isFavorite(product) {
                favorites.removeAll { $0.id == product.id }
            } else {
                favorites.insert(product, at: 0)
            }
        }

        func all() -> [Product] {
            favorites
        }

        func remove(_ product: Product) {
            favorites.removeAll { $0.id == product.id }
        }
    }

    final class MockCartStore: CartStoreProtocol {
        private(set) var items: [CartItem] = [] {
            didSet { onChange?() }
        }

        var totalItemsCount: Int {
            items.reduce(0) { $0 + $1.quantity }
        }

        var onChange: (() -> Void)?

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
    }

    // MARK: - Tests

    func test_addToCartFromFavorites() {
        let favoritesStore = MockFavoritesStore()
        let cartStore = MockCartStore()

        let product = Product(
            id: 1,
            title: "Test",
            description: "",
            category: "test",
            price: 100,
            discountPercentage: nil,
            rating: 4,
            stock: 1,
            brand: nil,
            thumbnail: "",
            images: []
        )

        favoritesStore.toggle(product)

        let sut = FavoritesViewModel(
            favoritesStore: favoritesStore,
            cartStore: cartStore
        )

        sut.addToCart(at: 0)

        XCTAssertEqual(cartStore.items.count, 1)
        XCTAssertEqual(cartStore.items.first?.product.id, product.id)
        XCTAssertEqual(cartStore.items.first?.quantity, 1)
    }

    func test_removeRemovesFromFavorites() {
        let favoritesStore = MockFavoritesStore()
        let cartStore = MockCartStore()

        let p1 = Product(id: 1, title: "A", description: "", category: "c", price: 10, discountPercentage: nil, rating: 1, stock: 1, brand: nil, thumbnail: "", images: [])
        let p2 = Product(id: 2, title: "B", description: "", category: "c", price: 10, discountPercentage: nil, rating: 1, stock: 1, brand: nil, thumbnail: "", images: [])

        favoritesStore.toggle(p1)
        favoritesStore.toggle(p2)

        let sut = FavoritesViewModel(favoritesStore: favoritesStore, cartStore: cartStore)
        XCTAssertEqual(sut.items.count, 2)

        sut.remove(at: 0)

        XCTAssertEqual(sut.items.count, 1)
        XCTAssertFalse(favoritesStore.isFavorite(p2)) // çünkü toggle insert at 0 yaptığı için p2 baştaydı
    }
}
