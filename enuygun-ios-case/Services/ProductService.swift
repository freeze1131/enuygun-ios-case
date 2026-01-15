//
//  ProductService.swift
//  enuygun-ios-case
//
//  Created by Ahmet Ozen on 15.01.2026.
//

import Foundation

final class ProductService {

    func fetchProducts() async throws -> ProductResponse {
        let urlString = APIConstants.baseURL + APIConstants.productsPath
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              200..<300 ~= httpResponse.statusCode else {
            throw URLError(.badServerResponse)
        }

        let decodedResponse = try JSONDecoder().decode(ProductResponse.self, from: data)
        return decodedResponse
    }
}


