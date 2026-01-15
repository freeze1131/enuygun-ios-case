//
//  ProductListViewModel.swift
//  enuygun-ios-case
//
//  Created by Ahmet Ozen on 15.01.2026.
//

import Foundation

@MainActor
final class ProductListViewModel {

    enum SortOption: CaseIterable {
        case relevance
        case priceLowToHigh
        case priceHighToLow
        case ratingHighToLow
        case discountHighToLow

        var title: String {
            switch self {
            case .relevance: return "Relevance"
            case .priceLowToHigh: return "Price: Low → High"
            case .priceHighToLow: return "Price: High → Low"
            case .ratingHighToLow: return "Rating: High → Low"
            case .discountHighToLow: return "Discount: High → Low"
            }
        }
    }

    private let service: ProductService

    // API totals
    private(set) var totalFromAPI: Int = 0

    // Pagination state
    private var loadedCount: Int = 0
    private var isLoadingMore: Bool = false
    private var canLoadMore: Bool = true

    private(set) var allProducts: [Product] = []

    private(set) var products: [Product] = [] {
        didSet { onUpdate?() }
    }

    var onUpdate: (() -> Void)?

    // Filters
    private var searchQuery: String = ""
    private var selectedCategory: String? = nil // nil = All
    private var sortOption: SortOption = .relevance

    init(service: ProductService = ProductService()) {
        self.service = service
    }

    // MARK: - Initial Load (resets pagination)
    func loadProducts() async {
        loadedCount = 0
        isLoadingMore = false
        canLoadMore = true

        totalFromAPI = 0
        allProducts = []
        products = []

        await loadMoreIfNeeded(force: true)
    }

    // MARK: - Pagination
    func loadMoreIfNeeded(force: Bool = false) async {
        guard !isLoadingMore else { return }
        guard canLoadMore || force else { return }

        isLoadingMore = true
        defer { isLoadingMore = false }

        do {
            let response = try await service.fetchProducts(skip: loadedCount, limit: APIConstants.pageLimit)
            totalFromAPI = response.total

            allProducts.append(contentsOf: response.products)
            loadedCount = allProducts.count

            canLoadMore = loadedCount < totalFromAPI

            apply()
        } catch {
            print("Pagination error:", error)
        }
    }

    func shouldLoadMore(currentIndex: Int) -> Bool {
        // When user scrolls near the end of currently rendered list, fetch next page.
        let threshold = max(0, products.count - 6)
        return currentIndex >= threshold
    }

    // MARK: - Search / Filter / Sort inputs
    func setSearchQuery(_ query: String) {
        searchQuery = query
        apply()
    }

    func setCategory(_ category: String?) {
        selectedCategory = category
        apply()
    }

    func setSortOption(_ option: SortOption) {
        sortOption = option
        apply()
    }

    func availableCategories() -> [String] {
        Array(Set(allProducts.map { $0.category })).sorted()
    }

    // MARK: - Apply pipeline
    private func apply() {
        var result = allProducts

        // Filter: category
        if let category = selectedCategory, !category.isEmpty {
            result = result.filter { $0.category == category }
        }

        // Search: title + description + brand(optional)
        let q = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if !q.isEmpty {
            result = result.filter { p in
                let haystack = [
                    p.title,
                    p.description,
                    p.brand ?? ""
                ].joined(separator: " ").lowercased()
                return haystack.contains(q)
            }
        }

        // Sort
        switch sortOption {
        case .relevance:
            break
        case .priceLowToHigh:
            result.sort { $0.price < $1.price }
        case .priceHighToLow:
            result.sort { $0.price > $1.price }
        case .ratingHighToLow:
            result.sort { $0.rating > $1.rating }
        case .discountHighToLow:
            result.sort { ($0.discountPercentage ?? 0) > ($1.discountPercentage ?? 0) }
        }

        products = result
    }
}
