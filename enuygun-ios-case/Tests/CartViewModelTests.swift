//
//  CartViewModelTests.swift
//  enuygun-ios-case
//
//  Created by Ahmet Ozen on 16.01.2026.
//
import XCTest
@testable import enuygun_ios_case

final class CartViewModelTests: XCTestCase {

    private var store: MockCartStore!
    private var sut: CartViewModel!

    override func setUp() {
        super.setUp()
        store = MockCartStore()
        sut = CartViewModel(cartStore: store)
    }

    override func tearDown() {
        sut = nil
        store = nil
        super.tearDown()
    }

    func test_load_readsItemsFromStore() {
        // GIVEN
        store.items = [
            CartItem(product: makeProduct(id: 1, price: 10, discount: nil), quantity: 2)
        ]

        // WHEN
        sut.load()

        // THEN
        XCTAssertEqual(sut.items.count, 1)
        XCTAssertEqual(sut.items.first?.quantity, 2)
    }

    func test_subtotalText_withDiscount_calculatesCorrectly() {
        // GIVEN: price 100, discount 10% => 90, qty 2 => 180
        store.items = [
            CartItem(product: makeProduct(id: 1, price: 100, discount: 10), quantity: 2)
        ]
        sut.load()

        // WHEN
        let subtotal = sut.subtotalText

        // THEN
        XCTAssertEqual(subtotal, "$180.00")
    }

    func test_increaseQuantity_callsStoreAndReloads() {
        // GIVEN
        store.items = [
            CartItem(product: makeProduct(id: 1, price: 10, discount: nil), quantity: 1)
        ]
        sut.load()

        // WHEN
        sut.increaseQuantity(at: 0)

        // THEN
        XCTAssertEqual(store.increaseCalledWith, [1])
        XCTAssertEqual(sut.items.first?.quantity, 2)
    }

    func test_decreaseQuantity_whenQuantityGreaterThan1_decreases() {
        // GIVEN
        store.items = [
            CartItem(product: makeProduct(id: 1, price: 10, discount: nil), quantity: 2)
        ]
        sut.load()

        // WHEN
        sut.decreaseQuantity(at: 0)

        // THEN
        XCTAssertEqual(store.decreaseCalledWith, [1])
        XCTAssertEqual(sut.items.first?.quantity, 1)
    }

    func test_shouldConfirmRemove_whenQuantityIs1_returnsTrue() {
        // GIVEN
        store.items = [
            CartItem(product: makeProduct(id: 1, price: 10, discount: nil), quantity: 1)
        ]
        sut.load()

        // THEN
        XCTAssertTrue(sut.shouldConfirmRemove(at: 0))
    }

    func test_removeItem_callsStoreAndReloads() {
        // GIVEN
        store.items = [
            CartItem(product: makeProduct(id: 1, price: 10, discount: nil), quantity: 1)
        ]
        sut.load()

        // WHEN
        sut.removeItem(at: 0)

        // THEN
        XCTAssertEqual(store.removeCalledWith, [1])
        XCTAssertEqual(sut.items.count, 0)
    }

    // MARK: - Helpers

    private func makeProduct(id: Int, price: Double, discount: Double?) -> Product {
        Product(
            id: id,
            title: "P\(id)",
            description: "",
            category: "x",
            price: price,
            discountPercentage: discount,
            rating: 4.0,
            stock: 10,
            brand: nil,
            thumbnail: "",
            images: []
        )
    }
}

// MARK: - MockCartStore

private final class MockCartStore: CartStoreProtocol {

    var items: [CartItem] = []
    var onChange: (() -> Void)?

    var totalItemsCount: Int {
        items.reduce(0) { $0 + $1.quantity }
    }

    var increaseCalledWith: [Int] = []
    var decreaseCalledWith: [Int] = []
    var removeCalledWith: [Int] = []

    func add(_ product: Product) {
        if let idx = items.firstIndex(where: { $0.product.id == product.id }) {
            items[idx].quantity += 1
        } else {
            items.append(CartItem(product: product, quantity: 1))
        }
        onChange?()
    }

    func increase(productId: Int) {
        increaseCalledWith.append(productId)
        guard let idx = items.firstIndex(where: { $0.product.id == productId }) else { return }
        items[idx].quantity += 1
        onChange?()
    }

    func decrease(productId: Int) {
        decreaseCalledWith.append(productId)
        guard let idx = items.firstIndex(where: { $0.product.id == productId }) else { return }
        items[idx].quantity = max(1, items[idx].quantity - 1)
        onChange?()
    }

    func remove(productId: Int) {
        removeCalledWith.append(productId)
        items.removeAll { $0.product.id == productId }
        onChange?()
    }

    func clear() {
        items = []
        onChange?()
    }
}
