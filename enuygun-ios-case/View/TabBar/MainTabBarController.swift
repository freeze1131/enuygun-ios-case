//
//  MainTabBarController.swift
//  enuygun-ios-case
//
//  Created by Ahmet Ozen on 15.01.2026.
//

import UIKit

final class MainTabBarController: UITabBarController {

    private let container: AppContainerProtocol

    init(container: AppContainerProtocol) {
        self.container = container
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()

        container.cartStore.onChange = { [weak self] in
            self?.updateCartBadge()
        }

        setupTabs()
        configureTabBarAppearance()
        updateCartBadge()
    }

    private func setupTabs() {
        let productListVM = ProductListViewModel(service: container.productService)
        let homeVC = UINavigationController(
            rootViewController: ProductListViewController(
                viewModel: productListVM,
                container: container
            )
        )
        homeVC.tabBarItem = UITabBarItem(
            title: "Home",
            image: UIImage(systemName: "house"),
            selectedImage: UIImage(systemName: "house.fill")
        )

        let favoritesVM = FavoritesViewModel(
            favoritesStore: container.favoritesStore,
            cartStore: container.cartStore
        )
        let favoritesVC = UINavigationController(
            rootViewController: FavoritesViewController(
                viewModel: favoritesVM,
                container: container
            )
        )
        favoritesVC.tabBarItem = UITabBarItem(
            title: "Favorites",
            image: UIImage(systemName: "heart"),
            selectedImage: UIImage(systemName: "heart.fill")
        )

        let cartVM = CartViewModel(cartStore: container.cartStore)
        let cartVC = UINavigationController(
            rootViewController: CartViewController(
                viewModel: cartVM,
                container: container
            )
        )
        cartVC.tabBarItem = UITabBarItem(
            title: "Cart",
            image: UIImage(systemName: "cart"),
            selectedImage: UIImage(systemName: "cart.fill")
        )

        viewControllers = [homeVC, favoritesVC, cartVC]
    }

    private func updateCartBadge() {
        let count = container.cartStore.totalItemsCount
        let cartIndex = 2
        tabBar.items?[cartIndex].badgeValue = count > 0 ? "\(count)" : nil
    }

    private func configureTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .secondarySystemGroupedBackground
        appearance.shadowColor = .separator

        tabBar.tintColor = .label
        tabBar.unselectedItemTintColor = .secondaryLabel

        tabBar.standardAppearance = appearance
        if #available(iOS 15.0, *) {
            tabBar.scrollEdgeAppearance = appearance
        }
    }
}
