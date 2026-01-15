//
//  ProductService.swift
//  enuygun-ios-case
//
//  Created by Ahmet Ozen on 15.01.2026.
//

import Foundation

final class ProductService {

    func fetchProducts(skip: Int, limit: Int = APIConstants.pageLimit) async throws -> ProductResponse {
        var components = URLComponents(string: APIConstants.baseURL + APIConstants.productsPath)
        components?.queryItems = [
            URLQueryItem(name: "limit", value: "\(limit)"),
            URLQueryItem(name: "skip", value: "\(skip)")
        ]

        guard let url = components?.url else { throw URLError(.badURL) }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let http = response as? HTTPURLResponse, 200..<300 ~= http.statusCode else {
            throw URLError(.badServerResponse)
        }

        return try JSONDecoder().decode(ProductResponse.self, from: data)
    }
}


