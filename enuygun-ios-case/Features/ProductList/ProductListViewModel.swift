//
//  ProductListViewModel.swift
//  enuygun-ios-case
//
//  Created by Ahmet Ozen on 15.01.2026.
//

import Foundation
import Combine


final class ProductListViewModel: ObservableObject {

    private let productService: ProductService

    private(set) var products: [Product] = []
    private(set) var isLoading: Bool = false
    private(set) var errorMessage: String?

    init(productService: ProductService = ProductService()) {
        self.productService = productService
    }

    @MainActor
    func fetchProducts() async {
        isLoading = true
        errorMessage = nil

        do {
            let response = try await productService.fetchProducts()
            products = response.products
        } catch {
            errorMessage = "Something went wrong"
        }


        isLoading = false
    }
}
