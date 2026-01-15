//
//  AppContainer.swift
//  enuygun-ios-case
//
//  Created by Ahmet Ozen on 15.01.2026.
//

import Foundation

protocol AppContainerProtocol {
    var productService: ProductServiceProtocol { get }
    var cartStore: CartStoreProtocol { get }
    var favoritesStore: FavoritesStoreProtocol { get }
}

final class AppContainer: AppContainerProtocol {

    let cartStore: CartStoreProtocol
    let favoritesStore: FavoritesStoreProtocol
    let productService: ProductServiceProtocol

    init(
        cartStore: CartStoreProtocol = CartStore.shared,
        favoritesStore: FavoritesStoreProtocol = FavoritesStore.shared,
        productService: ProductServiceProtocol = ProductService()
    ) {
        self.cartStore = cartStore
        self.favoritesStore = favoritesStore
        self.productService = productService
    }
}
