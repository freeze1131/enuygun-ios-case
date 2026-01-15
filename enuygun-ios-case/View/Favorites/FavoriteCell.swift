//
//  FavoriteCell.swift
//  enuygun-ios-case
//
//  Created by Ahmet Ozen on 15.01.2026.
//

import UIKit

final class FavoriteCell: UICollectionViewCell {

    static let reuseIdentifier = "FavoriteCell"

    var onRemove: (() -> Void)?
    var onAddToCart: (() -> Void)?

    private let cardView: UIView = {
        let v = UIView()
        v.backgroundColor = .systemBackground
        v.layer.cornerRadius = 16
        v.layer.masksToBounds = true
        v.layer.borderWidth = 1
        v.layer.borderColor = UIColor.separator.cgColor
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let topOverlayContainer: UIView = {
        let v = UIView()
        v.backgroundColor = .clear
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let productImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let imagePlaceholderView: UIView = {
        let v = UIView()
        v.backgroundColor = .secondarySystemGroupedBackground
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let imageSpinner: UIActivityIndicatorView = {
        let s = UIActivityIndicatorView(style: .medium)
        s.hidesWhenStopped = true
        s.translatesAutoresizingMaskIntoConstraints = false
        return s
    }()

    private let discountBadge: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 12, weight: .bold)
        l.textColor = .white
        l.backgroundColor = .systemRed
        l.layer.cornerRadius = 10
        l.layer.masksToBounds = true
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let removeButton: UIButton = {
        let b = UIButton(type: .system)
        b.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        b.tintColor = .label
        b.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.75)
        b.layer.cornerRadius = 14
        b.clipsToBounds = true
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    private let addButton: UIButton = {
        let b = UIButton(type: .system)
        b.setImage(UIImage(systemName: "plus"), for: .normal)
        b.tintColor = .label
        b.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.75)
        b.layer.cornerRadius = 14
        b.clipsToBounds = true
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 13, weight: .semibold)
        l.textColor = .label
        l.numberOfLines = 2
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let priceLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 16, weight: .bold)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let oldPriceLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 12)
        l.textColor = .secondaryLabel
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()

        removeButton.addTarget(self, action: #selector(removeTapped), for: .touchUpInside)
        addButton.addTarget(self, action: #selector(addTapped), for: .touchUpInside)
    }

    required init?(coder: NSCoder) { fatalError() }

    override func prepareForReuse() {
        super.prepareForReuse()

        productImageView.image = nil
        productImageView.alpha = 0
        imagePlaceholderView.alpha = 1
        imageSpinner.stopAnimating()

        discountBadge.isHidden = true
        discountBadge.text = nil

        titleLabel.text = nil
        priceLabel.text = nil
        oldPriceLabel.attributedText = nil
    }

    private func setupUI() {
        contentView.backgroundColor = .clear
        contentView.addSubview(cardView)

        cardView.addSubview(topOverlayContainer)
        cardView.addSubview(productImageView)
        cardView.addSubview(imagePlaceholderView)
        cardView.addSubview(imageSpinner)

        topOverlayContainer.addSubview(discountBadge)
        topOverlayContainer.addSubview(removeButton)
        topOverlayContainer.addSubview(addButton)

        cardView.addSubview(titleLabel)
        cardView.addSubview(priceLabel)
        cardView.addSubview(oldPriceLabel)

        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            topOverlayContainer.topAnchor.constraint(equalTo: cardView.topAnchor),
            topOverlayContainer.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
            topOverlayContainer.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
            topOverlayContainer.heightAnchor.constraint(equalToConstant: 40),

            productImageView.topAnchor.constraint(equalTo: topOverlayContainer.bottomAnchor),
            productImageView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
            productImageView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
            productImageView.heightAnchor.constraint(equalTo: cardView.widthAnchor, constant: -40),

            imagePlaceholderView.topAnchor.constraint(equalTo: productImageView.topAnchor),
            imagePlaceholderView.leadingAnchor.constraint(equalTo: productImageView.leadingAnchor),
            imagePlaceholderView.trailingAnchor.constraint(equalTo: productImageView.trailingAnchor),
            imagePlaceholderView.bottomAnchor.constraint(equalTo: productImageView.bottomAnchor),

            imageSpinner.centerXAnchor.constraint(equalTo: productImageView.centerXAnchor),
            imageSpinner.centerYAnchor.constraint(equalTo: productImageView.centerYAnchor),

            discountBadge.topAnchor.constraint(equalTo: topOverlayContainer.topAnchor, constant: 8),
            discountBadge.leadingAnchor.constraint(equalTo: topOverlayContainer.leadingAnchor, constant: 8),
            discountBadge.heightAnchor.constraint(equalToConstant: 20),

            removeButton.topAnchor.constraint(equalTo: topOverlayContainer.topAnchor, constant: 6),
            removeButton.trailingAnchor.constraint(equalTo: topOverlayContainer.trailingAnchor, constant: -8),
            removeButton.widthAnchor.constraint(equalToConstant: 28),
            removeButton.heightAnchor.constraint(equalToConstant: 28),

            addButton.topAnchor.constraint(equalTo: topOverlayContainer.topAnchor, constant: 6),
            addButton.trailingAnchor.constraint(equalTo: removeButton.leadingAnchor, constant: -6),
            addButton.widthAnchor.constraint(equalToConstant: 28),
            addButton.heightAnchor.constraint(equalToConstant: 28),

            // text section (under image)
            titleLabel.topAnchor.constraint(equalTo: productImageView.bottomAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -10),

            priceLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
            priceLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),

            oldPriceLabel.centerYAnchor.constraint(equalTo: priceLabel.centerYAnchor),
            oldPriceLabel.leadingAnchor.constraint(equalTo: priceLabel.trailingAnchor, constant: 6),
            oldPriceLabel.trailingAnchor.constraint(lessThanOrEqualTo: cardView.trailingAnchor, constant: -10),
            oldPriceLabel.bottomAnchor.constraint(lessThanOrEqualTo: cardView.bottomAnchor, constant: -10)
        ])
    }

    // MARK: - Configure

    func configure(viewData: FavoritesViewModel.CellViewData) {
        titleLabel.text = viewData.title
        priceLabel.text = viewData.priceText
        oldPriceLabel.attributedText = viewData.oldPriceText

        if let badge = viewData.discountBadgeText {
            discountBadge.isHidden = false
            discountBadge.text = "  \(badge)  "
        } else {
            discountBadge.isHidden = true
            discountBadge.text = nil
        }

        // Image state
        productImageView.image = nil
        productImageView.alpha = 0
        imagePlaceholderView.alpha = 1
        imageSpinner.startAnimating()

        ImageLoader.shared.load(from: viewData.imageURL) { [weak self] image in
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

    @objc private func removeTapped() {
        onRemove?()
    }

    @objc private func addTapped() {
        onAddToCart?()
    }
}
