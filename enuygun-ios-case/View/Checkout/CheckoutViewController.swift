//
//  CheckoutViewController.swift
//  enuygun-ios-case
//
//  Created by Ahmet Ozen on 15.01.2026.
//

import UIKit

final class CheckoutViewController: UIViewController {

    private let cartStore = CartStore.shared

    // MARK: - UI

    private let scrollView = UIScrollView()
    private let contentView = UIView()

    private let nameField = UITextField()
    private let phoneField = UITextField()
    private let addressView = UITextView()

    private let shippingSegment: UISegmentedControl = {
        let s = UISegmentedControl(items: ["Standard", "Express"])
        s.selectedSegmentIndex = 0
        s.translatesAutoresizingMaskIntoConstraints = false
        return s
    }()

    private let summaryTitleLabel: UILabel = {
        let l = UILabel()
        l.text = "Order Summary"
        l.font = .systemFont(ofSize: 16, weight: .bold)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let subtotalLabel = UILabel()
    private let shippingLabel = UILabel()
    private let totalLabel = UILabel()

    private let bottomBar: UIView = {
        let v = UIView()
        v.backgroundColor = .secondarySystemGroupedBackground
        v.layer.borderWidth = 1
        v.layer.borderColor = UIColor.separator.cgColor
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let continueButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Continue to Payment", for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        b.backgroundColor = .label
        b.setTitleColor(.systemBackground, for: .normal)
        b.layer.cornerRadius = 14
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    private let totalInBarLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 14, weight: .semibold)
        l.textColor = .secondaryLabel
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let totalInBarValueLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 18, weight: .bold)
        l.textColor = .label
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    // MARK: - Pricing

    private var shippingFee: Double {
        shippingSegment.selectedSegmentIndex == 0 ? 0.0 : 9.99
    }

