//
//  ProductListViewModelTests.swift
//  enuygun-ios-case
//
//  Created by Ahmet Ozen on 16.01.2026.
//

import XCTest
@testable import enuygun_ios_case

@MainActor
final class ProductListViewModelTests: XCTestCase {

    private var service: MockProductService!
    private var sut: ProductListViewModel!

    override func setUp() {
        super.setUp()

        service = MockProductService()
        service.products = [
            Product(
                id: 1,
                title: "iPhone 15",
                description: "Apple smartphone",
                category: "phones",
                price: 1200,
                discountPercentage: 10,
                rating: 4.8,
                stock: 5,
                brand: "Apple",
                thumbnail: "",
                images: []
            ),
            Product(
                id: 2,
                title: "Samsung Galaxy",
                description: "Android phone",
                category: "phones",
                price: 900,
                discountPercentage: nil,
                rating: 4.3,
                stock: 10,
                brand: "Samsung",
                thumbnail: "",
                images: []
            ),
            Product(
                id: 3,
                title: "MacBook Pro",
                description: "Apple laptop",
                category: "laptops",
                price: 2500,
                discountPercentage: 15,
                rating: 4.9,
                stock: 3,
                brand: "Apple",
                thumbnail: "",
                images: []
            )
        ]

        sut = ProductListViewModel(service: service)
    }

    override func tearDown() {
        sut = nil
        service = nil
        super.tearDown()
    }

    // MARK: - Tests

    func test_loadProducts_fetchesInitialProducts() async {
        await sut.loadProducts()

        XCTAssertEqual(sut.products.count, 3)
        XCTAssertEqual(sut.totalFromAPI, 3)
    }

    func test_searchFiltersProducts() async {
        await sut.loadProducts()

        sut.setSearchQuery("apple")
        
        await Task.yield()
        XCTAssertEqual(sut.products.count, 2)
        XCTAssertTrue(sut.products.allSatisfy {
            $0.brand == "Apple"
        })
    }

    func test_filterByCategory() async {
        await sut.loadProducts()

        sut.setCategory("phones")

        XCTAssertEqual(sut.products.count, 2)
        XCTAssertTrue(sut.products.allSatisfy {
            $0.category == "phones"
        })
    }

    func test_sortByPriceLowToHigh() async {
        await sut.loadProducts()

        sut.setSortOption(.priceLowToHigh)

        let prices = sut.products.map { $0.price }
        XCTAssertEqual(prices, prices.sorted())
    }

    func test_sortByRatingHighToLow() async {
        await sut.loadProducts()

        sut.setSortOption(.ratingHighToLow)

        let ratings = sut.products.map { $0.rating }
        XCTAssertEqual(ratings, ratings.sorted(by: >))
    }

    func test_paginationLoadsMore() async {
        service.products = (1...50).map {
            Product(
                id: $0,
                title: "Product \($0)",
                description: "Desc",
                category: "test",
                price: Double($0),
                discountPercentage: nil,
                rating: 4.0,
                stock: 10,
                brand: nil,
                thumbnail: "",
                images: []
            )
        }

        await sut.loadProducts()
        XCTAssertEqual(sut.products.count, APIConstants.pageLimit)

        await sut.loadMoreIfNeeded()
        XCTAssertTrue(sut.products.count > APIConstants.pageLimit)
    }
}
