//
//  PaymentViewController.swift
//  enuygun-ios-case
//
//  Created by Ahmet Ozen on 15.01.2026.
//

import UIKit

final class PaymentViewController: UIViewController {

    private let totalAmount: Double
    private let onSuccess: () -> Void

    // MARK: - UI

    private let scrollView = UIScrollView()
    private let contentView = UIView()

    private let cardNumberField = UITextField()
    private let nameField = UITextField()
    private let expiryField = UITextField()
    private let cvvField = UITextField()

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

    private let amountLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 14, weight: .semibold)
        l.textColor = .secondaryLabel
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let amountValueLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 18, weight: .bold)
        l.textColor = .label
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let loadingOverlay: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.black.withAlphaComponent(0.25)
        v.alpha = 0
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let spinner: UIActivityIndicatorView = {
        let s = UIActivityIndicatorView(style: .large)
        s.hidesWhenStopped = true
        s.translatesAutoresizingMaskIntoConstraints = false
        return s
    }()

    // MARK: - Init

    init(totalAmount: Double, onSuccess: @escaping () -> Void) {
        self.totalAmount = totalAmount
        self.onSuccess = onSuccess
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        navigationItem.title = "Payment"

        setupLayout()
        setupForm()
        setupLoading()
        updateAmount()

        payButton.addTarget(self, action: #selector(payTapped), for: .touchUpInside)

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
        bottomBar.addSubview(amountLabel)
        bottomBar.addSubview(amountValueLabel)
        bottomBar.addSubview(payButton)

        NSLayoutConstraint.activate([
            bottomBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            bottomBar.heightAnchor.constraint(equalToConstant: 92),

            amountLabel.topAnchor.constraint(equalTo: bottomBar.topAnchor, constant: 12),
            amountLabel.leadingAnchor.constraint(equalTo: bottomBar.leadingAnchor, constant: 16),

            amountValueLabel.topAnchor.constraint(equalTo: amountLabel.bottomAnchor, constant: 2),
            amountValueLabel.leadingAnchor.constraint(equalTo: amountLabel.leadingAnchor),

            payButton.trailingAnchor.constraint(equalTo: bottomBar.trailingAnchor, constant: -16),
            payButton.centerYAnchor.constraint(equalTo: bottomBar.centerYAnchor),
            payButton.heightAnchor.constraint(equalToConstant: 50),
            payButton.widthAnchor.constraint(equalToConstant: 140),

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

    private func setupForm() {
        let card = makeCard()
        contentView.addSubview(card)

        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            card.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            card.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            card.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])

        let title = makeSectionTitle("Card Details")
        card.addSubview(title)

        configureTextField(cardNumberField, placeholder: "Card number (16 digits)")
        configureTextField(nameField, placeholder: "Name on card")
        configureTextField(expiryField, placeholder: "MM/YY")
        configureTextField(cvvField, placeholder: "CVV")

        cardNumberField.keyboardType = .numberPad
        expiryField.keyboardType = .numberPad
        cvvField.keyboardType = .numberPad

        cvvField.isSecureTextEntry = true

        cardNumberField.delegate = self
        expiryField.delegate = self
        cvvField.delegate = self

        let row = UIStackView(arrangedSubviews: [expiryField, cvvField])
        row.axis = .horizontal
        row.spacing = 10
        row.distribution = .fillEqually
        row.translatesAutoresizingMaskIntoConstraints = false

        let stack = UIStackView(arrangedSubviews: [cardNumberField, nameField, row])
        stack.axis = .vertical
        stack.spacing = 10
        stack.translatesAutoresizingMaskIntoConstraints = false

        card.addSubview(stack)

        NSLayoutConstraint.activate([
            title.topAnchor.constraint(equalTo: card.topAnchor, constant: 14),
            title.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 14),

            stack.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 12),
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 14),
            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),
            stack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -14),

            cardNumberField.heightAnchor.constraint(equalToConstant: 44),
            nameField.heightAnchor.constraint(equalToConstant: 44),
            expiryField.heightAnchor.constraint(equalToConstant: 44),
            cvvField.heightAnchor.constraint(equalToConstant: 44)
        ])
    }

    private func setupLoading() {
        view.addSubview(loadingOverlay)
        loadingOverlay.addSubview(spinner)

        NSLayoutConstraint.activate([
            loadingOverlay.topAnchor.constraint(equalTo: view.topAnchor),
            loadingOverlay.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loadingOverlay.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            loadingOverlay.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            spinner.centerXAnchor.constraint(equalTo: loadingOverlay.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: loadingOverlay.centerYAnchor)
        ])
    }

    private func updateAmount() {
        amountLabel.text = "Total"
        amountValueLabel.text = String(format: "$%.2f", Double(totalAmount))
        payButton.setTitle("Pay $\(String(format: "%.2f", Double(totalAmount)))", for: .normal)
    }

    // MARK: - Actions

    @objc private func payTapped() {
        dismissKeyboard()

        guard validateInputs() else { return }

        setLoading(true)

        // Fake payment: 1.2s loading
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { [weak self] in
            guard let self else { return }
            self.setLoading(false)

            // %90 success, %10 fail
            let success = Int.random(in: 1...10) <= 9

            if success {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()

                // push success screen
                let successVC = PaymentSuccessViewController(
                    amount: String(self.totalAmount),
                    onDone: { [weak self] in
                        self?.onSuccess()
                    }
                )
                self.navigationController?.setViewControllers(
                    (self.navigationController?.viewControllers ?? []).dropLast() + [successVC],
                    animated: true
                )
            } else {
                UINotificationFeedbackGenerator().notificationOccurred(.error)
                self.showError("Payment failed. Please try again.")
            }
        }
    }

    private func setLoading(_ loading: Bool) {
        payButton.isEnabled = !loading
        payButton.alpha = loading ? 0.6 : 1.0

        if loading {
            spinner.startAnimating()
            UIView.animate(withDuration: 0.2) {
                self.loadingOverlay.alpha = 1
            }
        } else {
            UIView.animate(withDuration: 0.2, animations: {
                self.loadingOverlay.alpha = 0
            }) { _ in
                self.spinner.stopAnimating()
            }
        }
    }

    private func validateInputs() -> Bool {
        let rawCard = digitsOnly(cardNumberField.text ?? "")
        let name = (nameField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let rawExpiry = (expiryField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let rawCVV = digitsOnly(cvvField.text ?? "")

        guard rawCard.count == 16 else { showError("Card number must be 16 digits."); return false }
        guard name.count >= 2 else { showError("Please enter the name on the card."); return false }
        guard isValidExpiry(rawExpiry) else { showError("Expiry must be in MM/YY format."); return false }
        guard rawCVV.count == 3 else { showError("CVV must be 3 digits."); return false }

        return true
    }

    private func showError(_ message: String) {
        ToastPresenter.show(
            on: self,
            title: "Payment",
            message: message,
            primaryAction: .init(title: "OK", style: .default)
        )
    }


    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    // MARK: - Utils

    private func digitsOnly(_ s: String) -> String {
        s.filter { $0.isNumber }
    }

    private func isValidExpiry(_ s: String) -> Bool {
        // MM/YY
        let parts = s.split(separator: "/")
        guard parts.count == 2 else { return false }
        guard let mm = Int(parts[0]), let yy = Int(parts[1]) else { return false }
        guard (1...12).contains(mm) else { return false }
        guard (0...99).contains(yy) else { return false }
        return true
    }

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
        tf.translatesAutoresizingMaskIntoConstraints = false
    }
}

