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

    private enum Mode: Equatable {
        case browse
        case search(query: String)
    }

    private let service: ProductServiceProtocol

    // API totals
    private(set) var totalFromAPI: Int = 0

    // Pagination state
    private var loadedCount: Int = 0
    private var isLoadingMore: Bool = false
    private var canLoadMore: Bool = true

    // Raw data from API for current mode
    private(set) var allProducts: [Product] = []

    // Rendered (after filter/sort)
    private(set) var products: [Product] = [] {
        didSet { onUpdate?() }
    }

    var onUpdate: (() -> Void)?

    // Inputs
    private var searchQuery: String = ""
    private var selectedCategory: String? = nil // nil = All
    private var sortOption: SortOption = .relevance

    private var mode: Mode = .browse

    init(service: ProductServiceProtocol = ProductService()) {
        self.service = service
    }

    // MARK: - Initial Load
    func loadProducts() async {
        mode = .browse
        resetPagination()
        await loadMoreIfNeeded(force: true)
    }

    // MARK: - Pagination
    func loadMoreIfNeeded(force: Bool = false) async {
        guard !isLoadingMore else { return }
        guard canLoadMore || force else { return }

        isLoadingMore = true
        defer { isLoadingMore = false }

        do {
            let response: ProductResponse
            switch mode {
            case .browse:
                response = try await service.fetchProducts(skip: loadedCount, limit: APIConstants.pageLimit)
            case .search(let q):
                response = try await service.searchProducts(query: q, skip: loadedCount, limit: APIConstants.pageLimit)
            }

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
        let threshold = max(0, products.count - 6)
        return currentIndex >= threshold
    }

    // MARK: - Search / Filter / Sort
    func setSearchQuery(_ query: String) {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        searchQuery = trimmed

        // IMPORTANT: if query changes meaningfully, restart from page 0 for search.
        if trimmed.isEmpty {
            if mode != .browse {
                // go back to browse mode
                mode = .browse
                Task { await reloadForCurrentMode() }
            } else {
                apply() // local changes (e.g. sort/filter) still apply
            }
        } else {
            let newMode: Mode = .search(query: trimmed)
            if mode != newMode {
                mode = newMode
                Task { await reloadForCurrentMode() }
            } else {
                // same query (e.g. typing spaces), still apply local ops
                apply()
            }
        }
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

    // MARK: - Current UI State
    func currentCategory() -> String? { selectedCategory }
    func currentSortOption() -> SortOption { sortOption }

    // MARK: - Internal
    private func reloadForCurrentMode() async {
        resetPagination()
        await loadMoreIfNeeded(force: true)
    }

    private func resetPagination() {
        loadedCount = 0
        isLoadingMore = false
        canLoadMore = true

        totalFromAPI = 0
        allProducts = []
        products = []
    }

    private func apply() {
        var result = allProducts

        // Filter: category (local)
        if let category = selectedCategory, !category.isEmpty {
            result = result.filter { $0.category == category }
        }

        // Search: if we are in browse mode and user typed nothing, no local search.
        // If we are in search mode, server already filtered. Still allow local contains for extra fuzz? (optional)
        // Here: keep it simple; don't double filter.

        // Sort (local)
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
