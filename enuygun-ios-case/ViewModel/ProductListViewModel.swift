//
//  ProductListViewModel.swift
//  enuygun-ios-case
//
//  Created by Ahmet Ozen on 15.01.2026.
//

import Foundation
import Combine


import Foundation

@MainActor
final class ProductListViewModel: ObservableObject {

    @Published private(set) var products: [Product] = []

    private let service: ProductService

    init(service: ProductService = ProductService()) {
        self.service = service
    }

    func loadProducts() async {
        do {
            print("Task started")
            let response = try await service.fetchProducts()
            self.products = response.products
            print("Products loaded: \(products.count)")
        } catch {
            print("ViewModel error:", error)
        }
    }
}

