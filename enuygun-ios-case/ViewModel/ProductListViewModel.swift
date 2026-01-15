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

    private(set) var totalFromAPI: Int = 0
    private(set) var allProducts: [Product] = []
    private(set) var products: [Product] = [] { didSet { onUpdate?() } }

    var onUpdate: (() -> Void)?

    private var searchQuery: String = ""
    private var selectedCategory: String? = nil   // nil = All
    private var sortOption: SortOption = .relevance

    init(service: ProductService = ProductService()) {
        self.service = service
    }

    func loadProducts() async {
        do {
            let response = try await service.fetchProducts()
            totalFromAPI = response.total
            allProducts = response.products
            apply()
        } catch {
            print("ViewModel error:", error)
            // İstersen burada error state ekleriz (sonra)
        }
    }

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
