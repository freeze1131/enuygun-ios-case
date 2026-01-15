//
//  CartItem.swift
//  enuygun-ios-case
//
//  Created by Ahmet Ozen on 15.01.2026.
//
import Foundation

struct CartItem: Codable {
    let product: Product
    var quantity: Int

    init(product: Product, quantity: Int = 1) {
        self.product = product
        self.quantity = max(1, quantity)
    }

    var unitPrice: Double {
        // indirim varsa discounted
        if let discount = product.discountPercentage, discount > 0 {
            return product.price * (1 - discount / 100)
        }
        return product.price
    }

    var lineTotal: Double {
        unitPrice * Double(quantity)
    }
}
