//
//  MockProductService.swift
//  enuygun-ios-case
//
//  Created by Ahmet Ozen on 16.01.2026.
//

import Foundation
@testable import enuygun_ios_case

final class MockProductService: ProductServiceProtocol {

    var result: Result<ProductResponse, Error>!

    func fetchProducts(skip: Int, limit: Int) async throws -> ProductResponse {
        switch result {
        case .success(let response):
            return response
        case .failure(let error):
            throw error
        case .none:
            fatalError("MockProductService.result must be set before calling fetchProducts")
        }
    }
}

