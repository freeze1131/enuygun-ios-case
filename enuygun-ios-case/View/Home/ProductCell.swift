//
//  ProductCell.swift
//  enuygun-ios-case
//
//  Created by Ahmet Ozen on 15.01.2026.
//
import UIKit

final class ProductCell: UICollectionViewCell {

    static let reuseIdentifier = "ProductCell"

    private let productImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 8
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let oldPriceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let discountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .bold)
        label.textColor = .systemRed
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    private func setupUI() {
        contentView.backgroundColor = .secondarySystemBackground
        contentView.layer.cornerRadius = 12

        contentView.addSubview(productImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(priceLabel)
        contentView.addSubview(oldPriceLabel)
        contentView.addSubview(discountLabel)

        NSLayoutConstraint.activate([
            productImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            productImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            productImageView.widthAnchor.constraint(equalToConstant: 80),
            productImageView.heightAnchor.constraint(equalToConstant: 80),

            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: productImageView.trailingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),

            priceLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            priceLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),

            oldPriceLabel.centerYAnchor.constraint(equalTo: priceLabel.centerYAnchor),
            oldPriceLabel.leadingAnchor.constraint(equalTo: priceLabel.trailingAnchor, constant: 8),

            discountLabel.topAnchor.constraint(equalTo: priceLabel.bottomAnchor, constant: 4),
            discountLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor)
        ])
    }

    func configure(with product: Product) {
        titleLabel.text = product.title

        let price = product.price
        if let discount = product.discountPercentage {
            let discountedPrice = price * (1 - discount / 100)
            priceLabel.text = String(format: "$%.2f", discountedPrice)

            oldPriceLabel.text = String(format: "$%.2f", price)
            oldPriceLabel.attributedText = NSAttributedString(
                string: oldPriceLabel.text ?? "",
                attributes: [.strikethroughStyle: NSUnderlineStyle.single.rawValue]
            )

            discountLabel.text = "%\(Int(discount)) OFF"
        } else {
            priceLabel.text = String(format: "$%.2f", price)
            oldPriceLabel.text = nil
            discountLabel.text = nil
        }

        // Şimdilik placeholder
        productImageView.image = UIImage(systemName: "photo")
    }
}
