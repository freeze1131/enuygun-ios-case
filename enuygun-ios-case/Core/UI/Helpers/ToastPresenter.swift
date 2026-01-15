//
//  ToastPresenter.swift
//  enuygun-ios-case
//
//  Created by Ahmet Ozen on 15.01.2026.
//

import UIKit

enum ToastPresenter {

    struct Action {
        let title: String
        let style: UIAlertAction.Style
        let handler: (() -> Void)?

        init(
            title: String,
            style: UIAlertAction.Style = .default,
            handler: (() -> Void)? = nil
        ) {
            self.title = title
            self.style = style
            self.handler = handler
        }
    }

    static func show(
        on viewController: UIViewController,
        title: String? = nil,
        message: String,
        duration: TimeInterval = 0.6,
        primaryAction: Action? = nil,
        secondaryAction: Action? = nil
    ) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )

        if let primaryAction {
            alert.addAction(
                UIAlertAction(
                    title: primaryAction.title,
                    style: primaryAction.style
                ) { _ in
                    primaryAction.handler?()
                }
            )
        }

        if let secondaryAction {
            alert.addAction(
                UIAlertAction(
                    title: secondaryAction.title,
                    style: secondaryAction.style
                ) { _ in
                    secondaryAction.handler?()
                }
            )
        }

        viewController.present(alert, animated: true)

        if primaryAction == nil && secondaryAction == nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                alert.dismiss(animated: true)
            }
        }
    }
}
