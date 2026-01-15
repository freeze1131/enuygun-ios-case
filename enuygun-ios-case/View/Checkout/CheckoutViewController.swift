//
//  CheckoutViewController.swift
//  enuygun-ios-case
//
//  Created by Ahmet Ozen on 15.01.2026.
//
import UIKit

final class CheckoutViewController: UIViewController {

    private let viewModel = CheckoutViewModel()

    // amount snapshot (success screen için)
    private var amountAtPayTime: String = "$0.00"

    // MARK: - UI

    private let scrollView = UIScrollView()
    private let contentView = UIView()

    private let summaryCard = UIView()
    private let deliveryCard = UIView()
    private let paymentCard = UIView()
    private let addressCard = UIView()

    private let subtotalValueLabel = UILabel()
    private let deliveryValueLabel = UILabel()
    private let totalValueLabel = UILabel()

    private let deliverySegment: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["Normal", "Express"])
        sc.selectedSegmentIndex = 0
        sc.translatesAutoresizingMaskIntoConstraints = false
        return sc
    }()

    private let deliveryHintLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 13, weight: .semibold)
        l.textColor = .secondaryLabel
        l.numberOfLines = 2
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let nameField = UITextField()
    private let cardNumberField = UITextField()
    private let expiryField = UITextField()
    private let cvvField = UITextField()

    private let addressView: UITextView = {
        let tv = UITextView()
        tv.font = .systemFont(ofSize: 15)
        tv.backgroundColor = .systemBackground
        tv.layer.cornerRadius = 12
        tv.layer.borderWidth = 1
        tv.layer.borderColor = UIColor.separator.cgColor
        tv.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()

    private let addressPlaceholder: UILabel = {
        let l = UILabel()
        l.text = "Address"
        l.font = .systemFont(ofSize: 15)
        l.textColor = .placeholderText
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let bottomBar: UIView = {
        let v = UIView()
        v.backgroundColor = .secondarySystemGroupedBackground
        v.layer.borderWidth = 1
        v.layer.borderColor = UIColor.separator.cgColor
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let payButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Pay", for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        b.backgroundColor = .label
        b.setTitleColor(.systemBackground, for: .normal)
        b.layer.cornerRadius = 14
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    private let spinner: UIActivityIndicatorView = {
        let s = UIActivityIndicatorView(style: .medium)
        s.hidesWhenStopped = true
        s.translatesAutoresizingMaskIntoConstraints = false
        return s
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        title = "Checkout"

        setupUI()
        setupInputFormatting()
        bind()

        payButton.addTarget(self, action: #selector(payTapped), for: .touchUpInside)
        deliverySegment.addTarget(self, action: #selector(deliveryChanged), for: .valueChanged)

        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)

        // placeholder initial
        addressPlaceholder.isHidden = !addressView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func bind() {
        viewModel.onUpdate = { [weak self] in
            self?.render()
        }

        viewModel.onPaymentFailure = { [weak self] message in
            guard let self else { return }
            self.showError(message)
        }

        viewModel.onPaymentSuccess = { [weak self] in
            guard let self else { return }
            self.showSuccess(amountText: self.amountAtPayTime)
        }

        render()
    }

    private func render() {
        subtotalValueLabel.text = viewModel.subtotalText
        deliveryValueLabel.text = viewModel.deliveryFeeText
        totalValueLabel.text = viewModel.totalText
        deliveryHintLabel.text = "ETA: \(viewModel.deliveryEtaText)"

        switch viewModel.state {
        case .idle:
            spinner.stopAnimating()
            payButton.isEnabled = true
            payButton.alpha = 1.0
        case .loading:
            spinner.startAnimating()
            payButton.isEnabled = false
            payButton.alpha = 0.7
        }
    }

    // MARK: - Actions

    @objc private func deliveryChanged() {
        let option: CheckoutViewModel.DeliveryOption = (deliverySegment.selectedSegmentIndex == 1) ? .express : .normal
        viewModel.setDelivery(option)
    }

    @objc private func payTapped() {
        amountAtPayTime = viewModel.amountTextBeforePay()

        let rawCard = cardNumberField.text?.replacingOccurrences(of: " ", with: "")
        let rawExpiry = expiryField.text // zaten MM/YY
        let rawCVV = cvvField.text

        viewModel.pay(
            fullName: nameField.text,
            cardNumber: rawCard,
            expiry: rawExpiry,
            cvv: rawCVV,
            address: addressView.text
        )
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    // MARK: - Navigation

    private func showSuccess(amountText: String) {
        let vc = PaymentSuccessViewController(
            amount: amountText,
            onDone: { [weak self] in
                guard let self else { return }
                self.tabBarController?.selectedIndex = 0
                self.navigationController?.popToRootViewController(animated: false)
            }
        )
        navigationController?.pushViewController(vc, animated: true)
    }

    private func showError(_ message: String) {
        ToastPresenter.show(
            on: self,
            title: "Payment",
            message: message,
            primaryAction: .init(title: "OK", style: .default)
        )
    }

    // MARK: - Input Formatting Setup

    private func setupInputFormatting() {
        // delegates
        cardNumberField.delegate = self
        expiryField.delegate = self
        cvvField.delegate = self

        // keyboards
        cardNumberField.keyboardType = .numberPad
        expiryField.keyboardType = .numberPad
        cvvField.keyboardType = .numberPad

        // helpful
        cardNumberField.textContentType = .creditCardNumber
        expiryField.textContentType = nil
        cvvField.textContentType = nil

        // editing changed (paste durumları için de düzeltme)
        cardNumberField.addTarget(self, action: #selector(cardNumberEditingChanged), for: .editingChanged)
        expiryField.addTarget(self, action: #selector(expiryEditingChanged), for: .editingChanged)
        cvvField.addTarget(self, action: #selector(cvvEditingChanged), for: .editingChanged)
    }

    @objc private func cardNumberEditingChanged() {
        let digits = digitsOnly(cardNumberField.text).prefix(16)
        cardNumberField.text = formatCardNumber(String(digits))
    }

    @objc private func expiryEditingChanged() {
        let digits = digitsOnly(expiryField.text).prefix(4)
        expiryField.text = formatExpiry(String(digits)) // MM/YY
    }

    @objc private func cvvEditingChanged() {
        let digits = digitsOnly(cvvField.text).prefix(3)
        cvvField.text = String(digits)
    }

    // MARK: - UI Setup

    private func setupUI() {
        // Bottom bar (tek sefer!)
        view.addSubview(bottomBar)
        bottomBar.addSubview(payButton)
        bottomBar.addSubview(spinner)

        // Scroll container
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        NSLayoutConstraint.activate([
            // bottom bar
            bottomBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            bottomBar.heightAnchor.constraint(equalToConstant: 96),

            payButton.topAnchor.constraint(equalTo: bottomBar.topAnchor, constant: 14),
            payButton.leadingAnchor.constraint(equalTo: bottomBar.leadingAnchor, constant: 16),
            payButton.trailingAnchor.constraint(equalTo: bottomBar.trailingAnchor, constant: -16),
            payButton.heightAnchor.constraint(equalToConstant: 52),

            spinner.centerXAnchor.constraint(equalTo: bottomBar.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: bottomBar.centerYAnchor),

            // scroll view
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomBar.topAnchor),

            // content view (scrollview içinde düzgün: contentLayoutGuide / frameLayoutGuide)
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])

        // Cards style
        [summaryCard, deliveryCard, paymentCard, addressCard].forEach { card in
            card.translatesAutoresizingMaskIntoConstraints = false
            card.backgroundColor = .systemBackground
            card.layer.cornerRadius = 16
            card.layer.borderWidth = 1
            card.layer.borderColor = UIColor.separator.cgColor
        }

        // Summary card
        let summaryTitle = makeSectionTitle("Order Summary")
        let rowsStack = UIStackView(arrangedSubviews: [
            makeRow(title: "Subtotal", valueLabel: subtotalValueLabel),
            makeRow(title: "Delivery", valueLabel: deliveryValueLabel),
            makeRow(title: "Total", valueLabel: totalValueLabel, isEmphasis: true)
        ])
        rowsStack.axis = .vertical
        rowsStack.spacing = 10
        rowsStack.translatesAutoresizingMaskIntoConstraints = false

        summaryCard.addSubview(summaryTitle)
        summaryCard.addSubview(rowsStack)

        // Delivery card
        let deliveryTitle = makeSectionTitle("Delivery")
        deliveryCard.addSubview(deliveryTitle)
        deliveryCard.addSubview(deliverySegment)
        deliveryCard.addSubview(deliveryHintLabel)

        // Payment card
        let paymentTitle = makeSectionTitle("Payment")
        configureField(nameField, placeholder: "Full Name")
        configureField(cardNumberField, placeholder: "Card Number")
        configureField(expiryField, placeholder: "MM/YY")
        configureField(cvvField, placeholder: "CVV")

        cvvField.isSecureTextEntry = true

        let row2 = UIStackView(arrangedSubviews: [expiryField, cvvField])
        row2.axis = .horizontal
        row2.spacing = 12
        row2.distribution = .fillEqually
        row2.translatesAutoresizingMaskIntoConstraints = false

        paymentCard.addSubview(paymentTitle)
        paymentCard.addSubview(nameField)
        paymentCard.addSubview(cardNumberField)
        paymentCard.addSubview(row2)

        // Address card
        let addressTitle = makeSectionTitle("Address")
        addressCard.addSubview(addressTitle)
        addressCard.addSubview(addressView)
        addressCard.addSubview(addressPlaceholder)
        addressView.delegate = self

        // Main stack
        let mainStack = UIStackView(arrangedSubviews: [summaryCard, deliveryCard, paymentCard, addressCard])
        mainStack.axis = .vertical
        mainStack.spacing = 14
        mainStack.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(mainStack)

        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            mainStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            mainStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            mainStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),

            // Summary layout
            summaryTitle.topAnchor.constraint(equalTo: summaryCard.topAnchor, constant: 14),
            summaryTitle.leadingAnchor.constraint(equalTo: summaryCard.leadingAnchor, constant: 14),
            summaryTitle.trailingAnchor.constraint(equalTo: summaryCard.trailingAnchor, constant: -14),

            rowsStack.topAnchor.constraint(equalTo: summaryTitle.bottomAnchor, constant: 12),
            rowsStack.leadingAnchor.constraint(equalTo: summaryCard.leadingAnchor, constant: 14),
            rowsStack.trailingAnchor.constraint(equalTo: summaryCard.trailingAnchor, constant: -14),
            rowsStack.bottomAnchor.constraint(equalTo: summaryCard.bottomAnchor, constant: -14),

            // Delivery layout
            deliveryTitle.topAnchor.constraint(equalTo: deliveryCard.topAnchor, constant: 14),
            deliveryTitle.leadingAnchor.constraint(equalTo: deliveryCard.leadingAnchor, constant: 14),
            deliveryTitle.trailingAnchor.constraint(equalTo: deliveryCard.trailingAnchor, constant: -14),

            deliverySegment.topAnchor.constraint(equalTo: deliveryTitle.bottomAnchor, constant: 12),
            deliverySegment.leadingAnchor.constraint(equalTo: deliveryCard.leadingAnchor, constant: 14),
            deliverySegment.trailingAnchor.constraint(equalTo: deliveryCard.trailingAnchor, constant: -14),

            deliveryHintLabel.topAnchor.constraint(equalTo: deliverySegment.bottomAnchor, constant: 10),
            deliveryHintLabel.leadingAnchor.constraint(equalTo: deliveryCard.leadingAnchor, constant: 14),
            deliveryHintLabel.trailingAnchor.constraint(equalTo: deliveryCard.trailingAnchor, constant: -14),
            deliveryHintLabel.bottomAnchor.constraint(equalTo: deliveryCard.bottomAnchor, constant: -14),

            // Payment layout
            paymentTitle.topAnchor.constraint(equalTo: paymentCard.topAnchor, constant: 14),
            paymentTitle.leadingAnchor.constraint(equalTo: paymentCard.leadingAnchor, constant: 14),
            paymentTitle.trailingAnchor.constraint(equalTo: paymentCard.trailingAnchor, constant: -14),

            nameField.topAnchor.constraint(equalTo: paymentTitle.bottomAnchor, constant: 12),
            nameField.leadingAnchor.constraint(equalTo: paymentCard.leadingAnchor, constant: 14),
            nameField.trailingAnchor.constraint(equalTo: paymentCard.trailingAnchor, constant: -14),
            nameField.heightAnchor.constraint(equalToConstant: 44),

            cardNumberField.topAnchor.constraint(equalTo: nameField.bottomAnchor, constant: 10),
            cardNumberField.leadingAnchor.constraint(equalTo: paymentCard.leadingAnchor, constant: 14),
            cardNumberField.trailingAnchor.constraint(equalTo: paymentCard.trailingAnchor, constant: -14),
            cardNumberField.heightAnchor.constraint(equalToConstant: 44),

            row2.topAnchor.constraint(equalTo: cardNumberField.bottomAnchor, constant: 10),
            row2.leadingAnchor.constraint(equalTo: paymentCard.leadingAnchor, constant: 14),
            row2.trailingAnchor.constraint(equalTo: paymentCard.trailingAnchor, constant: -14),

            expiryField.heightAnchor.constraint(equalToConstant: 44),
            cvvField.heightAnchor.constraint(equalToConstant: 44),

            row2.bottomAnchor.constraint(equalTo: paymentCard.bottomAnchor, constant: -14),

            // Address layout
            addressTitle.topAnchor.constraint(equalTo: addressCard.topAnchor, constant: 14),
            addressTitle.leadingAnchor.constraint(equalTo: addressCard.leadingAnchor, constant: 14),
            addressTitle.trailingAnchor.constraint(equalTo: addressCard.trailingAnchor, constant: -14),

            addressView.topAnchor.constraint(equalTo: addressTitle.bottomAnchor, constant: 12),
            addressView.leadingAnchor.constraint(equalTo: addressCard.leadingAnchor, constant: 14),
            addressView.trailingAnchor.constraint(equalTo: addressCard.trailingAnchor, constant: -14),
            addressView.heightAnchor.constraint(equalToConstant: 120),
            addressView.bottomAnchor.constraint(equalTo: addressCard.bottomAnchor, constant: -14),

            addressPlaceholder.topAnchor.constraint(equalTo: addressView.topAnchor, constant: 10),
            addressPlaceholder.leadingAnchor.constraint(equalTo: addressView.leadingAnchor, constant: 14)
        ])
    }

    // MARK: - UI helpers

    private func makeSectionTitle(_ text: String) -> UILabel {
        let l = UILabel()
        l.text = text
        l.font = .systemFont(ofSize: 15, weight: .bold)
        l.textColor = .label
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }

    private func makeRow(title: String, valueLabel: UILabel, isEmphasis: Bool = false) -> UIView {
        let left = UILabel()
        left.text = title
        left.font = .systemFont(ofSize: 14, weight: isEmphasis ? .bold : .semibold)
        left.textColor = .secondaryLabel

        valueLabel.font = .systemFont(ofSize: 14, weight: isEmphasis ? .bold : .semibold)
        valueLabel.textColor = .label
        valueLabel.textAlignment = .right

        let h = UIStackView(arrangedSubviews: [left, valueLabel])
        h.axis = .horizontal
        h.alignment = .center
        h.spacing = 10
        return h
    }

    private func configureField(_ tf: UITextField, placeholder: String) {
        tf.translatesAutoresizingMaskIntoConstraints = false
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

    // MARK: - Formatting helpers

    private func digitsOnly(_ text: String?) -> String {
        let s = text ?? ""
        return s.filter { $0.isNumber }
    }

    private func formatCardNumber(_ digits: String) -> String {
        // "4242424242424242" -> "4242 4242 4242 4242"
        var out = ""
        for (i, ch) in digits.enumerated() {
            if i != 0 && i % 4 == 0 { out.append(" ") }
            out.append(ch)
        }
        return out
    }

    private func formatExpiry(_ digits: String) -> String {
        // "0127" -> "01/27", "0" -> "0", "01" -> "01", "012" -> "01/2"
        let d = Array(digits)
        if d.count <= 2 {
            return String(d)
        } else {
            let mm = String(d.prefix(2))
            let yy = String(d.dropFirst(2))
            return "\(mm)/\(yy)"
        }
    }
}

// MARK: - UITextViewDelegate (Address placeholder)
extension CheckoutViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        addressPlaceholder.isHidden = !textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        addressPlaceholder.isHidden = true
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        addressPlaceholder.isHidden = !textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

// MARK: - UITextFieldDelegate (Card / Expiry / CVV restrictions)
extension CheckoutViewController: UITextFieldDelegate {

    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {

        // backspace / normal behavior for non-number? -> biz sadece digit istiyoruz
        if string.isEmpty { return true }

        // sadece rakam
        guard string.allSatisfy({ $0.isNumber }) else { return false }

        if textField === cardNumberField {
            // max 16 digit
            let currentDigits = digitsOnly(textField.text)
            return currentDigits.count < 16
        }

        if textField === expiryField {
            // max 4 digit (MMYY) -> UI'da MM/YY
            let currentDigits = digitsOnly(textField.text)
            return currentDigits.count < 4
        }

        if textField === cvvField {
            // max 3 digit
            let currentDigits = digitsOnly(textField.text)
            return currentDigits.count < 3
        }

        return true
    }
}
