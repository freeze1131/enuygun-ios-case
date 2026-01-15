//
//  FavoriteCell.swift
//  enuygun-ios-case
//
//  Created by Ahmet Ozen on 15.01.2026.
//

import UIKit

final class FavoriteCell: UICollectionViewCell {

    static let reuseIdentifier = "FavoriteCell"
    var onAddToCart: (() -> Void)?
    var onRemove: (() -> Void)?

    // MARK: - Views

    private let cardView: UIView = {
        let v = UIView()
        v.backgroundColor = .secondarySystemGroupedBackground
        v.layer.cornerRadius = 18
        v.layer.borderWidth = 1
        v.layer.borderColor = UIColor.separator.cgColor
        v.layer.masksToBounds = true
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    // Image
    private let imagePlaceholderView: UIView = {
        let v = UIView()
        v.backgroundColor = .tertiarySystemGroupedBackground
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

    private let imageSpinner: UIActivityIndicatorView = {
        let s = UIActivityIndicatorView(style: .medium)
        s.hidesWhenStopped = true
        s.translatesAutoresizingMaskIntoConstraints = false
        return s
    }()

    // Top title inside card (small)
    private let headerTitleLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 12, weight: .semibold)
        l.textColor = .secondaryLabel
        l.numberOfLines = 1
        l.lineBreakMode = .byTruncatingTail
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    // Main title under image
    private let titleLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 14, weight: .semibold)
        l.textColor = .label
        l.numberOfLines = 2
        l.lineBreakMode = .byTruncatingTail
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    // Price row
    private let priceLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 15, weight: .bold)
        l.textColor = .label
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

    private let priceRow: UIStackView = {
        let s = UIStackView()
        s.axis = .horizontal
        s.spacing = 6
        s.alignment = .center
        s.translatesAutoresizingMaskIntoConstraints = false
        return s
    }()

    // Discount chip
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

    // Overlay buttons
    private let addButton: UIButton = {
        let b = UIButton(type: .system)
        b.setImage(UIImage(systemName: "plus"), for: .normal)
        b.tintColor = .label
        b.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.75)
        b.layer.cornerRadius = 16
        b.layer.masksToBounds = true
        b.layer.borderWidth = 1
        b.layer.borderColor = UIColor.separator.cgColor
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    private let removeButton: UIButton = {
        let b = UIButton(type: .system)
        b.setImage(UIImage(systemName: "heart.slash"), for: .normal)
        b.tintColor = .systemRed
        b.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.75)
        b.layer.cornerRadius = 16
        b.layer.masksToBounds = true
        b.layer.borderWidth = 1
        b.layer.borderColor = UIColor.separator.cgColor
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    // MARK: - Init

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

        headerTitleLabel.text = nil
        titleLabel.text = nil

        priceLabel.text = nil
        oldPriceLabel.attributedText = nil
        oldPriceLabel.isHidden = true

        discountLabel.text = nil
        discountLabel.isHidden = true

        onAddToCart = nil
        onRemove = nil
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        // Soft shadow on container (premium)
        contentView.layer.masksToBounds = false
        contentView.layer.shadowOpacity = 0.08
        contentView.layer.shadowRadius = 10
        contentView.layer.shadowOffset = CGSize(width: 0, height: 6)
        contentView.layer.shadowColor = UIColor.black.cgColor
        contentView.layer.shadowPath = UIBezierPath(
            roundedRect: cardView.frame,
            cornerRadius: cardView.layer.cornerRadius
        ).cgPath
    }

    private func setupUI() {
        contentView.backgroundColor = .clear
        contentView.addSubview(cardView)

        // Image stack
        cardView.addSubview(imagePlaceholderView)
        cardView.addSubview(productImageView)
        cardView.addSubview(imageSpinner)

        // Overlay buttons
        cardView.addSubview(addButton)
        cardView.addSubview(removeButton)

        // Texts
        cardView.addSubview(headerTitleLabel)
        cardView.addSubview(titleLabel)
        cardView.addSubview(priceRow)
        priceRow.addArrangedSubview(priceLabel)
        priceRow.addArrangedSubview(oldPriceLabel)
        cardView.addSubview(discountLabel)

        // Actions + animation on tap
        addButton.addTarget(self, action: #selector(addTapped), for: .touchUpInside)
        removeButton.addTarget(self, action: #selector(removeTapped), for: .touchUpInside)

        oldPriceLabel.setContentHuggingPriority(.required, for: .horizontal)
        oldPriceLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            // Image area: square
            imagePlaceholderView.topAnchor.constraint(equalTo: cardView.topAnchor),
            imagePlaceholderView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
            imagePlaceholderView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
            imagePlaceholderView.heightAnchor.constraint(equalTo: cardView.widthAnchor),

            productImageView.topAnchor.constraint(equalTo: imagePlaceholderView.topAnchor),
            productImageView.leadingAnchor.constraint(equalTo: imagePlaceholderView.leadingAnchor),
            productImageView.trailingAnchor.constraint(equalTo: imagePlaceholderView.trailingAnchor),
            productImageView.bottomAnchor.constraint(equalTo: imagePlaceholderView.bottomAnchor),

            imageSpinner.centerXAnchor.constraint(equalTo: imagePlaceholderView.centerXAnchor),
            imageSpinner.centerYAnchor.constraint(equalTo: imagePlaceholderView.centerYAnchor),

            // Overlay buttons (bottom corners of image)
            addButton.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -10),
            addButton.topAnchor.constraint(equalTo: imagePlaceholderView.topAnchor, constant: 10),
            addButton.widthAnchor.constraint(equalToConstant: 32),
            addButton.heightAnchor.constraint(equalToConstant: 32),

            removeButton.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 10),
            removeButton.topAnchor.constraint(equalTo: imagePlaceholderView.topAnchor, constant: 10),
            removeButton.widthAnchor.constraint(equalToConstant: 32),
            removeButton.heightAnchor.constraint(equalToConstant: 32),


            // Header title (small line)
            headerTitleLabel.topAnchor.constraint(equalTo: imagePlaceholderView.bottomAnchor, constant: 10),
            headerTitleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            headerTitleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),

            // Main title (2 lines)
            titleLabel.topAnchor.constraint(equalTo: headerTitleLabel.bottomAnchor, constant: 6),
            titleLabel.leadingAnchor.constraint(equalTo: headerTitleLabel.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: headerTitleLabel.trailingAnchor),

            // Price row
            priceRow.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            priceRow.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            priceRow.trailingAnchor.constraint(lessThanOrEqualTo: cardView.trailingAnchor, constant: -12),

            // Discount chip
            discountLabel.topAnchor.constraint(equalTo: priceRow.bottomAnchor, constant: 6),
            discountLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            discountLabel.bottomAnchor.constraint(lessThanOrEqualTo: cardView.bottomAnchor, constant: -10)
        ])
    }

    // MARK: - Configure

    func configure(with product: Product) {
        // Header line: category (küçük)
        headerTitleLabel.text = product.category.capitalized
        // Main title
        titleLabel.text = product.title

        // Price + discount
        let price = product.price
        if let discount = product.discountPercentage, discount > 0 {
            let discounted = price * (1 - discount / 100)
            priceLabel.text = String(format: "$%.2f", discounted)

            let old = String(format: "$%.2f", price)
            oldPriceLabel.attributedText = NSAttributedString(
                string: old,
                attributes: [.strikethroughStyle: NSUnderlineStyle.single.rawValue]
            )
            oldPriceLabel.isHidden = false

            discountLabel.text = "  %\(Int(discount)) OFF  "
            discountLabel.isHidden = false
        } else {
            priceLabel.text = String(format: "$%.2f", price)
            oldPriceLabel.attributedText = nil
            oldPriceLabel.isHidden = true

            discountLabel.text = nil
            discountLabel.isHidden = true
        }

        // Image loading (soft)
        productImageView.image = nil
        productImageView.alpha = 0
        imagePlaceholderView.alpha = 1
        imageSpinner.startAnimating()

        ImageLoader.shared.load(from: product.thumbnail) { [weak self] image in
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

    // MARK: - Actions (with tap animation)

    @objc private func addTapped() {
        animateTap(addButton)
        onAddToCart?()
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
