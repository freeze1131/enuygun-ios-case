//
//  MainTabBarController.swift
//  enuygun-ios-case
//
//  Created by Ahmet Ozen on 15.01.2026.
//

import UIKit

final class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        CartStore.shared.onChange = { [weak self] in
            self?.updateCartBadge()
        }
        
        setupTabs()
        configureTabBarAppearance()
        updateCartBadge()
    }

    private func setupTabs() {
        let homeVC = UINavigationController(rootViewController: ProductListViewController())
        homeVC.tabBarItem = UITabBarItem(
            title: "Home",
            image: UIImage(systemName: "house"),
            selectedImage: UIImage(systemName: "house.fill")
        )

        let favoritesVC = UINavigationController(rootViewController: FavoritesViewController())
        favoritesVC.tabBarItem = UITabBarItem(
            title: "Favorites",
            image: UIImage(systemName: "heart"),
            selectedImage: UIImage(systemName: "heart.fill")
        )

        let cartVC = UINavigationController(rootViewController: CartViewController())
        cartVC.tabBarItem = UITabBarItem(
            title: "Cart",
            image: UIImage(systemName: "cart"),
            selectedImage: UIImage(systemName: "cart.fill")
        )

        viewControllers = [homeVC, favoritesVC, cartVC]
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
    
    private func updateCartBadge() {
        let count = CartStore.shared.totalItemsCount
        let cartIndex = 2 

        if count > 0 {
            tabBar.items?[cartIndex].badgeValue = "\(count)"
        } else {
            tabBar.items?[cartIndex].badgeValue = nil
        }
    }


}