    private var total: Double {
        cartStore.subtotal + shippingFee
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        navigationItem.title = "Checkout"

        setupLayout()
        setupFormUI()
        updateSummary()

        shippingSegment.addTarget(self, action: #selector(shippingChanged), for: .valueChanged)
        continueButton.addTarget(self, action: #selector(continueTapped), for: .touchUpInside)

        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    // MARK: - Layout

    private func setupLayout() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        view.addSubview(bottomBar)
        bottomBar.addSubview(totalInBarLabel)
        bottomBar.addSubview(totalInBarValueLabel)
        bottomBar.addSubview(continueButton)

        NSLayoutConstraint.activate([
            bottomBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            bottomBar.heightAnchor.constraint(equalToConstant: 92),

            totalInBarLabel.topAnchor.constraint(equalTo: bottomBar.topAnchor, constant: 12),
            totalInBarLabel.leadingAnchor.constraint(equalTo: bottomBar.leadingAnchor, constant: 16),

            totalInBarValueLabel.topAnchor.constraint(equalTo: totalInBarLabel.bottomAnchor, constant: 2),
            totalInBarValueLabel.leadingAnchor.constraint(equalTo: totalInBarLabel.leadingAnchor),

            continueButton.trailingAnchor.constraint(equalTo: bottomBar.trailingAnchor, constant: -16),
            continueButton.centerYAnchor.constraint(equalTo: bottomBar.centerYAnchor),
            continueButton.heightAnchor.constraint(equalToConstant: 50),
            continueButton.widthAnchor.constraint(equalToConstant: 190),

            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomBar.topAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),

            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }

    private func setupFormUI() {
        // Section containers
        let formCard = makeCard()
        let shippingCard = makeCard()
        let summaryCard = makeCard()

        contentView.addSubview(formCard)
        contentView.addSubview(shippingCard)
        contentView.addSubview(summaryCard)

        formCard.translatesAutoresizingMaskIntoConstraints = false
        shippingCard.translatesAutoresizingMaskIntoConstraints = false
        summaryCard.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            formCard.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            formCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            formCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            shippingCard.topAnchor.constraint(equalTo: formCard.bottomAnchor, constant: 12),
            shippingCard.leadingAnchor.constraint(equalTo: formCard.leadingAnchor),
            shippingCard.trailingAnchor.constraint(equalTo: formCard.trailingAnchor),

            summaryCard.topAnchor.constraint(equalTo: shippingCard.bottomAnchor, constant: 12),
            summaryCard.leadingAnchor.constraint(equalTo: formCard.leadingAnchor),
            summaryCard.trailingAnchor.constraint(equalTo: formCard.trailingAnchor),
            summaryCard.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])

        // Form fields
        let formTitle = makeSectionTitle("Contact & Address")
        formCard.addSubview(formTitle)

        configureTextField(nameField, placeholder: "Full name")
        configureTextField(phoneField, placeholder: "Phone number")
        phoneField.keyboardType = .phonePad

        addressView.font = .systemFont(ofSize: 15)
        addressView.backgroundColor = .secondarySystemGroupedBackground
        addressView.layer.cornerRadius = 12
        addressView.layer.borderWidth = 1
        addressView.layer.borderColor = UIColor.separator.cgColor
        addressView.textContainerInset = UIEdgeInsets(top: 10, left: 8, bottom: 10, right: 8)
        addressView.text = "Address"
        addressView.textColor = .secondaryLabel

        addressView.delegate = self

        let formStack = UIStackView(arrangedSubviews: [nameField, phoneField, addressView])
        formStack.axis = .vertical
        formStack.spacing = 10
        formStack.translatesAutoresizingMaskIntoConstraints = false
        formCard.addSubview(formStack)

        NSLayoutConstraint.activate([
            formTitle.topAnchor.constraint(equalTo: formCard.topAnchor, constant: 14),
            formTitle.leadingAnchor.constraint(equalTo: formCard.leadingAnchor, constant: 14),
            formTitle.trailingAnchor.constraint(equalTo: formCard.trailingAnchor, constant: -14),

            formStack.topAnchor.constraint(equalTo: formTitle.bottomAnchor, constant: 12),
            formStack.leadingAnchor.constraint(equalTo: formCard.leadingAnchor, constant: 14),
            formStack.trailingAnchor.constraint(equalTo: formCard.trailingAnchor, constant: -14),
            formStack.bottomAnchor.constraint(equalTo: formCard.bottomAnchor, constant: -14),

            nameField.heightAnchor.constraint(equalToConstant: 44),
            phoneField.heightAnchor.constraint(equalToConstant: 44),
            addressView.heightAnchor.constraint(equalToConstant: 96)
        ])

        // Shipping
        let shippingTitle = makeSectionTitle("Shipping")
        shippingCard.addSubview(shippingTitle)
        shippingCard.addSubview(shippingSegment)

        NSLayoutConstraint.activate([
            shippingTitle.topAnchor.constraint(equalTo: shippingCard.topAnchor, constant: 14),
            shippingTitle.leadingAnchor.constraint(equalTo: shippingCard.leadingAnchor, constant: 14),
            shippingTitle.trailingAnchor.constraint(equalTo: shippingCard.trailingAnchor, constant: -14),

            shippingSegment.topAnchor.constraint(equalTo: shippingTitle.bottomAnchor, constant: 12),
            shippingSegment.leadingAnchor.constraint(equalTo: shippingCard.leadingAnchor, constant: 14),
            shippingSegment.trailingAnchor.constraint(equalTo: shippingCard.trailingAnchor, constant: -14),
            shippingSegment.bottomAnchor.constraint(equalTo: shippingCard.bottomAnchor, constant: -14)
        ])

        // Summary
        summaryCard.addSubview(summaryTitleLabel)
        configureSummaryLabel(subtotalLabel)
        configureSummaryLabel(shippingLabel)
        configureSummaryLabel(totalLabel, bold: true)

        let summaryStack = UIStackView(arrangedSubviews: [subtotalLabel, shippingLabel, totalLabel])
        summaryStack.axis = .vertical
        summaryStack.spacing = 8
        summaryStack.translatesAutoresizingMaskIntoConstraints = false
        summaryCard.addSubview(summaryStack)

        NSLayoutConstraint.activate([
            summaryTitleLabel.topAnchor.constraint(equalTo: summaryCard.topAnchor, constant: 14),
            summaryTitleLabel.leadingAnchor.constraint(equalTo: summaryCard.leadingAnchor, constant: 14),

            summaryStack.topAnchor.constraint(equalTo: summaryTitleLabel.bottomAnchor, constant: 12),
            summaryStack.leadingAnchor.constraint(equalTo: summaryCard.leadingAnchor, constant: 14),
            summaryStack.trailingAnchor.constraint(equalTo: summaryCard.trailingAnchor, constant: -14),
            summaryStack.bottomAnchor.constraint(equalTo: summaryCard.bottomAnchor, constant: -14)
        ])
    }

    // MARK: - Helpers

    private func makeCard() -> UIView {
        let v = UIView()
        v.backgroundColor = .systemBackground
        v.layer.cornerRadius = 16
        v.layer.borderWidth = 1
        v.layer.borderColor = UIColor.separator.cgColor
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }

    private func makeSectionTitle(_ text: String) -> UILabel {
        let l = UILabel()
        l.text = text
        l.font = .systemFont(ofSize: 15, weight: .bold)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }

    private func configureTextField(_ tf: UITextField, placeholder: String) {
        tf.placeholder = placeholder
        tf.backgroundColor = .secondarySystemGroupedBackground
        tf.layer.cornerRadius = 12
        tf.layer.borderWidth = 1
        tf.layer.borderColor = UIColor.separator.cgColor
        tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 1))
        tf.leftViewMode = .always
        tf.autocorrectionType = .no
        tf.autocapitalizationType = .words
    }

    private func configureSummaryLabel(_ label: UILabel, bold: Bool = false) {
        label.font = bold ? .systemFont(ofSize: 16, weight: .bold) : .systemFont(ofSize: 15, weight: .semibold)
        label.textColor = bold ? .label : .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
    }

    private func updateSummary() {
        subtotalLabel.text = String(format: "Subtotal: $%.2f", cartStore.subtotal)
        shippingLabel.text = String(format: "Shipping: $%.2f", shippingFee)
        totalLabel.text = String(format: "Total: $%.2f", total)

        totalInBarLabel.text = "Total"
        totalInBarValueLabel.text = String(format: "$%.2f", total)
    }

    // MARK: - Actions

    @objc private func shippingChanged() {
        updateSummary()
    }

    @objc private func continueTapped() {
        // basic validation
        let name = (nameField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let phone = (phoneField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let address = (addressView.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)

        let addressIsPlaceholder = (addressView.textColor == .secondaryLabel)

        guard !name.isEmpty else { showError("Please enter your full name."); return }
        guard !phone.isEmpty else { showError("Please enter your phone number."); return }
        guard !address.isEmpty, !addressIsPlaceholder else { showError("Please enter your address."); return }

        let paymentVC = PaymentViewController(
            totalAmount: total,
            onSuccess: { [weak self] in
                // Payment success: clear cart
                CartStore.shared.clear()
                self?.navigationController?.popToRootViewController(animated: true)
                self?.tabBarController?.selectedIndex = 0
            }
        )
        navigationController?.pushViewController(paymentVC, animated: true)
    }

    private func showError(_ message: String) {
        ToastPresenter.show(
            on: self,
            title: "Missing Info",
            message: message,
            primaryAction: .init(title: "OK", style: .default)
        )
    }


    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension CheckoutViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .secondaryLabel {
            textView.text = ""
            textView.textColor = .label
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        let t = textView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        if t.isEmpty {
            textView.text = "Address"
            textView.textColor = .secondaryLabel
        }
    }
}
