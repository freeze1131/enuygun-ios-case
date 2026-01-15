//
//  enuygun_ios_caseApp.swift
//  enuygun-ios-case
//
//  Created by Ahmet Ozen on 15.01.2026.
//

import SwiftUI

@main
struct enuygun_ios_caseApp: App {
    var body: some Scene {
        WindowGroup {
            MainTabBarWrapper()
        }
    }
}

struct MainTabBarWrapper: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        MainTabBarController()
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}
