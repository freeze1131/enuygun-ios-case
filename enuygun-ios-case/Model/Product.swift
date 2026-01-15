//
//  Product.swift
//  enuygun-ios-case
//
//  Created by Ahmet Ozen on 15.01.2026.
//

import Foundation

struct Product: Codable, Identifiable {
    let id: Int
    let title: String
    let description: String
    let category: String
    let price: Double
    let discountPercentage: Double?
    let rating: Double
    let stock: Int
    let brand: String?
    let thumbnail: String
    let images: [String]
}
