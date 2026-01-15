//
//  CartItemCell.swift
//  enuygun-ios-case
//
//  Created by Ahmet Ozen on 15.01.2026.
//

import UIKit

final class CartItemCell: UICollectionViewCell {

    static let reuseIdentifier = "CartItemCell"

    var onIncrease: (() -> Void)?
    var onDecrease: (() -> Void)?
    var onRemove: (() -> Void)?

    // MARK: - UI

    private let cardView: UIView = {
        let v = UIView()
        v.backgroundColor = .systemBackground
        v.layer.cornerRadius = 14
        v.layer.borderWidth = 1
        v.layer.borderColor = UIColor.separator.cgColor
        v.layer.masksToBounds = true
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let imagePlaceholderView: UIView = {
        let v = UIView()
        v.backgroundColor = .secondarySystemGroupedBackground
        v.layer.cornerRadius = 10
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let productImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 10
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let imageSpinner: UIActivityIndicatorView = {
        let s = UIActivityIndicatorView(style: .medium)
        s.hidesWhenStopped = true
        s.translatesAutoresizingMaskIntoConstraints = false
        return s
    }()

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 15, weight: .semibold)
        l.numberOfLines = 2
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let priceLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 15, weight: .bold)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let oldPriceLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 12, weight: .semibold)
        l.textColor = .secondaryLabel
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let discountLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 12, weight: .bold)
        l.textColor = .systemRed
        l.backgroundColor = UIColor.systemRed.withAlphaComponent(0.10)
        l.layer.cornerRadius = 10
        l.layer.masksToBounds = true
        l.isHidden = true
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let qtyLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 14, weight: .bold)
        l.textAlignment = .center
        l.textColor = .label
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let minusButton: UIButton = {
        let b = UIButton(type: .system)
        b.setImage(UIImage(systemName: "minus"), for: .normal)
        b.tintColor = .label
        b.backgroundColor = .secondarySystemGroupedBackground
        b.layer.cornerRadius = 12
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    private let plusButton: UIButton = {
        let b = UIButton(type: .system)
        b.setImage(UIImage(systemName: "plus"), for: .normal)
        b.tintColor = .label
        b.backgroundColor = .secondarySystemGroupedBackground
        b.layer.cornerRadius = 12
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    private let removeButton: UIButton = {
        let b = UIButton(type: .system)
        b.setImage(UIImage(systemName: "trash"), for: .normal)
        b.tintColor = .systemRed
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    private let priceRow: UIStackView = {
        let s = UIStackView()
        s.axis = .horizontal
        s.spacing = 6
        s.alignment = .center
        s.translatesAutoresizingMaskIntoConstraints = false
        return s
    }()

    private let qtyRow: UIStackView = {
        let s = UIStackView()
        s.axis = .horizontal
        s.spacing = 8
        s.alignment = .center
        s.translatesAutoresizingMaskIntoConstraints = false
        return s
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) { fatalError() }

    override func prepareForReuse() {
        super.prepareForReuse()

        productImageView.image = nil
        productImageView.alpha = 0
        imagePlaceholderView.alpha = 1
        imageSpinner.stopAnimating()

        titleLabel.text = nil
        priceLabel.text = nil
        oldPriceLabel.attributedText = nil
        discountLabel.text = nil
        discountLabel.isHidden = true
        qtyLabel.text = nil

        onIncrease = nil
        onDecrease = nil
        onRemove = nil
    }

    private func setupUI() {
        contentView.backgroundColor = .clear
        contentView.addSubview(cardView)

        cardView.addSubview(imagePlaceholderView)
        cardView.addSubview(productImageView)
        cardView.addSubview(imageSpinner)

        cardView.addSubview(titleLabel)
        cardView.addSubview(priceRow)
        priceRow.addArrangedSubview(priceLabel)
        priceRow.addArrangedSubview(oldPriceLabel)
        cardView.addSubview(discountLabel)

        cardView.addSubview(qtyRow)
        qtyRow.addArrangedSubview(minusButton)
        qtyRow.addArrangedSubview(qtyLabel)
        qtyRow.addArrangedSubview(plusButton)

        cardView.addSubview(removeButton)

        minusButton.addTarget(self, action: #selector(minusTapped), for: .touchUpInside)
        plusButton.addTarget(self, action: #selector(plusTapped), for: .touchUpInside)
        removeButton.addTarget(self, action: #selector(removeTapped), for: .touchUpInside)

        oldPriceLabel.setContentHuggingPriority(.required, for: .horizontal)
        oldPriceLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            imagePlaceholderView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            imagePlaceholderView.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            imagePlaceholderView.widthAnchor.constraint(equalToConstant: 76),
            imagePlaceholderView.heightAnchor.constraint(equalToConstant: 76),

            productImageView.topAnchor.constraint(equalTo: imagePlaceholderView.topAnchor),
            productImageView.leadingAnchor.constraint(equalTo: imagePlaceholderView.leadingAnchor),
            productImageView.trailingAnchor.constraint(equalTo: imagePlaceholderView.trailingAnchor),
            productImageView.bottomAnchor.constraint(equalTo: imagePlaceholderView.bottomAnchor),

            imageSpinner.centerXAnchor.constraint(equalTo: imagePlaceholderView.centerXAnchor),
            imageSpinner.centerYAnchor.constraint(equalTo: imagePlaceholderView.centerYAnchor),

            removeButton.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 10),
            removeButton.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -10),
            removeButton.widthAnchor.constraint(equalToConstant: 28),
            removeButton.heightAnchor.constraint(equalToConstant: 28),

            titleLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: imagePlaceholderView.trailingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: removeButton.leadingAnchor, constant: -8),

            priceRow.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            priceRow.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            priceRow.trailingAnchor.constraint(lessThanOrEqualTo: cardView.trailingAnchor, constant: -12),

            discountLabel.topAnchor.constraint(equalTo: priceRow.bottomAnchor, constant: 6),
            discountLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),

            qtyRow.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            qtyRow.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -12),

            minusButton.widthAnchor.constraint(equalToConstant: 36),
            minusButton.heightAnchor.constraint(equalToConstant: 36),
            plusButton.widthAnchor.constraint(equalToConstant: 36),
            plusButton.heightAnchor.constraint(equalToConstant: 36),

            qtyLabel.widthAnchor.constraint(equalToConstant: 28)
        ])
    }

    func configure(with item: CartItem) {
        titleLabel.text = item.product.title
        qtyLabel.text = "\(item.quantity)"

        // Price
        let price = item.product.price
        if let discount = item.product.discountPercentage, discount > 0 {
            let discounted = price * (1 - discount / 100)
            priceLabel.text = String(format: "$%.2f", discounted)

            oldPriceLabel.attributedText = NSAttributedString(
                string: String(format: "$%.2f", price),
                attributes: [.strikethroughStyle: NSUnderlineStyle.single.rawValue]
            )

            discountLabel.text = "  %\(Int(discount)) OFF  "
            discountLabel.isHidden = false
        } else {
            priceLabel.text = String(format: "$%.2f", price)
            oldPriceLabel.attributedText = nil
            discountLabel.text = nil
            discountLabel.isHidden = true
        }

        minusButton.isEnabled = true
        minusButton.alpha = 1.0

        // Image loading (soft)
        productImageView.image = nil
        productImageView.alpha = 0
        imagePlaceholderView.alpha = 1
        imageSpinner.startAnimating()

        ImageLoader.shared.load(from: item.product.thumbnail) { [weak self] image in
            guard let self else { return }
            self.imageSpinner.stopAnimating()

            if let image {
                self.productImageView.image = image
                UIView.animate(withDuration: 0.2) {
                    self.productImageView.alpha = 1
                    self.imagePlaceholderView.alpha = 0
                }
            } else {
                self.productImageView.alpha = 0
                self.imagePlaceholderView.alpha = 1
            }
        }
    }

    // MARK: - Actions

    @objc private func minusTapped() {
        animateTap(minusButton)
        onDecrease?()
    }

    @objc private func plusTapped() {
        animateTap(plusButton)
        onIncrease?()
    }

    @objc private func removeTapped() {
        animateTap(removeButton)
        onRemove?()
    }

    private func animateTap(_ view: UIView) {
        UIView.animate(withDuration: 0.10, animations: {
            view.transform = CGAffineTransform(scaleX: 0.88, y: 0.88)
        }) { _ in
            UIView.animate(withDuration: 0.12) {
                view.transform = .identity
            }
        }
    }
}

