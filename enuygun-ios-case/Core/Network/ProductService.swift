//
//  ProductService.swift
//  enuygun-ios-case
//
//  Created by Ahmet Ozen on 15.01.2026.
//

import Foundation

protocol ProductServiceProtocol {
    func fetchProducts(skip: Int, limit: Int) async throws -> ProductResponse
    func searchProducts(query: String, skip: Int, limit: Int) async throws -> ProductResponse
}

final class ProductService: ProductServiceProtocol {

    private let session: URLSession
    private let decoder: JSONDecoder

    init(session: URLSession = .shared, decoder: JSONDecoder = JSONDecoder()) {
        self.session = session
        self.decoder = decoder
    }
    
    func searchProducts(query: String, skip: Int, limit: Int = APIConstants.pageLimit) async throws -> ProductResponse {
        var components = URLComponents(string: APIConstants.baseURL + APIConstants.productsPath + "/search")
        components?.queryItems = [
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "limit", value: "\(limit)"),
            URLQueryItem(name: "skip", value: "\(skip)")
        ]

        guard let url = components?.url else { throw URLError(.badURL) }

        let (data, response) = try await session.data(from: url)

        guard let http = response as? HTTPURLResponse, 200..<300 ~= http.statusCode else {
            throw URLError(.badServerResponse)
        }

        return try decoder.decode(ProductResponse.self, from: data)
    }


    func fetchProducts(skip: Int, limit: Int = APIConstants.pageLimit) async throws -> ProductResponse {
        var components = URLComponents(string: APIConstants.baseURL + APIConstants.productsPath)
        components?.queryItems = [
            URLQueryItem(name: "limit", value: "\(limit)"),
            URLQueryItem(name: "skip", value: "\(skip)")
        ]

        guard let url = components?.url else { throw URLError(.badURL) }

        let (data, response) = try await session.data(from: url)

        guard let http = response as? HTTPURLResponse, 200..<300 ~= http.statusCode else {
            throw URLError(.badServerResponse)
        }

        return try decoder.decode(ProductResponse.self, from: data)
    }
}
