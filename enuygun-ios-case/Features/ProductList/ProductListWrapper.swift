//
//  ProductListWrapper.swift
//  enuygun-ios-case
//
//  Created by Ahmet Ozen on 15.01.2026.
//

import SwiftUI

struct ProductListViewControllerWrapper: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        ProductListViewController()
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}