// MARK: - Formatting input
extension PaymentViewController: UITextFieldDelegate {

    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {

        // only format card / expiry / cvv
        if textField == cardNumberField {
            let current = textField.text ?? ""
            guard let r = Range(range, in: current) else { return false }
            let updated = current.replacingCharacters(in: r, with: string)
            let digits = updated.filter { $0.isNumber }
            if digits.count > 16 { return false }

            // group as "1234 5678 9012 3456"
            var out = ""
            for (i, ch) in digits.enumerated() {
                if i > 0 && i % 4 == 0 { out.append(" ") }
                out.append(ch)
            }
            textField.text = out
            return false
        }

        if textField == expiryField {
            let current = textField.text ?? ""
            guard let r = Range(range, in: current) else { return false }
            let updated = current.replacingCharacters(in: r, with: string)
            let digits = updated.filter { $0.isNumber }
            if digits.count > 4 { return false }

            var out = ""
            for (i, ch) in digits.enumerated() {
                if i == 2 { out.append("/") }
                out.append(ch)
            }
            textField.text = out
            return false
        }

        if textField == cvvField {
            // only digits, max 3
            let current = textField.text ?? ""
            guard let r = Range(range, in: current) else { return false }
            let updated = current.replacingCharacters(in: r, with: string)
            let digits = updated.filter { $0.isNumber }
            if digits.count > 3 { return false }
            textField.text = digits
            return false
        }

        return true
    }
}
