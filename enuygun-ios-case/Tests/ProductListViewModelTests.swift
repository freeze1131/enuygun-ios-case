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

    // MARK: - Helpers

    private func makeProduct(
        id: Int,
        title: String,
        price: Double,
        rating: Double = 4.0,
        discount: Double? = nil,
        category: String = "phones",
        brand: String? = nil
    ) -> Product {
        Product(
            id: id,
            title: title,
            description: "desc",
            category: category,
            price: price,
            discountPercentage: discount,
            rating: rating,
            stock: 10,
            brand: brand,
            thumbnail: "https://example.com/img.png",
            images: []
        )
    }

    // MARK: - Tests

    func test_loadProducts_setsProductsAndTotal() async {
        // given
        let mockService = MockProductService()
        mockService.result = .success(
            ProductResponse(
                products: [
                    makeProduct(id: 1, title: "iPhone", price: 1000)
                ],
                total: 1,
                skip: 0,
                limit: 30
            )
        )

        let sut = ProductListViewModel(service: mockService)

        // when
        await sut.loadProducts()

        // then
        XCTAssertEqual(sut.totalFromAPI, 1)
        XCTAssertEqual(sut.products.count, 1)
        XCTAssertEqual(sut.products.first?.title, "iPhone")
    }

    func test_search_filtersProductsByTitle() async {
        // given
        let mockService = MockProductService()
        mockService.result = .success(
            ProductResponse(
                products: [
                    makeProduct(id: 1, title: "iPhone", price: 1000),
                    makeProduct(id: 2, title: "Samsung Galaxy", price: 900)
                ],
                total: 2,
                skip: 0,
                limit: 30
            )
        )

        let sut = ProductListViewModel(service: mockService)
        await sut.loadProducts()

        // when
        sut.setSearchQuery("iphone")

        // then
        XCTAssertEqual(sut.products.count, 1)
        XCTAssertEqual(sut.products.first?.title, "iPhone")
    }

    func test_sort_priceLowToHigh_sortsCorrectly() async {
        // given
        let mockService = MockProductService()
        mockService.result = .success(
            ProductResponse(
                products: [
                    makeProduct(id: 1, title: "Expensive", price: 2000),
                    makeProduct(id: 2, title: "Cheap", price: 500)
                ],
                total: 2,
                skip: 0,
                limit: 30
            )
        )

        let sut = ProductListViewModel(service: mockService)
        await sut.loadProducts()

        // when
        sut.setSortOption(.priceLowToHigh)

        // then
        XCTAssertEqual(sut.products.first?.title, "Cheap")
        XCTAssertEqual(sut.products.last?.title, "Expensive")
    }

    func test_sort_discountHighToLow_sortsCorrectly() async {
        // given
        let mockService = MockProductService()
        mockService.result = .success(
            ProductResponse(
                products: [
                    makeProduct(id: 1, title: "Low Discount", price: 1000, discount: 5),
                    makeProduct(id: 2, title: "High Discount", price: 1000, discount: 30)
                ],
                total: 2,
                skip: 0,
                limit: 30
            )
        )

        let sut = ProductListViewModel(service: mockService)
        await sut.loadProducts()

        // when
        sut.setSortOption(.discountHighToLow)

        // then
        XCTAssertEqual(sut.products.first?.title, "High Discount")
    }
}
