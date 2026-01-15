//
//  enuygun_ios_caseApp.swift
//  enuygun-ios-case
//
//  Created by Ahmet Ozen on 15.01.2026.
//

import SwiftUI
import UIKit

@main
struct enuygun_ios_caseApp: App {
    var body: some Scene {
        WindowGroup {
            MainTabBarWrapper()
        }
    }
}

struct MainTabBarWrapper: UIViewControllerRepresentable {

    // Container burada tek kez oluşsun
    private let container: AppContainerProtocol = AppContainer()

    func makeUIViewController(context: Context) -> UIViewController {
        MainTabBarController(container: container)
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}
