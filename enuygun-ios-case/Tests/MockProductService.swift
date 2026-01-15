//
//  MockProductService.swift
//  enuygun-ios-case
//
//  Created by Ahmet Ozen on 16.01.2026.
//

import Foundation
@testable import enuygun_ios_case

final class MockProductService: ProductServiceProtocol {

    var products: [Product] = []
    var error: Error?

    // MARK: - Fetch (normal list)
    func fetchProducts(skip: Int, limit: Int) async throws -> ProductResponse {
        if let error { throw error }

        let slice = Array(products.dropFirst(skip).prefix(limit))
        return ProductResponse(
            products: slice,
            total: products.count,
            skip: skip,
            limit: limit
        )
    }

    // MARK: - Search
    func searchProducts(query: String, skip: Int, limit: Int) async throws -> ProductResponse {
        if let error { throw error }

        let q = query.lowercased()

        let filtered = products.filter { p in
            let haystack = [
                p.title,
                p.description,
                p.brand ?? ""
            ]
            .joined(separator: " ")
            .lowercased()

            return haystack.contains(q)
        }

        let slice = Array(filtered.dropFirst(skip).prefix(limit))
        return ProductResponse(
            products: slice,
            total: filtered.count,
            skip: skip,
            limit: limit
        )
    }
}
