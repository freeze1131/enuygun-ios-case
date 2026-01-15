//
//  FavoritesViewModelTests.swift
//  enuygun-ios-caseTests
//
//  Created by Ahmet Ozen on 16.01.2026.
//
import XCTest
@testable import enuygun_ios_case

final class FavoritesViewModelTests: XCTestCase {

    // MARK: - Properties
    
    var sut: FavoritesViewModel!
    var favoritesStore: MockFavoritesStore!
    var cartStore: MockCartStore!
    
    // MARK: - Lifecycle
    
    override func setUp() {
        super.setUp()
        favoritesStore = MockFavoritesStore()
        cartStore = MockCartStore()
    }
    
    override func tearDown() {
        sut = nil
        favoritesStore = nil
        cartStore = nil
        super.tearDown()
    }

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
                favorites.append(product)
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
        // Arrange
        let product = Product.testProduct(id: 1, title: "Test Product")
        favoritesStore.toggle(product)
        
        sut = FavoritesViewModel(
            favoritesStore: favoritesStore,
            cartStore: cartStore
        )

        // Act
        sut.addToCart(at: 0)

        // Assert
        XCTAssertEqual(cartStore.items.count, 1, "Cart should contain 1 item")
        XCTAssertEqual(cartStore.items.first?.product.id, product.id, "Product ID should match")
        XCTAssertEqual(cartStore.items.first?.quantity, 1, "Quantity should be 1")
    }

    func test_removeRemovesFromFavorites() {
        let p1 = Product.testProduct(id: 1, title: "Product A")
        let p2 = Product.testProduct(id: 2, title: "Product B")

        favoritesStore.toggle(p1)
        favoritesStore.toggle(p2)

        sut = FavoritesViewModel(favoritesStore: favoritesStore, cartStore: cartStore)
        XCTAssertEqual(sut.items.count, 2)

        sut.remove(at: 0) // p1 sil

        XCTAssertEqual(sut.items.count, 1)
        XCTAssertEqual(sut.items.first?.id, p2.id, "Product B should remain")
        XCTAssertFalse(favoritesStore.isFavorite(p1), "Product A should be removed from favorites")
    }

    
    func test_loadRefreshesItems() {
        // Arrange
        let product = Product.testProduct(id: 1)
        favoritesStore.toggle(product)
        
        sut = FavoritesViewModel(
            favoritesStore: favoritesStore,
            cartStore: cartStore
        )
        
        XCTAssertEqual(sut.items.count, 1)
        
        // Act - Add another product directly to store
        let product2 = Product.testProduct(id: 2)
        favoritesStore.toggle(product2)
        sut.load()
        
        // Assert
        XCTAssertEqual(sut.items.count, 2, "Load should refresh items from store")
    }
    
    func test_isEmptyReturnsTrueWhenNoFavorites() {
        // Arrange
        sut = FavoritesViewModel(
            favoritesStore: favoritesStore,
            cartStore: cartStore
        )
        
        // Assert
        XCTAssertTrue(sut.isEmpty, "Should be empty when no favorites")
    }
    
    func test_isEmptyReturnsFalseWhenHasFavorites() {
        // Arrange
        let product = Product.testProduct(id: 1)
        favoritesStore.toggle(product)
        
        sut = FavoritesViewModel(
            favoritesStore: favoritesStore,
            cartStore: cartStore
        )
        
        // Assert
        XCTAssertFalse(sut.isEmpty, "Should not be empty when has favorites")
    }
    
    func test_productAtIndexReturnsCorrectProduct() {
        // Arrange
        let product1 = Product.testProduct(id: 1, title: "First")
        let product2 = Product.testProduct(id: 2, title: "Second")
        
        favoritesStore.toggle(product1)
        favoritesStore.toggle(product2)
        
        sut = FavoritesViewModel(
            favoritesStore: favoritesStore,
            cartStore: cartStore
        )
        
        // Act & Assert
        XCTAssertEqual(sut.product(at: 0).id, product1.id)
        XCTAssertEqual(sut.product(at: 1).id, product2.id)
    }
}

// MARK: - Test Helpers

extension Product {
    static func testProduct(
        id: Int,
        title: String = "Test Product",
        price: Double = 100.0,
        discountPercentage: Double? = nil
    ) -> Product {
        Product(
            id: id,
            title: title,
            description: "Test Description",
            category: "test",
            price: price,
            discountPercentage: discountPercentage,
            rating: 4.5,
            stock: 10,
            brand: "Test Brand",
            thumbnail: "https://example.com/image.jpg",
            images: []
        )
    }
}
